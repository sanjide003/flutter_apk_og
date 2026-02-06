import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. STUDENT LOGIN HELPERS ---

  // Get Active Classes for Dropdown
  Stream<QuerySnapshot> getActiveClasses() {
    return _db.collection('classes').orderBy('name').snapshots();
  }

  // Get Students by Class (Name Search)
  Future<List<Map<String, dynamic>>> getStudentsForLogin(String className) async {
    final snapshot = await _db.collection('students')
        .where('className', isEqualTo: className)
        .where('isActive', isEqualTo: true)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'phone': doc['phone'], // Password check
    }).toList();
  }

  // Verify Student Phone (Password)
  Future<bool> verifyStudentLogin(String studentId, String inputPhone) async {
    try {
      DocumentSnapshot doc = await _db.collection('students').doc(studentId).get();
      if (!doc.exists) return false;
      
      String registeredPhone = doc['phone'] ?? "";
      // ഫോൺ നമ്പർ മാച്ച് ആകുന്നുണ്ടോ എന്ന് നോക്കുന്നു (ലളിതമായ പാസ്‌വേഡ്)
      return registeredPhone.trim() == inputPhone.trim();
    } catch (e) {
      return false;
    }
  }

  // --- 2. STAFF / ADMIN LOGIN ---

  Future<String> loginStaff(String identifier, String password) async {
    try {
      // 1. HARDCODED MASTER ADMIN (For Safety)
      if (identifier == "dsd003@gmail.com" && password == "dsd003") {
        try {
           await _auth.signInWithEmailAndPassword(email: identifier, password: password);
        } catch (e) {
           // If auth fails (no user yet), allow bypass for setup
        }
        return "admin";
      }

      // 2. CHECK DB FOR USERNAME/EMAIL
      // We check if input matches 'username' OR 'email'
      final snapshot = await _db.collection('users')
          .where('username', isEqualTo: identifier) // Check username
          .get();
      
      QueryDocumentSnapshot? userDoc;
      
      if (snapshot.docs.isNotEmpty) {
        userDoc = snapshot.docs.first;
      } else {
        // If not found by username, try email
        final emailSnap = await _db.collection('users').where('email', isEqualTo: identifier).get();
        if (emailSnap.docs.isNotEmpty) userDoc = emailSnap.docs.first;
      }

      if (userDoc == null) throw Exception("User not found");

      var data = userDoc.data() as Map<String, dynamic>;
      
      // Password Check
      if (data['password'] != password) throw Exception("Incorrect Password");
      if (data['isActive'] == false) throw Exception("Account Deactivated");

      // Firebase Auth Login (Optional: if email exists)
      String email = data['email'] ?? "";
      if (email.isNotEmpty && email.contains("@")) {
        try {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
        } catch (_) {}
      }

      return data['role'] ?? "staff";

    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  Future<void> logout() async => await _auth.signOut();
}