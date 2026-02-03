import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardState {
  final int documentsCount;
  final int activeDocuments;
  final int usersCount;

  DashboardState({
    required this.documentsCount,
    required this.activeDocuments,
    required this.usersCount,
  });
}

class DashboardCubit extends Cubit<DashboardState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardCubit()
      : super(DashboardState(
    documentsCount: 0,
    activeDocuments: 0,
    usersCount: 0,
  ));

  Future<void> loadDashboard() async {
    final docsSnap = await _firestore.collection('documents').get();
    final usersSnap = await _firestore.collection('users').get();

    final activeDocs = docsSnap.docs.where(
          (d) => d.data()['status'] == 'active',
    ).length;

    emit(
      DashboardState(
        documentsCount: docsSnap.size,
        activeDocuments: activeDocs,
        usersCount: usersSnap.size,
      ),
    );
  }
}
