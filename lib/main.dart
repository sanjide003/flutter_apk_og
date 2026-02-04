import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'config/firebase_options.dart';
import 'public/public_page.dart';
import 'auth/login_page.dart';
import 'admin/admin_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InstitutionApp());
}

class InstitutionApp extends StatefulWidget {
  const InstitutionApp({super.key});

  @override
  State<InstitutionApp> createState() => _InstitutionAppState();
}

class _InstitutionAppState extends State<InstitutionApp> {
  // റിയൽ ഫയർബേസ് ഇനിഷ്യലൈസേഷൻ
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fee edusy',
      theme: AppTheme.lightTheme,
      
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
      },

      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // എറർ വന്നാൽ
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Firebase Error: ${snapshot.error}", 
                  style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          // കണക്ട് ആയാൽ
          if (snapshot.connectionState == ConnectionState.done) {
            return const PublicPage();
          }

          // ലോഡിംഗ്
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
