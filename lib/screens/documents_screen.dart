import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/documents/documents_state.dart';
import '../widgets/documents_table.dart';
import 'add_document_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل تريد تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        Navigator.pop(context);
                      },
                      child: const Text('خروج'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),



      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated && state.role == 'admin') {
            return FloatingActionButton(
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
            );
          }
          return const SizedBox(); // user لا يرى الزر
        },
      ),


      body: BlocBuilder<DocumentsCubit, DocumentsState>(
        builder: (context, state) {
          if (state is DocumentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocumentsLoaded) {
            return Column(
              children: [
                // ✅ SEARCH BAR (NOW IT WILL APPEAR)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (value) {
                      context.read<DocumentsCubit>().search(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'بحث...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // ✅ TABLE MUST BE EXPANDED
                Expanded(
                  child: DocumentsTable(
                    documents: state.documents,

                  ),
                ),
              ],
            );
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
