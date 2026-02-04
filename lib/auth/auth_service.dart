import 'dart:async';

class AuthService {
  // --- MOCK DATA (ടെസ്റ്റിംഗിന് വേണ്ടി മാത്രം) ---
  
  // ക്ലാസ്സുകളുടെ ലിസ്റ്റ്
  final List<String> _dummyClasses = [
    "Class 8 A", "Class 8 B", 
    "Class 9 A", "Class 9 B", 
    "Class 10 A", "Class 10 B", 
    "+1 Science", "+1 Commerce", "+1 Humanities",
    "+2 Science", "+2 Commerce", "+2 Humanities"
  ];

  // കുട്ടികളുടെ ലിസ്റ്റ് (ക്ലാസ്സ് തിരിച്ച്)
  final Map<String, List<String>> _dummyStudents = {
    "Class 10 A": ["Arjun", "Anjali", "Adwaith", "Bimal", "Chandana"],
    "Class 10 B": ["Rahul", "Rohit", "Reshma", "Sruthi", "Varun"],
    "+2 Science": ["Fathima", "Gokul", "Harikrishnan", "Ishaan"],
  };

  // സ്റ്റാഫ് ലിസ്റ്റ്
  final List<String> _dummyStaff = [
    "Principal User",
    "Manager User",
    "Rahul Teacher",
    "Sruthi Teacher",
    "Accountant",
    "Clerk"
  ];

  // --- FUNCTIONS ---

  // 1. എല്ലാ ക്ലാസ്സുകളും ലഭിക്കാൻ
  Future<List<String>> getClasses() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Loading simulation
    return _dummyClasses;
  }

  // 2. ഒരു ക്ലാസ്സിലെ കുട്ടികളെ ലഭിക്കാൻ
  Future<List<String>> getStudentsByClass(String className) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyStudents[className] ?? []; // ആ ക്ലാസ്സ് ഇല്ലെങ്കിൽ വെറും ലിസ്റ്റ്
  }

  // 3. എല്ലാ സ്റ്റാഫിനെയും ലഭിക്കാൻ
  Future<List<String>> getStaffList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyStaff;
  }

  // 4. Student Login Check (Temporary)
  Future<bool> loginStudent(String className, String name, String phone) async {
    await Future.delayed(const Duration(seconds: 2));
    // ടെസ്റ്റിംഗ്: ഫോൺ നമ്പർ '123456' ആണെങ്കിൽ വിജയിക്കും
    if (phone == "123456") return true;
    return false;
  }

  // 5. Staff Login Check (Temporary)
  Future<String?> loginStaff(String name, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // ടെസ്റ്റിംഗ്: പാസ്‌വേഡ് 'password' ആണെങ്കിൽ വിജയിക്കും
    if (password == "password") {
      // പേര് നോക്കി റോൾ തീരുമാനിക്കുന്നു (Demo Logic)
      if (name.contains("Principal") || name.contains("Manager")) return "admin";
      return "staff";
    }
    return null; // Login Failed
  }
}
