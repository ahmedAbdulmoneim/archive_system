import 'package:cloud_firestore/cloud_firestore.dart';

import 'attachment_model.dart';

class DocumentModel {
  final String id;
  final String categoryName;
  final String number;
  final DateTime? date;
  final String from;
  final String to;
  final String subject;
  final List<String> keywords;
  final String notes;
  final String paperArchive;
  final String createdBy;
  final List<AttachmentModel> attachments;

  DocumentModel({
    required this.id,
    required this.categoryName,
    required this.number,
    required this.date,
    required this.from,
    required this.to,
    required this.subject,
    required this.keywords,
    required this.notes,
    required this.paperArchive,
    required this.createdBy,
    this.attachments = const [],
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      categoryName: map['categoryName'] ?? 'غير مصنف',
      number: map['number'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate(),
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      subject: map['subject'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      notes: map['notes'] ?? '',
      paperArchive: map['paperArchive'] ?? '',
      createdBy: map['createdBy'] ?? '',
      attachments: (map['attachments'] as List<dynamic>? ?? [])
          .map((e) => AttachmentModel.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'number': number,
      'date': date,
      'from': from,
      'to': to,
      'subject': subject,
      'keywords': keywords,
      'notes': notes,
      'paperArchive': paperArchive,
      'createdBy': createdBy,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };
  }
}
