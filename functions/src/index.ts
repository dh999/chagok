import * as admin from 'firebase-admin';

// Firebase Admin 초기화
admin.initializeApp();

// Functions 내보내기
export { chatWithRabbit } from './chat/chatWithRabbit';
export { generateDailyMissions } from './missions/generateDailyMissions';
export { processEndOfDay } from './missions/processEndOfDay';
export { onMissionComplete } from './gamification/onMissionComplete';
