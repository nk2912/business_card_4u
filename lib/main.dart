import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/auth/auth_provider.dart';
import 'bloc/card/card_provider.dart';
import 'bloc/company/company_provider.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        /// ================= AUTH PROVIDER =================
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkLogin(),
        ),

        /// ================= CARD PROVIDER =================
        ChangeNotifierProvider(
          create: (_) => CardProvider(),
        ),

        /// ================= COMPANY PROVIDER =================
        ChangeNotifierProvider(
          create: (_) => CompanyProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..load(),
        ),

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          home: const AuthGate(),
        ),
      ),
    );
  }
}
