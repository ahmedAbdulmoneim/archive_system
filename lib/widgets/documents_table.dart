import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/documents/documents_cubit.dart';
import '../core/permissions.dart';
import '../models/documents_model.dart';
import '../screens/add_document_screen.dart';

class DocumentsTable extends StatefulWidget {
  final List<DocumentModel> documents;

  const DocumentsTable({
    super.key,
    required this.documents,
  });

  @override
  State<DocumentsTable> createState() => _DocumentsTableState();
}

class _DocumentsTableState extends State<DocumentsTable> {
  String safe(String? v) => v == null || v.isEmpty ? '' : v;
  int? sortColumnIndex;
  bool isAscending = true;

  void onSort<T>(
      Comparable<T> Function(DocumentModel d) getField, int columnIndex) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = !isAscending;

      widget.documents.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return isAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  // ============================================================
  void showDocumentDetailsSheet(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'تفاصيل المستند',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _detailItem('الصنف', doc.categoryName),
              _detailItem('الرقم', doc.number),
              _detailItem('التاريخ', doc.date?.toString()),
              _detailItem('صادر من', doc.from),
              _detailItem('وارد إلى', doc.to),
              _detailItem('الموضوع', doc.subject),
              _detailItem('الكلمات الدلالية', doc.keywords.join(', ')),
              _detailItem('ملاحظات', doc.notes),
              _detailItem('عدد المرفقات', '${doc.attachments.length}'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value ?? '')),
        ],
      ),
    );
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DocumentsCubit>();
    final authState = context.read<AuthCubit>().state;
    final isAdmin = Permissions.isAdmin(authState);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        sortColumnIndex: sortColumnIndex,
        sortAscending: isAscending,

        // 🎨 Header styling (Dark Mode Safe)
        headingRowColor: WidgetStateProperty.all(
          theme.colorScheme.surfaceVariant,
        ),
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),

        // Borders
        dividerThickness: 1,
        border: TableBorder.all(
          color: theme.dividerColor,
          width: 0.8,
        ),

        // ================= HEADER =================
        columns: [
          DataColumn(
            label: isAdmin
                ? Checkbox(
                    value: cubit.selectedCount == widget.documents.length &&
                        widget.documents.isNotEmpty,
                    onChanged: (v) {
                      cubit.toggleSelectAll(v ?? false);
                    },
                  )
                : const SizedBox(),
          ),
          const DataColumn(label: Text('الصنف')),
          DataColumn(
            label: const Text('الرقم'),
            onSort: (columnIndex, _) {
              onSort((d) => d.number ?? "", columnIndex);
            },
          ),

          DataColumn(
            label: const Text('التاريخ'),
            onSort: (columnIndex, _) {
              onSort((d) => d.date ?? DateTime(1900), columnIndex);
            },
          ),

          const DataColumn(label: Text('صادر من')),
          const DataColumn(label: Text('وارد إلى')),
          const DataColumn(label: Text('الموضوع')),
          const DataColumn(label: Text('كلمات دلالية')),
          const DataColumn(label: Text('ملاحظات')),
          const DataColumn(label: Text('مرفقات')),
          const DataColumn(label: Text('عرض')), // زر التفاصيل
        ],

        // ================= ROWS =================
        rows: widget.documents.map((doc) {
          final isSelected = cubit.isSelected(doc.id);
          final index = widget.documents.indexOf(doc);

          return DataRow(
            selected: isSelected,

            // Zebra + Hover + Selected
            color: MaterialStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.colorScheme.primary.withOpacity(0.12);
                }
                if (states.contains(MaterialState.hovered)) {
                  return theme.colorScheme.primary.withOpacity(0.06);
                }
                return index.isEven
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surfaceVariant.withOpacity(0.4);
              },
            ),

            // الضغط على الصف
            onSelectChanged: (_) {
              if (isAdmin) {
                // فتح شاشة التعديل
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: AddDocumentScreen(document: doc),
                    ),
                  ),
                );
              } else {
                // فتح التفاصيل فقط
                showDocumentDetailsSheet(context, doc);
              }
            },

            cells: [
              // Checkbox للأدمن فقط
              DataCell(
                isAdmin
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => cubit.toggleSelection(doc.id),
                      )
                    : const SizedBox(),
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
                  doc.keywords.join(', '),
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

              // زر عرض التفاصيل
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'عرض التفاصيل',
                  onPressed: () {
                    showDocumentDetailsSheet(context, doc);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
