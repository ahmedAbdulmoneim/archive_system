import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> log({
    required String action,
    required String entity,
    String? entityId,
    String? description,
    String? by, // 👈 اختياري
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await _firestore.collection('audit_logs').add({
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'description': description,
      'by': by ?? currentUser?.uid, // 👈 fallback ذكي
      'email': currentUser?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
