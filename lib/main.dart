import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'config/firebase_options.dart';
import 'public/public_page.dart';

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
  // ഫയർബേസ് ഇനിഷ്യലൈസ് ചെയ്യുന്ന ഫ്യൂച്ചർ
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Updated App Name
      title: 'Fee edusy',
      
      theme: AppTheme.lightTheme,
      
      // FutureBuilder ഉപയോഗിക്കുന്നു
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // 1. എറർ വന്നാൽ സ്ക്രീനിൽ കാണിക്കും
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Something went wrong!\n\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          }

          // 2. കണക്ട് ആയിക്കഴിഞ്ഞാൽ പബ്ലിക് പേജ് കാണിക്കും
          if (snapshot.connectionState == ConnectionState.done) {
            return const PublicPage();
          }

          // 3. കണക്ട് ആകുന്നത് വരെ ലോഡിംഗ് കാണിക്കും
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Fee edusy Loading..."),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
