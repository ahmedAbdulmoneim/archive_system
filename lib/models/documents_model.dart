
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

  DocumentModel({
    required this.id,
    required this.categoryName,
    required this.number,
    this.date,
    required this.from,
    required this.to,
    required this.subject,
    required this.keywords,
    required this.notes,
    required this.paperArchive,
    required this.createdBy,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      categoryName: map['categoryName'] ?? '',
      number: map['number'] ?? '',
      date: map['date']?.toDate(),
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      subject: map['subject'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      notes: map['notes'] ?? '',
      paperArchive: map['paperArchive'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}
