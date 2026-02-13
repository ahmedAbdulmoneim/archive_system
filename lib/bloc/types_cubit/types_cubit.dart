import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TypesCubit extends Cubit<TypesState> {
  TypesCubit() : super(TypesLoading());

  final _categoriesRef = FirebaseFirestore.instance.collection('categories');
  final _paperTypesRef = FirebaseFirestore.instance.collection('paperTypes');

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> paperTypes = [];

  Future<void> loadTypes() async {
    emit(TypesLoading());

    final catSnap = await _categoriesRef.get();
    final paperSnap = await _paperTypesRef.get();

    categories = catSnap.docs
        .map((d) => {"id": d.id, "name": d["name"]})
        .toList();

    paperTypes = paperSnap.docs
        .map((d) => {"id": d.id, "name": d["name"]})
        .toList();

    emit(TypesLoaded());
  }

  // ---------------- ADD ----------------
  Future<void> addCategory(String name) async {
    await _categoriesRef.add({"name": name});
    await loadTypes();
  }

  Future<void> addPaperType(String name) async {
    await _paperTypesRef.add({"name": name});
    await loadTypes();
  }

  // ---------------- DELETE ----------------
  Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
    await loadTypes();
  }

  Future<void> deletePaperType(String id) async {
    await _paperTypesRef.doc(id).delete();
    await loadTypes();
  }

  // ---------------- UPDATE ----------------
  Future<void> updateCategory(String id, String newName) async {
    await _categoriesRef.doc(id).update({"name": newName});
    await loadTypes();
  }

  Future<void> updatePaperType(String id, String newName) async {
    await _paperTypesRef.doc(id).update({"name": newName});
    await loadTypes();
  }
}

abstract class TypesState {}
class TypesLoading extends TypesState {}
class TypesLoaded extends TypesState {}
