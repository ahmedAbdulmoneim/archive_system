
import '../../models/documents_model.dart';

abstract class DocumentsState {}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentModel> documents;
  DocumentsLoaded(this.documents);
}

class DocumentsError extends DocumentsState {
  final String message;
  DocumentsError(this.message);
}
