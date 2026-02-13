import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/types_cubit/types_cubit.dart';

class AdvancedSearchDialog extends StatefulWidget {
  const AdvancedSearchDialog({super.key});

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  final number = TextEditingController();
  final fromField = TextEditingController();
  final toField = TextEditingController();
  final subject = TextEditingController();
  final keywords = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  String? category;
  String? paper;

  @override
  Widget build(BuildContext context) {
    final types = context.read<TypesCubit>();

    return AlertDialog(
      title: const Text('بحث متقدم'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _dropdown(
              label: 'الصنف',
              items: types.categories,
              onChanged: (v) => category = v,
            ),

            _field('الرقم', number),

            _date('من تاريخ', fromDate, (d) => setState(() => fromDate = d)),
            _date('إلى تاريخ', toDate, (d) => setState(() => toDate = d)),

            _field('صادر من', fromField),
            _field('وارد إلى', toField),
            _field('الموضوع', subject),
            _field('كلمات دلالية', keywords),

            _dropdown(
              label: 'الضبارة الورقية',
              items: types.paperTypes,
              onChanged: (v) => paper = v,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('بحث'),
          onPressed: () {
            context.read<DocumentsCubit>().searchAdvanced(
              text: number.text,
              from: fromDate,
              to: toDate,
              category: category,
              paper: paper,
              fromField: fromField.text,
              toField: toField.text,
              subject: subject.text,
              keywords: keywords.text,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _date(String label, DateTime? value, Function(DateTime) onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (d != null) onPick(d);
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value == null ? label : '$label: ${value.toLocal()}'),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
            value: e['name'] as String,
            child: Text(e['name'] as String),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

