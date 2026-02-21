import 'package:archive_system/screens/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/documents/documents_cubit.dart';
import '../bloc/documents/documents_state.dart';
import '../bloc/types_cubit/types_cubit.dart';
import '../services/excel_export_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/advanced_search_dialog.dart';
import '../widgets/documents_table.dart';
import 'account_screen.dart';
import 'add_document_screen.dart';
import 'dashboard_screen.dart';
import 'manage_types_screen.dart';

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

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<DocumentsCubit>().fetchDocuments(
            role: authState.role,
            branchId: authState.branchId,
          );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  void _confirmDelete(BuildContext context, DocumentsCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المستندات'),
        content: Text('هل تريد حذف ${cubit.selectedCount} مستند؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
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

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr is AuthAuthenticated,
      listener: (context, state) {
        final auth = state as AuthAuthenticated;
        context.read<DocumentsCubit>().fetchDocuments(
              role: auth.role,
              branchId: auth.branchId,
            );
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('إدارة المستندات'),
              actions: [
                // 🔍 البحث
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final cubit = context.read<DocumentsCubit>();
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const AdvancedSearchDialog(),
                      ),
                    );
                  },
                ),

                // 👥 إدارة المستخدمين (Super Admin فقط)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated &&
                        state.role == 'super_admin') {
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

                // 📊 Dashboard (Super Admin فقط)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated &&
                        state.role == 'super_admin') {
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

                // 📄 Export PDF (Super Admin + Branch Admin)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated &&
                        (state.role == 'super_admin' ||
                            state.role == 'branch_admin')) {
                      return IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        tooltip: 'Export PDF',
                        onPressed: () {
                          final docs = (context.read<DocumentsCubit>().state
                                  as DocumentsLoaded)
                              .documents;
                          PdfExportService.exportDocuments(docs);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),

                // 📊 Export Excel (Super Admin + Branch Admin)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated &&
                        (state.role == 'super_admin' ||
                            state.role == 'branch_admin')) {
                      return IconButton(
                        icon: const Icon(Icons.table_view),
                        tooltip: 'Export Excel',
                        onPressed: () {
                          final docs = (context.read<DocumentsCubit>().state
                                  as DocumentsLoaded)
                              .documents;
                          ExcelExportService.exportDocuments(docs);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),

                // 👤 الحساب
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
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: "تحديث",
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<DocumentsCubit>().reset();
                      context.read<DocumentsCubit>().fetchDocuments(
                            role: authState.role,
                            branchId: authState.branchId,
                          );
                    }
                  },
                ),

                // 🗑️ حذف المستندات (Super Admin فقط)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is! AuthAuthenticated ||
                        authState.role != 'super_admin') {
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

                // 🗂️ إدارة الأنواع (Super Admin فقط)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated &&
                        state.role == 'super_admin') {
                      return IconButton(
                        icon: const Icon(Icons.category),
                        tooltip: 'إدارة الأنواع',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<TypesCubit>(),
                                child: const ManageTypesScreen(),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),

            // ➕ إضافة مستند (Super Admin + Branch Admin)
            floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated &&
                    (state.role == 'super_admin' ||
                        state.role == 'branch_admin')) {
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
                return const SizedBox();
              },
            ),

            body: BlocBuilder<DocumentsCubit, DocumentsState>(
              builder: (context, state) {
                final cubit = context.read<DocumentsCubit>();

                if (state is DocumentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DocumentsLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cubit.isSearching)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                'نتائج البحث: ${state.documents.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('عرض كل المستندات'),
                                onPressed: () {
                                  cubit.clearSearch();
                                },
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: DocumentsTable(documents: state.documents),
                      ),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}
