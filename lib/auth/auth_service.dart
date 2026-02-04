import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // GET STAFF NAMES FOR LOGIN
  Future<List<String>> getStaffNames() async {
    try {
      final snapshot = await _db.collection('users').get();
      
      // എല്ലാ യൂസർ ഡോക്യുമെന്റുകളിൽ നിന്നും പേരുകൾ മാപ്പ് ചെയ്യുന്നു
      List<String> names = snapshot.docs.map((doc) {
        // ഡാറ്റ ഉണ്ടോ എന്ന് ഉറപ്പാക്കുന്നു
        return (doc.data()['name'] ?? "").toString();
      }).where((name) => name.isNotEmpty).toList();
      
      // ലിസ്റ്റ് എംപ്റ്റി ആണെങ്കിൽ (ആദ്യ ഉപയോഗം) അഡ്മിനെ ചേർക്കുന്നു
      if (names.isEmpty || !names.contains("Principal User")) {
        names.insert(0, "Principal User");
      }
      
      return names;
    } catch (e) {
      print("Error fetching names: $e");
      return ["Principal User"]; // എന്തെങ്കിലും എറർ വന്നാൽ ഡിഫോൾട്ട് നെയിം
    }
  }

  Future<String> loginStaff(String name, String password) async {
    try {
      // 1. HARDCODED ADMIN CHECK
      if (name == "Principal User" && password == "dsd003") {
        await _auth.signInWithEmailAndPassword(email: "dsd003@gmail.com", password: password);
        return "admin";
      }

      // 2. DB USER CHECK
      final snapshot = await _db.collection('users').where('name', isEqualTo: name).limit(1).get();
      if (snapshot.docs.isEmpty) throw Exception("User not found.");

      var data = snapshot.docs.first.data();
      
      // പാസ്‌വേഡ് ചെക്ക് (Phone number or Custom Password)
      String storedPass = data['password'] ?? data['phone'] ?? "";
      
      if (password != storedPass) throw Exception("Wrong Password.");

      // Login success logic (Auth simulation for staff)
      // Since staff may not have valid Auth emails yet, we bypass FirebaseAuth for them temporarily
      // or use a shared dummy account if strict Auth is needed.
      // For now, we trust the password match and return the role.
      
      return data['role'] ?? "staff";

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async => await _auth.signOut();
}