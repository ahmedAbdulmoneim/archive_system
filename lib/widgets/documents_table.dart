import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/documents/documents_cubit.dart';
import '../bloc/documents/documents_state.dart';
import '../models/documents_model.dart';
import '../screens/add_document_screen.dart';

class DocumentsTable extends StatelessWidget {
  final List<DocumentModel> documents;

  const DocumentsTable({
    super.key,
    required this.documents,
  });


  String safe(String? v) => v == null || v.isEmpty ? '' : v;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DocumentsCubit>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor:
        MaterialStateProperty.all(Colors.grey.shade200),

        // ================= HEADER =================
        columns: [
          DataColumn(
            label: BlocBuilder<DocumentsCubit, DocumentsState>(
              builder: (context, state) {
                final allSelected =
                    cubit.selectedCount == documents.length &&
                        documents.isNotEmpty;

                return Checkbox(
                  value: allSelected,
                  onChanged: (v) {
                    cubit.toggleSelectAll(v ?? false);
                  },
                );
              },
            ),
          ),
          const DataColumn(label: Text('الصنف')),
          const DataColumn(label: Text('الرقم')),
          const DataColumn(label: Text('التاريخ')),
          const DataColumn(label: Text('صادر من')),
          const DataColumn(label: Text('وارد إلى')),
          const DataColumn(label: Text('الموضوع')),
          const DataColumn(label: Text('كلمات دلالية')),
          const DataColumn(label: Text('ملاحظات')),
          const DataColumn(label: Text('مرفقات')),
        ],

        // ================= ROWS =================
        rows: documents.map((doc) {
          final isSelected = cubit.isSelected(doc.id);

          return DataRow(
            selected: isSelected,
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: cubit,
                    child: AddDocumentScreen(document: doc),
                  ),
                ),
              );
            },
            cells: [
              // ✅ SINGLE CHECKBOX
              DataCell(
                Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    cubit.toggleSelection(doc.id);
                  },
                ),
              ),

              DataCell(Text(safe(doc.categoryName))),
              DataCell(Text(safe(doc.number))),
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
              DataCell(
                Text(
                  doc.keywords.isEmpty
                      ? ''
                      : doc.keywords.join(', '),
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
