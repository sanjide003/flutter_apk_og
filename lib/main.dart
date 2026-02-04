import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'config/firebase_options.dart';
import 'public/public_page.dart';
import 'auth/login_page.dart'; // പുതിയ ഫയൽ ഇമ്പോർട്ട് ചെയ്തു

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
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fee edusy',
      theme: AppTheme.lightTheme,
      
      // റൂട്ടുകൾ ഇവിടെ രജിസ്റ്റർ ചെയ്യുന്നു
      routes: {
        '/login': (context) => const LoginPage(),
        // '/admin': (context) => const AdminDashboard(), // പിന്നീട് ചേർക്കാം
      },

      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const PublicPage();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
