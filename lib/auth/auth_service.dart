import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // സ്റ്റാഫിന്റെ പേരുകൾ മാത്രം എടുക്കുന്ന ഫംഗ്‌ഷൻ (Search ചെയ്യാൻ)
  Future<List<String>> getStaffNames() async {
    try {
      final snapshot = await _db.collection('users').get();
      List<String> names = snapshot.docs.map((doc) => doc['name'] as String).toList();
      
      if (!names.contains("Principal User")) names.insert(0, "Principal User");
      return names;
    } catch (e) {
      return ["Principal User"];
    }
  }

  // LOGIN FUNCTION WITH PASSWORD CHECK
  Future<String> loginStaff(String name, String password) async {
    try {
      // 1. ADMIN CHECK (HARDCODED FOR SAFETY)
      if (name == "Principal User" && password == "dsd003") {
        await _auth.signInWithEmailAndPassword(email: "dsd003@gmail.com", password: password);
        return "admin";
      }

      // 2. FETCH USER FROM DB BY NAME
      final snapshot = await _db.collection('users')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("User name not found. Please contact Admin.");
      }

      var userData = snapshot.docs.first.data();
      String storedPassword = userData['password'] ?? ""; // Fetching stored password

      // 3. VERIFY PASSWORD
      if (password != storedPassword) {
        throw Exception("Incorrect Password.");
      }

      // 4. IF PASSWORD CORRECT, LOGIN VIA FIREBASE (Using Dummy Email Logic or Real Email if available)
      // Since we are using Name/Pass login, we simulate Auth state.
      // In a real app, you should Map names to Emails.
      // For now, we return the role directly.
      
      return userData['role'] ?? "staff";

    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}