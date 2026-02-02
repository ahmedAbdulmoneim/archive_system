import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/documents/documents_cubit.dart';
import '../models/documents_model.dart';
import '../screens/add_document_screen.dart';

class DocumentsTable extends StatelessWidget {
  final List<DocumentModel> documents;
  final DocumentsCubit cubit;
  String safe(String? v) => v == null || v.isEmpty ? '' : v;

  const DocumentsTable({
    super.key,
    required this.documents,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor:
        MaterialStateProperty.all(Colors.grey.shade200),

        columns: const [
          DataColumn(label: Text('✔')),
          DataColumn(label: Text('الصنف')),
          DataColumn(label: Text('الرقم')),
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('صادر من')),
          DataColumn(label: Text('وارد إلى')),
          DataColumn(label: Text('الموضوع')),
          DataColumn(label: Text('كلمات دلالية')),
          DataColumn(label: Text('ملاحظات')),
          DataColumn(label: Text('مرفقات')),
        ],

        rows: documents.map((doc) {
          return DataRow(
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: AddDocumentScreen(document: doc),
                  ),
                ),
              );
            },

            cells: [
              DataCell(Checkbox(value: false, onChanged: (_) {})),
              DataCell(Text(doc.categoryName)),
              DataCell(Text(doc.number)),
              DataCell(
                Text(
                  doc.date == null
                      ? ''
                      : DateFormat.yMd('ar').format(doc.date!),
                ),
              ),
              DataCell(Text(safe(doc.from))),

              DataCell(Text(safe(doc.to))),

              DataCell(Text(safe(doc.subject))),
              DataCell(Text(
                  doc.keywords.isEmpty ? '' : doc.keywords.join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              ),


              DataCell(
                Text(
                  safe(doc.notes),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16),
                    const SizedBox(width: 4),
                    Text('${doc.attachments.length}'),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
