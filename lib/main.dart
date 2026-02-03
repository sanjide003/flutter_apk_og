import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';

void main() {
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
