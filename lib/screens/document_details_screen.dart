import 'package:flutter/material.dart';
import '../models/documents_model.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailsScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المستند')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('الصنف: ${document.categoryName}'),
            Text('الرقم: ${document.number}'),
            Text('التاريخ: ${document.date}'),
            Text('صادر من: ${document.from}'),
            Text('وارد إلى: ${document.to}'),
            Text('الموضوع: ${document.subject}'),
            Text('الكلمات الدلالية: ${document.keywords.join(", ")}'),
            Text('ملاحظات: ${document.notes}'),
            Text('عدد المرفقات: ${document.attachments.length}'),
          ],
        ),
      ),
    );
  }
}
