import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/documents_model.dart';
import '../screens/document_details_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/documents/documents_cubit.dart';

class DocumentsTable extends StatelessWidget {
  final List<DocumentModel> documents;

  const DocumentsTable({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('الصنف')),
          DataColumn(label: Text('الرقم')),
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('صادر من')),
          DataColumn(label: Text('وارد إلى')),
          DataColumn(label: Text('الموضوع')),
          DataColumn(label: Text('الحفظ الورقي')),
        ],
        rows: documents.map((doc) {
          return DataRow(
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DocumentDetailsScreen(document: doc),
                ),
              );
            },
            cells: [
              DataCell(Text(doc.categoryName)),
              DataCell(Text(doc.number)),
              DataCell(Text(doc.date != null
                  ? DateFormat.yMd('ar').format(doc.date!)
                  : '')),
              DataCell(Text(doc.from)),
              DataCell(Text(doc.to)),
              DataCell(Text(doc.subject)),
              DataCell(Text(doc.paperArchive)),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 🔽 Reusable sortable header
  DataColumn _sortableColumn(
    BuildContext context, {
    required String title,
    required String field,
  }) {
    return DataColumn(
      label: InkWell(
        onTap: () {
          context.read<DocumentsCubit>().sortDocuments(field);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(width: 4),
            const Icon(
              Icons.unfold_more,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
