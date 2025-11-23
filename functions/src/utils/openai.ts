import OpenAI from 'openai';
import * as functions from 'firebase-functions';

// OpenAI 클라이언트 초기화
const openai = new OpenAI({
  apiKey: functions.config().openai?.key || process.env.OPENAI_API_KEY,
});

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export async function getChatCompletion(
  messages: ChatMessage[],
  options?: {
    temperature?: number;
    maxTokens?: number;
  }
): Promise<string> {
  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: messages,
      temperature: options?.temperature ?? 0.7,
      max_tokens: options?.maxTokens ?? 1000,
    });

    return completion.choices[0]?.message?.content || '';
  } catch (error) {
    console.error('OpenAI API error:', error);
    throw new Error('AI 응답 생성에 실패했습니다.');
  }
}

export function parseJsonFromResponse(response: string): any | null {
  try {
    // JSON 블록 찾기
    const jsonMatch = response.match(/\{[\s\S]*"action"[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }

    // 전체 응답이 JSON인지 확인
    if (response.trim().startsWith('{')) {
      return JSON.parse(response);
    }

    return null;
  } catch {
    return null;
  }
}
