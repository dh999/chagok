import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { getChatCompletion, parseJsonFromResponse } from '../utils/openai';
import { getDailyMissionPrompt } from '../utils/prompts';

const db = admin.firestore();

/**
 * 매일 자정(KST)에 실행되는 미션 생성 함수
 */
export const generateDailyMissions = functions
  .region('asia-northeast3')
  .pubsub.schedule('0 0 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting daily mission generation...');

    try {
      // 온보딩 완료된 모든 사용자 조회
      const usersSnapshot = await db
        .collection('users')
        .where('onboarding_completed', '==', true)
        .get();

      console.log(`Found ${usersSnapshot.size} users to generate missions for`);

      const batch = db.batch();
      const today = getToday();
      let successCount = 0;
      let errorCount = 0;

      for (const userDoc of usersSnapshot.docs) {
        try {
          const user = userDoc.data();
          const uid = userDoc.id;

          // 오늘 미션이 이미 있는지 확인
          const existingMissions = await db
            .collection('missions')
            .where('uid', '==', uid)
            .where('date', '>=', admin.firestore.Timestamp.fromDate(today))
            .where('date', '<', admin.firestore.Timestamp.fromDate(getTomorrow()))
            .get();

          if (!existingMissions.empty) {
            console.log(`User ${uid} already has missions for today, skipping`);
            continue;
          }

          // 어제 미션 완료 여부 확인
          const yesterday = new Date(today);
          yesterday.setDate(yesterday.getDate() - 1);

          const yesterdayMissions = await db
            .collection('missions')
            .where('uid', '==', uid)
            .where('date', '>=', admin.firestore.Timestamp.fromDate(yesterday))
            .where('date', '<', admin.firestore.Timestamp.fromDate(today))
            .get();

          const yesterdayCompleted =
            !yesterdayMissions.empty &&
            yesterdayMissions.docs.every((doc) => doc.data().is_completed);

          // 최근 7일 완료율 계산
          const weekAgo = new Date(today);
          weekAgo.setDate(weekAgo.getDate() - 7);

          const weekMissions = await db
            .collection('missions')
            .where('uid', '==', uid)
            .where('date', '>=', admin.firestore.Timestamp.fromDate(weekAgo))
            .get();

          const weeklyRate =
            weekMissions.size > 0
              ? (weekMissions.docs.filter((doc) => doc.data().is_completed).length /
                  weekMissions.size) *
                100
              : 0;

          // AI로 미션 생성
          const targetDate = user.target_date?.toDate() || new Date();
          const daysRemaining = Math.max(
            1,
            Math.ceil(
              (targetDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24)
            )
          );

          const prompt = getDailyMissionPrompt({
            finalGoal: user.final_goal || '목표 달성',
            goalCategory: user.goal_category || 'STUDY',
            daysRemaining,
            yesterdayCompleted,
            currentStreak: user.total_streak || 0,
            weeklyRate,
          });

          const response = await getChatCompletion(
            [
              { role: 'system', content: prompt },
              { role: 'user', content: '오늘의 미션을 생성해주세요.' },
            ],
            { temperature: 0.7 }
          );

          const parsed = parseJsonFromResponse(response);
          const dailyMissions = parsed?.daily_missions || [];

          if (dailyMissions.length === 0) {
            // 기본 미션 생성
            dailyMissions.push(
              { content: '목표 관련 글 읽기 (10분)', type: 'STUDY', difficulty: 'EASY' },
              { content: '오늘 할 일 정리하기', type: 'TASK', difficulty: 'EASY' }
            );
          }

          // 미션 저장
          for (const mission of dailyMissions) {
            const missionRef = db.collection('missions').doc();
            batch.set(missionRef, {
              uid,
              date: admin.firestore.Timestamp.fromDate(today),
              content: mission.content,
              type: mission.type || 'TASK',
              difficulty: mission.difficulty || 'EASY',
              block_value: getBlockValue(mission.difficulty),
              status: 'PENDING',
              is_completed: false,
              generated_by: 'AI',
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
          }

          successCount++;
        } catch (userError) {
          console.error(`Error generating missions for user ${userDoc.id}:`, userError);
          errorCount++;
        }
      }

      await batch.commit();

      console.log(
        `Daily mission generation complete. Success: ${successCount}, Errors: ${errorCount}`
      );

      return { success: successCount, errors: errorCount };
    } catch (error) {
      console.error('generateDailyMissions error:', error);
      throw error;
    }
  });

function getToday(): Date {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function getTomorrow(): Date {
  const today = getToday();
  today.setDate(today.getDate() + 1);
  return today;
}

function getBlockValue(difficulty?: string): number {
  switch (difficulty) {
    case 'HARD':
      return 3;
    case 'MEDIUM':
      return 2;
    case 'EASY':
    default:
      return 1;
  }
}
