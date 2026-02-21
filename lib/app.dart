import 'package:archive_system/feautres/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_cubit.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/documents/documents_cubit.dart';
import 'bloc/theme_cubit/theme_cubit.dart';
import 'bloc/types_cubit/types_cubit.dart';
import 'core/theme/app_theme.dart';
import 'screens/documents_screen.dart';

class ArchiveApp extends StatelessWidget {
  const ArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routes: { '/documents': (_) => const DocumentsScreen(), },

            home: BlocListener<AuthCubit, AuthState>(
              listenWhen: (prev, curr) => curr is AuthUnauthenticated,
              listener: (context, state) {
                context.read<DocumentsCubit>().reset();
                context.read<TypesCubit>().reset();
                // لو عندك UsersCubit global
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return const DocumentsScreen();
                  }
                  if (state is AuthLoading || state is AuthInitial) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const LoginPage();
                },
              ),

            ),


          );
        },
      ),
    );
  }
}
