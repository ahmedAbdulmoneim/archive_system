import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/documents_model.dart';
import '../../services/audit_service.dart';
import 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DocumentModel> _allDocuments = [];
  List<DocumentModel> _visibleDocuments = [];

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _sortField;
  bool _ascending = true;

  final Set<String> _selectedIds = {};
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;

  DocumentsCubit() : super(const DocumentsInitial());

  // 🔑 الطريقة الصحيحة الوحيدة للإرسال
  void _emitVisible() {
    emit(DocumentsLoaded(
      documents: List.from(_visibleDocuments),
      selectedIds: Set.from(_selectedIds),
      isSearching: _isSearching,
    ));
  }

  // ================= FETCH =================
  Future<void> fetchDocuments() async {
    emit(const DocumentsLoading());

    try {
      final snapshot = await _firestore
          .collection('documents')
          .orderBy('createdAt', descending: true)
          .get();

      _allDocuments = snapshot.docs
          .map((e) => DocumentModel.fromMap(e.data(), e.id))
          .toList();

      _visibleDocuments = List.from(_allDocuments);
      _selectedIds.clear();
      _isSearching = false;

      _emitVisible();
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  // ================= SIMPLE SEARCH =================
  void search(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    final lower = query.toLowerCase();

    _visibleDocuments = _allDocuments.where((doc) {
      return doc.categoryName.toLowerCase().contains(lower) ||
          doc.from.toLowerCase().contains(lower) ||
          doc.number.toLowerCase().contains(lower) ||
          doc.notes.toLowerCase().contains(lower) ||
          doc.paperArchive.toLowerCase().contains(lower) ||
          doc.subject.toLowerCase().contains(lower);
    }).toList();

    _emitVisible();
  }

  // ================= ADVANCED SEARCH =================
  void searchAdvanced({
    String text = "",
    DateTime? from,
    DateTime? to,
    String? category,
    String? paper,
    String? fromField,
    String? toField,
    String? subject,
    String? keywords,
  }) {
    _isSearching = true;
    List<DocumentModel> result = List.from(_allDocuments);

    if (text.isNotEmpty) {
      final lower = text.toLowerCase();
      result = result.where((doc) {
        return doc.categoryName.toLowerCase().contains(lower) ||
            doc.from.toLowerCase().contains(lower) ||
            doc.to.toLowerCase().contains(lower) ||
            doc.subject.toLowerCase().contains(lower) ||
            doc.notes.toLowerCase().contains(lower) ||
            doc.paperArchive.toLowerCase().contains(lower) ||
            doc.keywords.join(',').toLowerCase().contains(lower);
      }).toList();
    }

    if (category != null && category.isNotEmpty) {
      result = result.where((doc) => doc.categoryName == category).toList();
    }

    if (paper != null && paper.isNotEmpty) {
      result = result.where((doc) => doc.paperArchive == paper).toList();
    }

    if (fromField != null && fromField.isNotEmpty) {
      result = result.where((doc) => doc.from.contains(fromField)).toList();
    }

    if (toField != null && toField.isNotEmpty) {
      result = result.where((doc) => doc.to.contains(toField)).toList();
    }

    if (subject != null && subject.isNotEmpty) {
      result = result.where((doc) => doc.subject.contains(subject)).toList();
    }

    if (keywords != null && keywords.isNotEmpty) {
      result = result.where(
            (doc) => doc.keywords.any((k) => k.contains(keywords)),
      ).toList();
    }

    if (from != null) {
      result = result.where(
            (doc) => doc.date != null && !doc.date!.isBefore(from),
      ).toList();
    }

    if (to != null) {
      result = result.where(
            (doc) => doc.date != null && !doc.date!.isAfter(to),
      ).toList();
    }

    _visibleDocuments = List.from(result);
    _emitVisible();
  }

  // ================= CLEAR SEARCH =================
  void clearSearch() {
    _isSearching = false;
    _visibleDocuments = List.from(_allDocuments);
    _emitVisible();
  }

  // ================= SORT =================
  void sortDocuments(String field) {
    if (state is! DocumentsLoaded) return;

    if (_sortField == field) {
      _ascending = !_ascending;
    } else {
      _sortField = field;
      _ascending = true;
    }

    _visibleDocuments.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (field) {
        case 'date':
          aValue = a.date;
          bValue = b.date;
          break;
        case 'number':
          aValue = a.number;
          bValue = b.number;
          break;
        case 'category':
          aValue = a.categoryName;
          bValue = b.categoryName;
          break;
        default:
          return 0;
      }

      if (aValue == null || bValue == null) return 0;

      return _ascending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });

    _emitVisible();
  }

  // ================= SELECTION =================
  bool isSelected(String id) => _selectedIds.contains(id);

  void toggleSelection(String id) {
    _selectedIds.contains(id)
        ? _selectedIds.remove(id)
        : _selectedIds.add(id);
    _emitVisible();
  }

  void toggleSelectAll(bool selectAll) {
    if (selectAll) {
      _selectedIds
        ..clear()
        ..addAll(_visibleDocuments.map((e) => e.id));
    } else {
      _selectedIds.clear();
    }
    _emitVisible();
  }

  void clearSelection() {
    _selectedIds.clear();
    _emitVisible();
  }

  // ================= DELETE =================
  Future<void> deleteSelected() async {
    final batch = _firestore.batch();

    for (final id in _selectedIds) {
      final ref = _firestore.collection('documents').doc(id);
      await AuditService.log(
        action: 'delete_document',
        entity: 'document',
        entityId: id,
        description: 'تم حذف وثيقة',
      );
      batch.delete(ref);
    }

    await batch.commit();
    _selectedIds.clear();
    await fetchDocuments();
  }

  // ================= ADD / UPDATE =================
  Future<void> addDocument(DocumentModel doc) async {
    await _firestore.collection('documents').add(doc.toMap());
    await AuditService.log(
      action: 'add_document',
      entity: 'document',
      description: 'تم إضافة وثيقة جديدة',
    );
    await fetchDocuments();
  }

  Future<void> updateDocument(DocumentModel doc) async {
    await _firestore
        .collection('documents')
        .doc(doc.id)
        .update(doc.toMap());

    await AuditService.log(
      action: 'update_document',
      entity: 'document',
      entityId: doc.id,
      description: 'تم تعديل وثيقة',
    );

    await fetchDocuments();
  }
}
