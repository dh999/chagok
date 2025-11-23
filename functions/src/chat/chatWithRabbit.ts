import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { getChatCompletion, parseJsonFromResponse, ChatMessage } from '../utils/openai';
import { RABBIT_SYSTEM_PROMPT } from '../utils/prompts';

const db = admin.firestore();

interface ChatRequest {
  sessionId: string;
  message: string;
  history: Array<{ role: string; content: string }>;
}

export const chatWithRabbit = functions
  .region('asia-northeast3')
  .https.onCall(async (data: ChatRequest, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        '로그인이 필요합니다.'
      );
    }

    const { sessionId, message, history } = data;
    const uid = context.auth.uid;

    try {
      // 세션 확인
      const sessionRef = db.collection('chat_sessions').doc(sessionId);
      const sessionDoc = await sessionRef.get();

      if (!sessionDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          '채팅 세션을 찾을 수 없습니다.'
        );
      }

      const sessionData = sessionDoc.data();
      if (sessionData?.uid !== uid) {
        throw new functions.https.HttpsError(
          'permission-denied',
          '접근 권한이 없습니다.'
        );
      }

      // 메시지 히스토리 구성
      const messages: ChatMessage[] = [
        { role: 'system', content: RABBIT_SYSTEM_PROMPT },
        ...history.map((m) => ({
          role: m.role as 'user' | 'assistant',
          content: m.content,
        })),
        { role: 'user', content: message },
      ];

      // AI 응답 생성
      const reply = await getChatCompletion(messages, {
        temperature: 0.8,
        maxTokens: 1000,
      });

      // JSON 파싱 시도
      const parsedAction = parseJsonFromResponse(reply);

      // 세션에 메시지 저장
      const now = admin.firestore.Timestamp.now();
      await sessionRef.update({
        messages: admin.firestore.FieldValue.arrayUnion(
          { role: 'user', content: message, timestamp: now },
          { role: 'assistant', content: reply, timestamp: now }
        ),
        ...(parsedAction && { result_json: parsedAction }),
      });

      return {
        reply,
        parsedAction,
      };
    } catch (error) {
      console.error('chatWithRabbit error:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        '메시지 처리 중 오류가 발생했습니다.'
      );
    }
  });
