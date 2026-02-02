import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/documents_model.dart';
import 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DocumentModel> _allDocuments = [];
  String? _sortField;
  bool _ascending = true;

  DocumentsCubit() : super(DocumentsInitial());

  // ================= FETCH =================
  Future<void> fetchDocuments() async {
    emit(DocumentsLoading());

    try {
      final snapshot = await _firestore
          .collection('documents')
          .orderBy('createdAt', descending: true)
          .get();

      _allDocuments = snapshot.docs
          .map((e) => DocumentModel.fromMap(e.data(), e.id))
          .toList();

      emit(DocumentsLoaded(_allDocuments));
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  // ================= SEARCH =================
  void search(String query) {
    if (query.isEmpty) {
      emit(DocumentsLoaded(_allDocuments));
      return;
    }

    final lower = query.toLowerCase();

    final filtered = _allDocuments.where((doc) {
      return doc.categoryName.toLowerCase().contains(lower) ||
          doc.from.toLowerCase().contains(lower) ||
          doc.number.toLowerCase().contains(lower) ||
          doc.notes.toLowerCase().contains(lower) ||
          doc.subject.toLowerCase().contains(lower);
    }).toList();

    emit(DocumentsLoaded(filtered));
  }

  // ================= ADD =================
  Future<void> addDocument(DocumentModel doc) async {
    try {
      await _firestore.collection('documents').add(doc.toMap());
      await fetchDocuments();
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  // ================= UPDATE =================
  Future<void> updateDocument(DocumentModel doc) async {
    await _firestore
        .collection('documents')
        .doc(doc.id)
        .update(doc.toMap());

    await fetchDocuments();
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

    final sorted = List<DocumentModel>.from(_allDocuments)..sort((a, b) {
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

    emit(DocumentsLoaded(sorted));
  }
}
