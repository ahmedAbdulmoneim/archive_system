import 'package:archive_system/models/attachment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/types_cubit/types_cubit.dart';
import '../models/documents_model.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentModel? document;

  const AddDocumentScreen({super.key, this.document});

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

  // ===================== ATTACHMENTS =====================

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة بالكاميرا'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('اختيار صورة من الجهاز'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('اختيار ملف من الجهاز'),
              onTap: () {
                Navigator.pop(context);
                _pickAttachment();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _attachments.add(
        AttachmentModel(
          name: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
          type: 'jpg',
          localPath: picked.path,
        ),
      );
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _attachments.add(
        AttachmentModel(
          name: 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
          type: 'jpg',
          localPath: picked.path,
        ),
      );
    });
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    if (result == null) return;

    setState(() {
      for (final file in result.files) {
        _attachments.add(
          AttachmentModel(
            name: file.name,
            type: file.extension ?? 'file',
            localPath: file.path,
          ),
        );
      }
    });
  }

  // ===================== INIT =====================

  @override
  void initState() {
    super.initState();
    context.read<TypesCubit>().loadTypes();

    if (widget.document != null) {
      final doc = widget.document!;
      _numberController.text = doc.number ?? '';
      _fromController.text = doc.from ?? '';
      _toController.text = doc.to ?? '';
      _subjectController.text = doc.subject ?? '';
      _notesController.text = doc.notes ?? '';
      _paperArchiveController.text = doc.paperArchive ?? '';
      _keywordsController.text = (doc.keywords ?? []).join(', ');
      _selectedDate = doc.date;
      _categoryName = doc.categoryName ?? '';
      _attachments.addAll(doc.attachments ?? []);
    } else {
      _selectedDate = DateTime.now();
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

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document == null ? 'إضافة مستند' : 'تعديل مستند'),
      ),
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
                  // الصنف
                  DropdownButtonFormField<String>(
                    value: typesCubit.categories
                        .any((e) => e['name'] == _categoryName)
                        ? _categoryName
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'الصنف (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                    items: typesCubit.categories
                        .map((e) => DropdownMenuItem<String>(
                      value: e['name'],
                      child: Text(e['name']),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryName = v ?? ''),
                  ),
                  const SizedBox(height: 12),

                  _textField('رقم الوثيقة (اختياري)', _numberController),
                  _datePicker(context),
                  _textField('صادر من (اختياري)', _fromController),
                  _textField('وارد إلى (اختياري)', _toController),
                  _textField('الموضوع (اختياري)', _subjectController),
                  _textField('كلمات دلالية (اختياري)', _keywordsController),
                  _textField('ملاحظات (اختياري)', _notesController, maxLines: 3),

                  // 🆕 نوع الحفظ الورقي
                  DropdownButtonFormField<String>(
                    value: typesCubit.paperTypes.any(
                            (e) => e['name'] == _paperArchiveController.text)
                        ? _paperArchiveController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'نوع الحفظ الورقي (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                    items: typesCubit.paperTypes
                        .map((e) => DropdownMenuItem<String>(
                      value: e['name'],
                      child: Text(e['name']),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _paperArchiveController.text = v ?? ''),
                  ),

                  const SizedBox(height: 16),
                  _attachmentsList(),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('إضافة مرفق'),
                      onPressed: () => _showAttachmentOptions(context),
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
          if (picked != null) setState(() => _selectedDate = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'التاريخ (إجباري)',
            border: OutlineInputBorder(),
          ),
          child: Text(
            _selectedDate != null
                ?DateFormat('yyyy/MM/dd').format(_selectedDate!)
                : '',
          ),
        ),
      ),
    );
  }

  Widget _attachmentsList() {
    if (_attachments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('لا توجد مرفقات', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        final att = _attachments[index];
        final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp']
            .contains(att.type.toLowerCase());

        return Card(
          child: ListTile(
            leading: isImage && att.localPath != null
                ? Image.network(att.localPath!, width: 40, height: 40)
                : const Icon(Icons.attach_file),
            title: Text(att.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(att.type.toUpperCase()),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () =>
                  setState(() => _attachments.removeAt(index)),
            ),
          ),
        );
      },
    );
  }

  // ===================== SAVE =====================

  void _saveDocument() async {
    if (_selectedDate == null) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    String? branchName;
    if (authState.branchId != null) {
      final branchDoc = await FirebaseFirestore.instance
          .collection('branches')
          .doc(authState.branchId)
          .get();
      branchName = branchDoc.data()?['name'];
    }

    final doc = DocumentModel(
      id: widget.document?.id ?? '',
      categoryName: _categoryName.isEmpty ? null : _categoryName,
      number: _numberController.text.isEmpty ? null : _numberController.text,
      date: _selectedDate,
      from: _fromController.text.isEmpty ? null : _fromController.text,
      to: _toController.text.isEmpty ? null : _toController.text,
      subject:
      _subjectController.text.isEmpty ? null : _subjectController.text,
      keywords: _keywordsController.text.isEmpty
          ? null
          : _keywordsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      paperArchive: _paperArchiveController.text.isEmpty
          ? null
          : _paperArchiveController.text,
      attachments: _attachments.isEmpty ? null : _attachments,
      createdBy: authState.name ?? authState.user.email,
      branchId: authState.branchId,
      branchName: branchName,
    );

    if (widget.document == null) {
      context.read<DocumentsCubit>().addDocument(doc);
    } else {
      context.read<DocumentsCubit>().updateDocument(doc);
    }

    if (mounted) Navigator.pop(context);
  }
}
