import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:smartnavi/utils/router.gr.dart';

final _providers = [EmailAuthProvider()];

@RoutePage()
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  void _onSignedIn(BuildContext context) {
    // Handle post sign-in logic here, such as navigating to the home page
    AutoRouter.of(context).replace(HomeRoute());
  }

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: _providers,
      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          // Put a ny new user logic here
          debugPrint('New user created: ${state.credential.user?.email}');
          _onSignedIn(context);
        }),
        AuthStateChangeAction<SignedIn>((context, state) {
          _onSignedIn(context);
        }),
      ],
    );
  }
}
