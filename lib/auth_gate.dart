import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/auth/auth_provider.dart';
import 'ui/components/loading_view.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/card_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isCheckingSession) {
          return const Scaffold(
            body: Center(child: LoadingView()),
          );
        }
        if (auth.isLoggedIn) {
          return const CardPage();
        }
        return const LoginPage();
      },
    );
  }
}
