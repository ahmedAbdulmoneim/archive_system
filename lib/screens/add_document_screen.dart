import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/documents/documents_cubit.dart';
import '../models/documents_model.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();
  final _paperArchiveController = TextEditingController();
  final _keywordsController = TextEditingController();

  DateTime? _selectedDate;
  String _categoryName = 'غير مصنف';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة وثيقة'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// CATEGORY
              DropdownButtonFormField<String>(
                value: _categoryName,
                decoration: const InputDecoration(labelText: 'الصنف'),
                items: const [
                  DropdownMenuItem(value: 'غير مصنف', child: Text('غير مصنف')),
                  DropdownMenuItem(value: 'وارد', child: Text('وارد')),
                  DropdownMenuItem(value: 'صادر', child: Text('صادر')),
                ],
                onChanged: (v) => setState(() => _categoryName = v!),
              ),

              const SizedBox(height: 12),

              _textField('رقم الوثيقة', _numberController),
              _datePicker(context),
              _textField('صادر من', _fromController),
              _textField('وارد إلى', _toController),
              _textField('الموضوع', _subjectController),

              _textField(
                'كلمات دلالية (افصل بفاصلة)',
                _keywordsController,
              ),

              _textField(
                'ملاحظات',
                _notesController,
                maxLines: 3,
              ),

              _textField(
                'الحفظ الورقي',
                _paperArchiveController,
              ),

              const SizedBox(height: 24),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الوثيقة'),
                  onPressed: _saveDocument,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _textField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() => _selectedDate = picked);
          }
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'التاريخ',
            border: OutlineInputBorder(),
          ),
          child: Text(
            _selectedDate == null
                ? 'اختر التاريخ'
                : DateFormat.yMd('ar').format(_selectedDate!),
          ),
        ),
      ),
    );
  }

  void _saveDocument() {
    if (!_formKey.currentState!.validate()) return;

    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    context.read<DocumentsCubit>().addDocument(
      DocumentModel(
        id: '',
        categoryName: _categoryName,
        number: _numberController.text,
        date: _selectedDate,
        from: _fromController.text,
        to: _toController.text,
        subject: _subjectController.text,
        keywords: keywords,
        notes: _notesController.text,
        paperArchive: _paperArchiveController.text,
        createdBy: 'admin', // later from auth
      ),
    );

    Navigator.pop(context);
  }
}
