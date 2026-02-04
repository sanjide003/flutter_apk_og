import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- MOCK DATA (ഡാറ്റാബേസ് റെഡിയാകുന്നത് വരെ ക്ലാസ്സുകൾ കാണിക്കാൻ) ---
  final List<String> _dummyClasses = [
    "Class 8 A", "Class 8 B", 
    "Class 9 A", "Class 9 B", 
    "Class 10 A", "Class 10 B", 
    "+1 Science", "+1 Commerce", "+1 Humanities",
    "+2 Science", "+2 Commerce", "+2 Humanities"
  ];

  final Map<String, List<String>> _dummyStudents = {
    "Class 10 A": ["Arjun", "Anjali", "Adwaith", "Bimal", "Chandana"],
    "Class 10 B": ["Rahul", "Rohit", "Reshma", "Sruthi", "Varun"],
    "+2 Science": ["Fathima", "Gokul", "Harikrishnan", "Ishaan"],
  };

  // സ്റ്റാഫ് ലിസ്റ്റ് (ഇതിൽ Principal User എന്നത് അഡ്മിൻ ആണ്)
  final List<String> _dummyStaff = [
    "Principal User", // Admin
    "Manager User",   // Admin (Optional)
    "Rahul Teacher",
    "Sruthi Teacher",
    "Accountant",
    "Clerk"
  ];

  // --- FUNCTIONS ---

  Future<List<String>> getClasses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyClasses;
  }

  Future<List<String>> getStudentsByClass(String className) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyStudents[className] ?? [];
  }

  Future<List<String>> getStaffList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyStaff;
  }

  // --- REAL FIREBASE LOGIN IMPLEMENTATION ---

  // 1. Staff / Admin Login
  Future<String?> loginStaff(String name, String password) async {
    try {
      // അഡ്മിൻ ലോഗിൻ പരിശോധന
      // പേര് "Principal User" അല്ലെങ്കിൽ "Manager User" ആണെങ്കിൽ അഡ്മിൻ ഇമെയിൽ ഉപയോഗിക്കുന്നു
      if (name == "Principal User" || name == "Manager User") {
        
        // ഫയർബേസ് ലോഗിൻ (Email & Password)
        await _firebaseAuth.signInWithEmailAndPassword(
          email: "dsd003@gmail.com", 
          password: password
        );
        
        return "admin"; // വിജയിച്ചാൽ 'admin' റോൾ നൽകുന്നു
      } 
      
      // സാധാരണ സ്റ്റാഫ് ലോഗിൻ (ഇപ്പോൾ ഡമ്മി ആയി വെക്കുന്നു)
      else if (password == "password") {
        return "staff";
      }
      
      return null; // ലോഗിൻ പരാജയപ്പെട്ടു

    } on FirebaseAuthException catch (e) {
      print("Firebase Login Error: ${e.message}");
      return null;
    } catch (e) {
      print("General Login Error: $e");
      return null;
    }
  }

  // 2. Student Login (താൽക്കാലികമായി പഴയതുപോലെ തന്നെ)
  Future<bool> loginStudent(String className, String name, String phone) async {
    await Future.delayed(const Duration(seconds: 2));
    if (phone == "123456") return true;
    return false;
  }

  // 3. Logout Function
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
  
  // 4. Check Current User
  User? get currentUser => _firebaseAuth.currentUser;
}
