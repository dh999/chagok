import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * 매일 23:59(KST)에 실행되는 하루 마감 처리 함수
 * - 미완료 미션을 FAILED로 변경
 * - Streak 리셋 (필요시)
 */
export const processEndOfDay = functions
  .region('asia-northeast3')
  .pubsub.schedule('59 23 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting end of day processing...');

    try {
      const today = getToday();
      const tomorrow = getTomorrow();

      // 오늘의 미완료 미션 조회
      const pendingMissionsSnapshot = await db
        .collection('missions')
        .where('date', '>=', admin.firestore.Timestamp.fromDate(today))
        .where('date', '<', admin.firestore.Timestamp.fromDate(tomorrow))
        .where('status', '==', 'PENDING')
        .get();

      console.log(`Found ${pendingMissionsSnapshot.size} pending missions to process`);

      // 사용자별로 그룹화
      const userMissions = new Map<string, string[]>();

      pendingMissionsSnapshot.docs.forEach((doc) => {
        const uid = doc.data().uid;
        if (!userMissions.has(uid)) {
          userMissions.set(uid, []);
        }
        userMissions.get(uid)!.push(doc.id);
      });

      const batch = db.batch();

      // 미완료 미션 FAILED로 변경
      for (const doc of pendingMissionsSnapshot.docs) {
        batch.update(doc.ref, {
          status: 'FAILED',
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // 미완료 미션이 있는 사용자의 streak 리셋
      for (const [uid, missionIds] of userMissions) {
        try {
          // 오늘 완료된 미션이 하나도 없는지 확인
          const completedToday = await db
            .collection('missions')
            .where('uid', '==', uid)
            .where('date', '>=', admin.firestore.Timestamp.fromDate(today))
            .where('date', '<', admin.firestore.Timestamp.fromDate(tomorrow))
            .where('is_completed', '==', true)
            .get();

          if (completedToday.empty) {
            // 완료된 미션이 하나도 없으면 streak 리셋
            await db.collection('users').doc(uid).update({
              total_streak: 0,
              monthly_streak: 0,
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Reset streak for user ${uid}`);
          }
        } catch (error) {
          console.error(`Error resetting streak for user ${uid}:`, error);
        }
      }

      console.log('End of day processing complete');

      return {
        processedMissions: pendingMissionsSnapshot.size,
        affectedUsers: userMissions.size,
      };
    } catch (error) {
      console.error('processEndOfDay error:', error);
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
