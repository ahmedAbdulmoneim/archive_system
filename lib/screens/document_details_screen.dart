import 'package:flutter/material.dart';
import '../models/documents_model.dart';
import 'package:intl/intl.dart';

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
            _detailItem('الصنف', document.categoryName),
            _detailItem('الرقم', document.number),
            _detailItem(
              'التاريخ',
              document.date == null
                  ? ''
                  : DateFormat.yMd('ar').format(document.date!),
            ),
            _detailItem('صادر من', document.from),
            _detailItem('وارد إلى', document.to),
            _detailItem('الموضوع', document.subject),

            // ⭐ تمت الإضافة هنا
            _detailItem('الحفظ الورقي', document.paperArchive),

            _detailItem('الكلمات الدلالية', document.keywords.join(", ")),
            _detailItem('ملاحظات', document.notes),
            _detailItem('عدد المرفقات', '${document.attachments.length}'),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
