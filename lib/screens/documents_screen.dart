import 'package:archive_system/screens/users/users_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/documents/documents_state.dart';
import '../services/excel_export_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/documents_table.dart';
import 'account_screen.dart';
import 'add_document_screen.dart';
import 'dashboard_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.role == 'admin') {
                return IconButton(
                  icon: const Icon(Icons.people),
                  tooltip: 'إدارة المستخدمين',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UsersScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.role == 'admin') {
                return IconButton(
                  icon: const Icon(Icons.dashboard),
                  tooltip: 'Dashboard',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.role == 'admin') {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export PDF',
                  onPressed: () {
                    final docs =
                        (context.read<DocumentsCubit>().state as DocumentsLoaded)
                            .documents;
                    PdfExportService.exportDocuments(docs);
                  },
                );
              }
              return const SizedBox();
            },
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.role == 'admin') {
                return IconButton(
                  icon: const Icon(Icons.table_view),
                  tooltip: 'Export Excel',
                  onPressed: () {
                    final docs =
                        (context.read<DocumentsCubit>().state as DocumentsLoaded)
                            .documents;

                    ExcelExportService.exportDocuments(docs);
                  },
                );

            }
              return const SizedBox();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'الحساب',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountScreen(),
                ),
              );
            },
          ),
          BlocBuilder<DocumentsCubit, DocumentsState>(
            builder: (context, state) {
              final cubit = context.read<DocumentsCubit>();

              if (!cubit.hasSelection) return const SizedBox();

              return IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('حذف'),
                      content: const Text('هل تريد حذف العناصر المحددة؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            cubit.deleteSelected();
                            Navigator.pop(context);
                          },
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                },
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
