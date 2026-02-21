import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/auth/auth_provider.dart';
import 'bloc/card/card_provider.dart';
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

      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}
