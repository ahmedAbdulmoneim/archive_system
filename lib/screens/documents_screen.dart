import 'package:archive_system/screens/users/users_screen.dart';
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

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }
  void _confirmDelete(
      BuildContext context, DocumentsCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المستندات'),
        content: Text(
          'هل تريد حذف ${cubit.selectedCount} مستند؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              cubit.deleteSelected();
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Documents'),
            actions: [

              // =========================
              // 👥 USERS (ADMIN)
              // =========================
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated &&
                      state.role == 'admin') {
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

              // =========================
              // 📊 DASHBOARD
              // =========================
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated &&
                      state.role == 'admin') {
                    return IconButton(
                      icon: const Icon(Icons.dashboard),
                      tooltip: 'Dashboard',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const DashboardScreen(),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),

              // =========================
              // 📄 EXPORT PDF
              // =========================
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated &&
                      state.role == 'admin') {
                    return IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'Export PDF',
                      onPressed: () {
                        final docs =
                            (context.read<DocumentsCubit>().state
                            as DocumentsLoaded)
                                .documents;
                        PdfExportService.exportDocuments(docs);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),

              // =========================
              // 📊 EXPORT EXCEL
              // =========================
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated &&
                      state.role == 'admin') {
                    return IconButton(
                      icon: const Icon(Icons.table_view),
                      tooltip: 'Export Excel',
                      onPressed: () {
                        final docs =
                            (context.read<DocumentsCubit>().state
                            as DocumentsLoaded)
                                .documents;
                        ExcelExportService.exportDocuments(docs);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),

              // =========================
              // 👤 ACCOUNT
              // =========================
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
              // delete ==============
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthAuthenticated ||
                      authState.role != 'admin') {
                    return const SizedBox();
                  }

                  return BlocBuilder<DocumentsCubit, DocumentsState>(
                    builder: (context, docState) {
                      final cubit = context.read<DocumentsCubit>();

                      if (!cubit.hasSelection) {
                        return const SizedBox();
                      }

                      return IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف المحدد',
                        onPressed: () {
                          _confirmDelete(context, cubit);
                        },
                      );
                    },
                  );
                },
              ),

            ],
          ),

          // =========================
          // ➕ ADD DOCUMENT
          // =========================
          floatingActionButton:
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated &&
                  state.role == 'admin') {
                return FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value:
                          context.read<DocumentsCubit>(),
                          child:
                          const AddDocumentScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                );
              }
              return const SizedBox();
            },
          ),

          // =========================
          // 📄 BODY
          // =========================
          body: BlocBuilder<DocumentsCubit, DocumentsState>(
            builder: (context, state) {
              if (state is DocumentsLoading) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              if (state is DocumentsLoaded) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        onChanged: (value) {
                          context
                              .read<DocumentsCubit>()
                              .search(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'بحث...',
                          prefixIcon:
                          const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DocumentsTable(
                        documents: state.documents,
                      ),
                    ),
                  ],
                );
              }

              if (state is DocumentsError) {
                return Center(
                    child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
