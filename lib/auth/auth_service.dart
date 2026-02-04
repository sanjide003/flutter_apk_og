import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. ലോഗിൻ പേജിലെ ലിസ്റ്റിലേക്ക് സ്റ്റാഫുകളെ വിളിക്കുന്നു
  Future<List<String>> getStaffList() async {
    try {
      // 'users' കളക്ഷനിൽ നിന്നും സ്റ്റാഫിനെ എടുക്കുന്നു
      // (role: admin or staff)
      final snapshot = await _db.collection('users')
          .where('role', whereIn: ['admin', 'staff'])
          .get();

      List<String> staffNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
      
      // ഡാറ്റാബേസ് ശൂന്യമാണെങ്കിൽ (ആദ്യത്തെ തവണ) അഡ്മിനെ കാണിക്കാൻ
      if (staffNames.isEmpty) {
        return ["Principal User"]; 
      }
      
      // അല്ലെങ്കിൽ ലിസ്റ്റിലേക്ക് "Principal User" കൂടി ചേർക്കുക (എപ്പോഴും ലോഗിൻ ചെയ്യാൻ)
      if (!staffNames.contains("Principal User")) {
        staffNames.insert(0, "Principal User");
      }
      
      return staffNames;
    } catch (e) {
      print("Error fetching staff: $e");
      // എറർ വന്നാൽ അഡ്മിൻ പേര് മാത്രം കാണിക്കും
      return ["Principal User"];
    }
  }

  // 2. ക്ലാസ്സുകൾ എടുക്കുന്നു (ഇപ്പോൾ ശൂന്യമായിരിക്കും)
  Future<List<String>> getClasses() async {
    try {
      final snapshot = await _db.collection('academic_years')
          .where('isActive', isEqualTo: true)
          .get();
      
      // ഇവിടെ ലോജിക് പിന്നീട് എഴുതാം, ഇപ്പോൾ Empty List
      return []; 
    } catch (e) {
      return [];
    }
  }

  // 3. സ്റ്റാഫ് ലോഗിൻ (Real Auth)
  Future<String> loginStaff(String name, String password) async {
    try {
      String email = "";

      // കേസ് 1: അഡ്മിൻ (Principal User)
      if (name == "Principal User") {
        email = "dsd003@gmail.com";
      } 
      // കേസ് 2: മറ്റ് സ്റ്റാഫുകൾ (Database-ൽ നിന്ന് ഇമെയിൽ കണ്ടുപിടിക്കുന്നു)
      else {
        final snapshot = await _db.collection('users')
            .where('name', isEqualTo: name)
            .limit(1)
            .get();
            
        if (snapshot.docs.isEmpty) {
          throw Exception("User not found in database");
        }
        email = snapshot.docs.first['email'];
      }

      // ഫയർബേസ് ഓതന്റിക്കേഷൻ
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // വിജയിച്ചാൽ റോൾ തിരിച്ചയക്കുന്നു
      if (name == "Principal User") return "admin";
      
      // മറ്റുള്ളവരുടെ റോൾ ചെക്ക് ചെയ്യുന്നു (ബാക്കി കോഡ് പിന്നീട്)
      return "staff";

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 4. ലോഗൗട്ട്
  Future<void> logout() async {
    await _auth.signOut();
  }
}
