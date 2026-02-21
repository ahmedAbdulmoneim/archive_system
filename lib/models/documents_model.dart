import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment_model.dart';

class DocumentModel {
  final String id;

  final String? categoryName;
  final String? number;
  final DateTime? date;
  final String? from;
  final String? to;
  final String? subject;
  final List<String>? keywords;
  final String? notes;
  final String? paperArchive;

  // 🆕 الجديد
  final String? createdBy;   // email
  final String? branchId;
  final String? branchName;

  final List<AttachmentModel>? attachments;

  DocumentModel({
    required this.id,
    this.categoryName,
    this.number,
    this.date,
    this.from,
    this.to,
    this.subject,
    this.keywords,
    this.notes,
    this.paperArchive,
    this.createdBy,
    this.branchId,
    this.branchName,
    this.attachments,
  });

  // ================= FROM FIRESTORE =================
  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      categoryName: map['categoryName'],
      number: map['number'],
      date: (map['date'] as Timestamp?)?.toDate(),
      from: map['from'],
      to: map['to'],
      subject: map['subject'],
      keywords: map['keywords'] != null
          ? List<String>.from(map['keywords'])
          : null,
      notes: map['notes'],
      paperArchive: map['paperArchive'],
      createdBy: map['createdBy'],
      branchId: map['branchId'],
      branchName: map['branchName'],
      attachments: (map['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentModel.fromMap(e))
          .toList(),
    );
  }

  // ================= TO FIRESTORE =================
  Map<String, dynamic> toMap() {
    return {
      if (categoryName != null) 'categoryName': categoryName,
      if (number != null) 'number': number,
      if (date != null) 'date': date,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (subject != null) 'subject': subject,
      if (keywords != null) 'keywords': keywords,
      if (notes != null) 'notes': notes,
      if (paperArchive != null) 'paperArchive': paperArchive,

      // 🆕
      'createdBy': createdBy,
     'branchId': branchId,
      'branchName': branchName,

      if (attachments != null)
        'attachments': attachments!.map((a) => a.toMap()).toList(),

      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };
  }

  // ================= COPY WITH =================
  DocumentModel copyWith({
    String? id,
    String? categoryName,
    String? number,
    DateTime? date,
    String? from,
    String? to,
    String? subject,
    List<String>? keywords,
    String? notes,
    String? paperArchive,
    String? createdBy,
    String? branchId,
    String? branchName,
    List<AttachmentModel>? attachments,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      number: number ?? this.number,
      date: date ?? this.date,
      from: from ?? this.from,
      to: to ?? this.to,
      subject: subject ?? this.subject,
      keywords: keywords ?? this.keywords,
      notes: notes ?? this.notes,
      paperArchive: paperArchive ?? this.paperArchive,
      createdBy: createdBy ?? this.createdBy,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      attachments: attachments ?? this.attachments,
    );
  }
}
