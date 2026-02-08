import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/documents/documents_state.dart';
import '../core/permissions.dart';
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
    final authState = context.read<AuthCubit>().state;
    final isAdmin = Permissions.isAdmin(authState);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,

        // =========================
        // 🎨 HEADER STYLE (DARK SAFE)
        // =========================
        headingRowColor: MaterialStateProperty.all(
          theme.colorScheme.surfaceVariant,
        ),
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),

        // =========================
        // 📏 BORDERS & DIVIDERS
        // =========================
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
              value: cubit.selectedCount == documents.length && documents.isNotEmpty,
              onChanged: (v) {
                cubit.toggleSelectAll(v ?? false);
              },
            )
                : const SizedBox(), // hide for normal users
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
              color: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return theme.colorScheme.primary.withOpacity(0.06);
            }
            final index = documents.indexOf(doc);
            return index.isEven
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceVariant.withOpacity(0.4);
          },
          ),
            onSelectChanged: isAdmin
                ? (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: AddDocumentScreen(document: doc),
                  ),
                ),
              );
            }
                : null,
            cells: [
              // ✅ CHECKBOX (IMPROVED)
              DataCell(
                isAdmin
                    ? Checkbox(
                  value: cubit.isSelected(doc.id),
                  onChanged: (_) => cubit.toggleSelection(doc.id),
                )
                    : const SizedBox(), // hide for normal users
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
                Tooltip(
                  message: 'عدد المرفقات: ${doc.attachments.length}',
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text('${doc.attachments.length}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
