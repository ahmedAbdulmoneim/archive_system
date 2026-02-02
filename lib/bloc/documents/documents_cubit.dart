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

  // 1️⃣ Fetch documents
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

  // 2️⃣ Search documents
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
          doc.notes.toLowerCase().contains(lower);
    }).toList();

    emit(DocumentsLoaded(filtered));
  }

  // 3️⃣ Add document  ✅ THIS FIXES YOUR ERROR
  Future<void> addDocument(DocumentModel doc) async {
    await FirebaseFirestore.instance.collection('documents').add({
      'categoryName': doc.categoryName,
      'number': doc.number,
      'date': doc.date,
      'from': doc.from,
      'to': doc.to,
      'subject': doc.subject,
      'keywords': doc.keywords,
      'notes': doc.notes,
      'paperArchive': doc.paperArchive,
      'status': 'active',
      'createdBy': doc.createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });

    fetchDocuments(); // refresh list
  }

  void sortDocuments(String field) {
    if (state is! DocumentsLoaded) return;

    final current = (state as DocumentsLoaded).documents;

    if (_sortField == field) {
      _ascending = !_ascending; // toggle
    } else {
      _sortField = field;
      _ascending = true;
    }

    final sorted = List.of(current)..sort((a, b) {
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
