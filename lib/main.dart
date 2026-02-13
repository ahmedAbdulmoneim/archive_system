import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'bloc/auth/auth_cubit.dart';
import 'bloc/documents/documents_cubit.dart';
import 'bloc/types_cubit/types_cubit.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ AUTH CUBIT (GLOBAL)
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..checkAuthStatus(),
        ),

        // ✅ DOCUMENTS CUBIT (GLOBAL)
        BlocProvider<DocumentsCubit>(
          create: (_) => DocumentsCubit()..fetchDocuments(),
        ),
        BlocProvider(create: (_) => TypesCubit()..loadTypes()),
      ],
      child: const ArchiveApp(),
    );
  }
}
