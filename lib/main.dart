import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InstitutionApp());
}

class InstitutionApp extends StatelessWidget {
  const InstitutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Institution Operating System',
      theme: buildAppTheme(),
      initialRoute: AppRoutes.publicHome,
      routes: buildRoutes(),
    );
  }
}
