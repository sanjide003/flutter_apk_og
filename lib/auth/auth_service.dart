import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- MOCK DATA ---
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

  final List<String> _dummyStaff = [
    "Principal User",
    "Manager User",
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
  Future<String> loginStaff(String name, String password) async {
    // അഡ്മിൻ ലോഗിൻ പരിശോധന
    if (name == "Principal User" || name == "Manager User") {
      // ഇവിടെ try-catch ഒഴിവാക്കി, എറർ വന്നാൽ അത് നേരിട്ട് UI-ലേക്ക് പോകും
      await _firebaseAuth.signInWithEmailAndPassword(
        email: "dsd003@gmail.com", 
        password: password
      );
      return "admin"; 
    } 
    
    // സാധാരണ സ്റ്റാഫ് ലോഗിൻ
    else if (password == "password") {
      return "staff";
    }
    
    // പാസ്‌വേഡ് തെറ്റാണെങ്കിൽ എറർ ത്രോ ചെയ്യുന്നു
    throw Exception("Invalid Username or Password");
  }

  // 2. Student Login
  Future<bool> loginStudent(String className, String name, String phone) async {
    await Future.delayed(const Duration(seconds: 2));
    if (phone == "123456") return true;
    return false;
  }

  // 3. Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
  
  User? get currentUser => _firebaseAuth.currentUser;
}
