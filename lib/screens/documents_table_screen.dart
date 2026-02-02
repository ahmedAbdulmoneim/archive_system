import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/documents/documents_state.dart';
import '../widgets/documents_table.dart';
import 'add_document_screen.dart';

class DocumentsTableScreen extends StatelessWidget {
  const DocumentsTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<DocumentsCubit>(),
                child: const AddDocumentScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: BlocBuilder<DocumentsCubit, DocumentsState>(
        builder: (context, state) {
          if (state is DocumentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocumentsLoaded) {
            return DocumentsTable(documents: state.documents, cubit: context.read<DocumentsCubit>()
          ,);
          }

          if (state is DocumentsError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
