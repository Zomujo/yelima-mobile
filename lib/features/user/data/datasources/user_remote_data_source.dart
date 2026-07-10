import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/api/api_client.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final APIClient _apiClient;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required APIClient apiClient,
  })  : _firebaseAuth = firebaseAuth,
        _apiClient = apiClient;

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    data['email'] = data['email'] ?? _firebaseAuth.currentUser?.email ?? '';

    return UserModel.fromJson(data);
  }

  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<void> onboardUser(Map<String, dynamic> data) async {
    await _apiClient.post("/api/v1/auth/onboard", data: data);
  }
}
