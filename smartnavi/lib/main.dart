import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartnavi/utils/theme.dart';
import 'firebase_options.dart';
import 'utils/router.dart';

final _appRouter = AppRouter();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.config(),
    );
  }
}
