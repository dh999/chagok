import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * 미션 완료 시 트리거되는 함수
 * - 블록 추가
 * - EXP 추가
 * - Streak 업데이트
 * - 보상 해금 체크
 */
export const onMissionComplete = functions
  .region('asia-northeast3')
  .firestore.document('missions/{missionId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // 미션이 방금 완료된 경우만 처리
    if (before.is_completed || !after.is_completed) {
      return null;
    }

    const uid = after.uid;
    const blockValue = after.block_value || 1;

    console.log(`Mission completed for user ${uid}, block_value: ${blockValue}`);

    try {
      await db.runTransaction(async (transaction) => {
        const userRef = db.collection('users').doc(uid);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          console.error(`User ${uid} not found`);
          return;
        }

        const user = userDoc.data()!;

        // 1. 블록 추가
        let blocksToAdd = blockValue;

        // 2. EXP 계산
        let expToAdd = 10; // 기본 EXP

        // 3. 오늘 모든 미션 완료 여부 확인
        const today = getToday();
        const tomorrow = getTomorrow();

        const todayMissionsSnapshot = await db
          .collection('missions')
          .where('uid', '==', uid)
          .where('date', '>=', admin.firestore.Timestamp.fromDate(today))
          .where('date', '<', admin.firestore.Timestamp.fromDate(tomorrow))
          .get();

        const allCompleted = todayMissionsSnapshot.docs.every(
          (doc) => doc.data().is_completed
        );

        if (allCompleted && todayMissionsSnapshot.size > 1) {
          // 올클리어 보너스
          blocksToAdd += 1;
          expToAdd += 30;
          console.log(`User ${uid} completed all missions today! Bonus applied.`);
        }

        // 4. Streak 계산
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);

        const yesterdayMissions = await db
          .collection('missions')
          .where('uid', '==', uid)
          .where('date', '>=', admin.firestore.Timestamp.fromDate(yesterday))
          .where('date', '<', admin.firestore.Timestamp.fromDate(today))
          .where('is_completed', '==', true)
          .get();

        const hadCompletedYesterday = !yesterdayMissions.empty;

        let newTotalStreak = hadCompletedYesterday ? (user.total_streak || 0) + 1 : 1;
        let newMonthlyStreak = hadCompletedYesterday ? (user.monthly_streak || 0) + 1 : 1;

        // 월이 바뀌었으면 월간 스트릭 리셋
        const lastLogin = user.last_login_at?.toDate();
        if (lastLogin && lastLogin.getMonth() !== today.getMonth()) {
          newMonthlyStreak = 1;
        }

        // Streak 보너스 EXP
        if (newTotalStreak === 7) {
          expToAdd += 50;
          console.log(`User ${uid} reached 7-day streak!`);
        } else if (newTotalStreak === 30) {
          expToAdd += 200;
          console.log(`User ${uid} reached 30-day streak!`);
        }

        // 5. 레벨업 계산
        let newExp = (user.rabbit_exp || 0) + expToAdd;
        let newLevel = user.rabbit_level || 1;

        const levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
        while (newLevel < 10 && newExp >= levelThresholds[newLevel]) {
          newExp -= levelThresholds[newLevel];
          newLevel++;
          console.log(`User ${uid} leveled up to ${newLevel}!`);
        }

        // 6. 보상 해금 체크
        const currentBlocks = (user.current_blocks || 0) + blocksToAdd;
        const unlockedItems = user.unlocked_items || [];
        const newUnlocks: string[] = [];

        // Streak 기반 보상
        if (newTotalStreak >= 7 && !unlockedItems.includes('item_flower_pot')) {
          newUnlocks.push('item_flower_pot');
        }
        if (newTotalStreak >= 14 && !unlockedItems.includes('item_fence')) {
          newUnlocks.push('item_fence');
        }
        if (newTotalStreak >= 30 && !unlockedItems.includes('item_bicycle')) {
          newUnlocks.push('item_bicycle');
        }
        if (newTotalStreak >= 60 && !unlockedItems.includes('item_garden')) {
          newUnlocks.push('item_garden');
        }
        if (newTotalStreak >= 100 && !unlockedItems.includes('item_second_floor')) {
          newUnlocks.push('item_second_floor');
        }

        if (newUnlocks.length > 0) {
          console.log(`User ${uid} unlocked: ${newUnlocks.join(', ')}`);
        }

        // 7. 사용자 정보 업데이트
        transaction.update(userRef, {
          current_blocks: currentBlocks,
          rabbit_exp: newExp,
          rabbit_level: newLevel,
          total_streak: newTotalStreak,
          monthly_streak: newMonthlyStreak,
          longest_streak: Math.max(user.longest_streak || 0, newTotalStreak),
          unlocked_items: [...unlockedItems, ...newUnlocks],
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      console.log(`Successfully processed mission completion for user ${uid}`);
      return null;
    } catch (error) {
      console.error('onMissionComplete error:', error);
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
