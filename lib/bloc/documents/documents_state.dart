import 'package:equatable/equatable.dart';
import '../../models/documents_model.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {
  const DocumentsInitial();
}

class DocumentsLoading extends DocumentsState {
  const DocumentsLoading();
}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentModel> documents;
  final Set<String> selectedIds;
  final bool isSearching;

  const DocumentsLoaded({
    required this.documents,
    required this.selectedIds,
    required this.isSearching,
  });

  @override
  List<Object?> get props => [documents, selectedIds, isSearching];
}

class DocumentsError extends DocumentsState {
  final String message;
  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
