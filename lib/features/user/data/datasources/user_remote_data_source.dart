import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/api/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/models/facility_model.dart';

/// Reads and writes the profile in Firestore and registers patients with the API.
class UserRemoteDataSource {
  UserRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required APIClient apiClient,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth,
        _api = apiClient,
        _firestoreOverride = firestore;

  final FirebaseAuth _auth;
  final APIClient _api;
  final FirebaseFirestore? _firestoreOverride;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      (_firestoreOverride ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(uid);

  /// The stored profile, or null if the user has none yet.
  Future<UserEntity?> getUserProfile(String uid) async {
    final data = (await _doc(uid).get()).data();
    if (data == null) return null;
    return UserEntity.fromJson({
      ...data,
      'id': uid,
      'email': data['email'] ?? _auth.currentUser?.email ?? '',
    });
  }

  /// Merges [data] into the stored profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) =>
      _doc(uid).set(data, SetOptions(merge: true));

  /// Registers [profile] as a patient of [facilityId].
  Future<void> onboardUser(UserEntity profile, String facilityId) =>
      _api.post('/api/v1/auth/onboard', data: {
        'firstname': profile.firstName ?? '',
        'lastname': profile.lastName ?? '',
        'gender': profile.gender?.toLowerCase() ?? 'prefer_not_to_say',
        'dateOfBirth':
            (profile.dateOfBirth ?? clock.now()).toUtc().toIso8601String(),
        'age': profile.age ?? 0,
        'chronicConditions':
            profile.conditions.map((c) => c.toLowerCase()).toList(),
        'facilityId': facilityId,
        'phoneNumber': profile.phoneNumber ?? '',
      });

  /// Updates the name and gender the clinic sees on the patient record.
  Future<void> updatePatient(Map<String, dynamic> body) =>
      _api.patch('/api/v1/client/patient', data: body);

  /// Up to 20 facilities whose name matches [search].
  Future<List<FacilityModel>> searchFacilities(String search) async {
    final response = await _api.get('/api/v1/client/facilities',
        queryParameters: {'page': 1, 'pageSize': 20, 'search': search});
    final data = response is Map<String, dynamic> ? response['data'] : null;
    return data == null ? const [] : FacilityListResponse.fromJson(data).rows;
  }
}
