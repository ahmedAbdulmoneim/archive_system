import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/documents_model.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailsScreen({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(
              title: 'Category',
              value: document.categoryName,
            ),

            _infoCard(
              title: 'From',
              value: document.from,
            ),

            _infoCard(
              title: 'Numbers',
              value: document.number,
            ),

            _infoCard(
              title: 'Date',
              value: document.date != null
                  ? DateFormat.yMMMMd().format(document.date!)
                  : '—',
            ),

            _infoCard(
              title: 'Notes',
              value: document.notes.isNotEmpty
                  ? document.notes
                  : 'No notes',
              multiline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    bool multiline = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: multiline ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
