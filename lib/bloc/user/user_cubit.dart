import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/audit_service.dart';

class UsersCubit extends Cubit<List<Map<String, dynamic>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UsersCubit() : super([]);

  // 🔹 Fetch all users
  Future<void> fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();

    emit(snapshot.docs.map((e) {
      return {
        'id': e.id,
        ...e.data(),
      };
    }).toList());
  }

  // 🔹 Update user role (admin / user)
  Future<void> updateRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
    });

    // ✅ Audit log
    await AuditService.log(
      action: 'change_role',
      entity: 'user',
      entityId: uid,
      description: 'تم تغيير دور المستخدم إلى $role',
    );

    fetchUsers();
  }

  // 🔹 Enable / Disable user
  Future<void> toggleActive(String uid, bool active) async {
    await _firestore.collection('users').doc(uid).update({
      'active': active,
    });

    // ✅ Audit log
    await AuditService.log(
      action: 'toggle_active',
      entity: 'user',
      entityId: uid,
      description:
      active ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم',
    );

    fetchUsers();
  }
}
