import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersCubit extends Cubit<List<Map<String, dynamic>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UsersCubit() : super([]);

  Future<void> fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    emit(snapshot.docs.map((e) {
      return {
        'id': e.id,
        ...e.data(),
      };
    }).toList());
  }

  Future<void> updateRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
    });
    fetchUsers();
  }

  Future<void> toggleActive(String uid, bool active) async {
    await _firestore.collection('users').doc(uid).update({
      'active': active,
    });
    fetchUsers();
  }
}
