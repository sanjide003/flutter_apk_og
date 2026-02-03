import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'config/firebase_options.dart'; // പുതിയ ഫയൽ ഇമ്പോർട്ട് ചെയ്യുന്നു
import 'public/public_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ഫയർബേസ് ഇനിഷ്യലൈസ് ചെയ്യുന്നു (നമ്മുടെ പുതിയ ഫയലിൽ നിന്ന് ഓപ്ഷൻസ് എടുക്കും)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully using Custom Config");
  } catch (e) {
    print("Firebase Error: $e");
  }

  runApp(const InstitutionApp());
}

class InstitutionApp extends StatelessWidget {
  const InstitutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Institution OS',
      theme: AppTheme.lightTheme,
      home: const PublicPage(),
    );
  }
}
