import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/audit_service.dart';

class UsersCubit extends Cubit<List<Map<String, dynamic>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UsersCubit() : super([]);

  // =========================
  // 🔹 Fetch all users
  // =========================
  Future<void> fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();

    emit(
      snapshot.docs.map((e) {
        return {
          'id': e.id,
          ...e.data(),
        };
      }).toList(),
    );
  }

  // =========================
  // 🔹 Update user role
  // =========================
  Future<void> updateRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
    });

    await AuditService.log(
      action: 'change_role',
      entity: 'user',
      entityId: uid,
      description: 'تم تغيير دور المستخدم إلى $role',
    );

    fetchUsers();
  }


  // =========================
  // 🔹 Enable / Disable user
  // =========================
  Future<void> toggleActive({
    required String uid,
    required bool active,
    required String adminUid,
  }) async {
    // ❌ منع الأدمن من تعطيل نفسه
    if (uid == adminUid) return;

    final ref = _firestore.collection('users').doc(uid);

    await ref.update({'active': active});

    await AuditService.log(
      action: active ? 'ENABLE_USER' : 'DISABLE_USER',
      entity: 'user',
      entityId: uid,
      description: active
          ? 'تم تفعيل المستخدم'
          : 'تم تعطيل المستخدم',
      by: adminUid,
    );

    await fetchUsers();
  }
  void reset() {
    emit([]);
  }

  // ====================== create user =============
  Future<void> createUser({ required String email, required String password, required String role, required bool active, }) async { final callable = FirebaseFunctions.instance.httpsCallable('createUser'); await callable.call({ 'email': email, 'password': password, 'role': role, 'active': active, }); await fetchUsers(); }
}
