import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/types_cubit/types_cubit.dart';

class ManageTypesScreen extends StatelessWidget {
  const ManageTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TypesCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الأنواع"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("إضافة نوع"),
        onPressed: () => _showAddDialog(context),
      ),

      body: BlocBuilder<TypesCubit, TypesState>(
        builder: (context, state) {
          if (state is TypesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _sectionTitle("📁 أنواع الصنف (${cubit.categories.length})"),
                const SizedBox(height: 8),

                ...cubit.categories.map(
                      (item) => _typeTile(
                    context,
                    id: item["id"],
                    title: item["name"],
                    isCategory: true,
                  ),
                ),

                const SizedBox(height: 30),

                _sectionTitle("🗄️ أنواع الحفظ الورقي (${cubit.paperTypes.length})"),
                const SizedBox(height: 8),

                ...cubit.paperTypes.map(
                      (item) => _typeTile(
                    context,
                    id: item["id"],
                    title: item["name"],
                    isCategory: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _typeTile(
      BuildContext context, {
        required String id,
        required String title,
        required bool isCategory,
      }) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDialog(context, id, title, isCategory),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, id, title, isCategory),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ADD DIALOG ----------------

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    bool isCategory = true;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("إضافة نوع جديد"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<bool>(
                value: true,
                items: const [
                  DropdownMenuItem(value: true, child: Text("نوع الصنف")),
                  DropdownMenuItem(value: false, child: Text("نوع الحفظ الورقي")),
                ],
                onChanged: (v) => isCategory = v!,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "الاسم",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("إضافة"),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final cubit = context.read<TypesCubit>();
                  isCategory
                      ? cubit.addCategory(name)
                      : cubit.addPaperType(name);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------- EDIT DIALOG ----------------

  void _showEditDialog(
      BuildContext context,
      String id,
      String oldName,
      bool isCategory,
      ) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("تعديل النوع"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "الاسم الجديد",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("حفظ"),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  final cubit = context.read<TypesCubit>();

                  isCategory
                      ? cubit.updateCategory(id, newName)
                      : cubit.updatePaperType(id, newName);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------- DELETE DIALOG ----------------

  void _showDeleteDialog(
      BuildContext context,
      String id,
      String name,
      bool isCategory,
      ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("حذف النوع"),
          content: Text("هل تريد حذف '$name'؟"),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("حذف"),
              onPressed: () {
                final cubit = context.read<TypesCubit>();

                isCategory
                    ? cubit.deleteCategory(id)
                    : cubit.deletePaperType(id);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
