import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> log({
    required String action,
    required String entity,
    required String description,
    String? entityId,
  }) async {
    final user = _auth.currentUser;

    await _firestore.collection('audit_logs').add({
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'description': description,
      'performedBy': user?.uid,
      'performedByEmail': user?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
