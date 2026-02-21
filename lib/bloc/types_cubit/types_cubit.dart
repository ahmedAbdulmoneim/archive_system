import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================= CUBIT =================

class TypesCubit extends Cubit<TypesState> {
  TypesCubit() : super(TypesInitial());

  final _categoriesRef =
  FirebaseFirestore.instance.collection('categories');
  final _paperTypesRef =
  FirebaseFirestore.instance.collection('paperTypes');

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> paperTypes = [];

  bool _loaded = false;

  // ================= LOAD =================
  Future<void> loadTypes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 🔐 حماية

    if (_loaded) return; // ⛔ منع التحميل المتكرر

    emit(TypesLoading());

    try {
      final catSnap = await _categoriesRef.get();
      final paperSnap = await _paperTypesRef.get();

      categories = catSnap.docs
          .map((d) => {
        "id": d.id,
        "name": d.data()["name"],
      })
          .toList();

      paperTypes = paperSnap.docs
          .map((d) => {
        "id": d.id,
        "name": d.data()["name"],
      })
          .toList();

      _loaded = true;
      emit(TypesLoaded());
    } catch (e) {
      emit(TypesError(e.toString()));
    }
  }

  // ================= ADD =================
  Future<void> addCategory(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _categoriesRef.add({"name": name});
    _loaded = false;
    await loadTypes();
  }

  Future<void> addPaperType(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _paperTypesRef.add({"name": name});
    _loaded = false;
    await loadTypes();
  }

  // ================= DELETE =================
  Future<void> deleteCategory(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _categoriesRef.doc(id).delete();
    _loaded = false;
    await loadTypes();
  }

  Future<void> deletePaperType(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _paperTypesRef.doc(id).delete();
    _loaded = false;
    await loadTypes();
  }

  // ================= UPDATE =================
  Future<void> updateCategory(String id, String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _categoriesRef.doc(id).update({"name": newName});
    _loaded = false;
    await loadTypes();
  }

  Future<void> updatePaperType(String id, String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _paperTypesRef.doc(id).update({"name": newName});
    _loaded = false;
    await loadTypes();
  }

  // ================= RESET =================
  void reset() {
    categories.clear();
    paperTypes.clear();
    _loaded = false;
    emit(TypesInitial());
  }
}

// ================= STATES =================

abstract class TypesState {}

class TypesInitial extends TypesState {}

class TypesLoading extends TypesState {}

class TypesLoaded extends TypesState {}

class TypesError extends TypesState {
  final String message;
  TypesError(this.message);
}
