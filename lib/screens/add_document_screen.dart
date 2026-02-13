import 'package:archive_system/bloc/documents/documents_state.dart';
import 'package:archive_system/models/attachment_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/documents/documents_cubit.dart';
import '../bloc/types_cubit/types_cubit.dart';
import '../models/documents_model.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentModel? document;

  const AddDocumentScreen({
    super.key,
    this.document,
  });

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
  String _categoryName = '';
  final List<AttachmentModel> _attachments = [];

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );

    if (result == null) return;

    for (final file in result.files) {
      _attachments.add(
        AttachmentModel(
          name: file.name,
          type: file.extension ?? 'file',
          localPath: file.path,
        ),
      );
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (widget.document != null) {
      final doc = widget.document!;

      _numberController.text = doc.number;
      _fromController.text = doc.from;
      _toController.text = doc.to;
      _subjectController.text = doc.subject;
      _notesController.text = doc.notes;
      _paperArchiveController.text = doc.paperArchive;
      _keywordsController.text = doc.keywords.join(', ');
      _selectedDate = doc.date;

      _categoryName = doc.categoryName;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _subjectController.dispose();
    _notesController.dispose();
    _paperArchiveController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مستند')),

      body: BlocBuilder<TypesCubit, TypesState>(
        builder: (context, state) {
          if (state is TypesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final typesCubit = context.read<TypesCubit>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ---------------- الصنف ----------------
                  DropdownButtonFormField<String>(
                    value: typesCubit.categories.any((item) => item["name"] == _categoryName)
                        ? _categoryName
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'الصنف',
                      border: OutlineInputBorder(),
                    ),
                    items: typesCubit.categories
                        .map(
                          (item) => DropdownMenuItem<String>(
                        value: item["name"] as String,
                        child: Text(item["name"] as String),
                      ),
                    )
                        .toList(),

                    onChanged: (v) => setState(() => _categoryName = v!),
                    validator: (v) => v == null ? 'اختر الصنف' : null,
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

                  // ---------------- الحفظ الورقي ----------------
                  DropdownButtonFormField<String>(
                    value: typesCubit.paperTypes.any(
                            (item) => item["name"] == _paperArchiveController.text)
                        ? _paperArchiveController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'نوع الحفظ الورقي',
                      border: OutlineInputBorder(),
                    ),
                    items: typesCubit.paperTypes
                        .map(
                          (item) => DropdownMenuItem<String>(
                        value: item["name"] as String,
                        child: Text(item["name"] as String),
                      ),
                    )
                        .toList(),

                    onChanged: (v) {
                      setState(() {
                        _paperArchiveController.text = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _attachmentsList(),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('إضافة مرفق'),
                      onPressed: _pickAttachment,
                    ),
                  ),

                  const SizedBox(height: 24),

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
          );
        },
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {int maxLines = 1}) {
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
            initialDate: _selectedDate ?? DateTime.now(),
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

  Widget _attachmentsList() {
    if (_attachments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(
          'لا توجد مرفقات',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        final att = _attachments[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _attachmentIcon(att.type),
            title: Text(att.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(att.type),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  _attachments.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _saveDocument() {
    if (!_formKey.currentState!.validate()) return;

    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final doc = DocumentModel(
      id: widget.document?.id ?? '',
      categoryName: _categoryName,
      number: _numberController.text,
      date: _selectedDate,
      from: _fromController.text,
      to: _toController.text,
      subject: _subjectController.text,
      keywords: keywords,
      notes: _notesController.text,
      paperArchive: _paperArchiveController.text,
      attachments: _attachments,
      createdBy: widget.document?.createdBy ?? 'admin',
    );

    if (widget.document == null) {
      context.read<DocumentsCubit>().addDocument(doc);
    } else {
      context.read<DocumentsCubit>().updateDocument(doc);
    }

    Navigator.pop(context);
  }
}

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
