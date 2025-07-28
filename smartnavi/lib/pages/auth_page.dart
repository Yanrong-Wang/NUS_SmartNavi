import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnavi/utils/router.gr.dart';

final _providers = [ui_auth.EmailAuthProvider()];

@RoutePage()
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<void> _onSignedIn(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unverified Email'),
          content: const Text(
            'Please check your email for the verification link and complete the verification.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await user.sendEmailVerification();
                Navigator.of(context).pop();
              },
              child: const Text('Resend Verification Email'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      AutoRouter.of(context).replace(HomeRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ui_auth.SignInScreen(
      providers: _providers,
      actions: [
        ui_auth.AuthStateChangeAction<ui_auth.UserCreated>((context, state) {
          debugPrint('New user created: ${state.credential.user?.email}');
          _onSignedIn(context);
        }),
        ui_auth.AuthStateChangeAction<ui_auth.SignedIn>((context, state) {
          _onSignedIn(context);
        }),
      ],
    );
  }
}
