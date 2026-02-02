import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'bloc/auth/auth_cubit.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  runApp(
    BlocProvider<AuthCubit>(
      create: (_) => AuthCubit()..checkAuthStatus(),
      child: const ArchiveApp(),
    ),
  );
}
