import 'package:art_mobile/features/auth/presentation/controller/auth_controller.dart';
import 'package:art_mobile/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

class AppStartupPage extends StatelessWidget {
  const AppStartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!auth.isLoggedIn) {
          return const LoginPage();
        }

        /// NEXT STEP:
        /// validate backend session
        /// validate approval state

        return const HomePage();
      },
    );
  }
}
