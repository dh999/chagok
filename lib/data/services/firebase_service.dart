import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_collections.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  // Collections
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get missionsCollection =>
      _firestore.collection(FirestoreCollections.missions);

  CollectionReference<Map<String, dynamic>> get chatSessionsCollection =>
      _firestore.collection(FirestoreCollections.chatSessions);

  CollectionReference<Map<String, dynamic>> get rewardsCollection =>
      _firestore.collection(FirestoreCollections.rewards);

  // Current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User document reference
  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersCollection.doc(uid);

  // Missions query for user
  Query<Map<String, dynamic>> missionsForUser(String uid) =>
      missionsCollection.where('uid', isEqualTo: uid);

  // Missions for specific date
  Query<Map<String, dynamic>> missionsForDate(String uid, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return missionsCollection
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay));
  }

  // Chat sessions for user
  Query<Map<String, dynamic>> chatSessionsForUser(String uid) =>
      chatSessionsCollection.where('uid', isEqualTo: uid);
}
