import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/documents_model.dart';
import '../models/attachment_model.dart';

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

            const SizedBox(height: 24),

            // ================= ATTACHMENTS =================
            const Text(
              'Attachments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            _attachmentsList(document.attachments),
          ],
        ),
      ),
    );
  }

  // ================= INFO CARD =================
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

  // ================= ATTACHMENTS LIST =================
  Widget _attachmentsList(List<AttachmentModel> attachments) {
    if (attachments.isEmpty) {
      return const Text(
        'No attachments',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final att = attachments[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _attachmentIcon(att.type),
            title: Text(att.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(att.type),
          ),
        );
      },
    );
  }

  // ================= ICON BY TYPE =================
  Widget _attachmentIcon(String type) {
    final t = type.toLowerCase();

    if (t.contains('pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    }
    if (t.contains('jpg') || t.contains('png') || t.contains('jpeg')) {
      return const Icon(Icons.image, color: Colors.blue);
    }
    if (t.contains('doc')) {
      return const Icon(Icons.description, color: Colors.indigo);
    }

    return const Icon(Icons.attach_file);
  }
}
