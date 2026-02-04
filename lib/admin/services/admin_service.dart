import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ACADEMIC YEAR MANAGEMENT ---

  // 1. പുതിയ വർഷം ചേർക്കാൻ
  Future<void> addAcademicYear(String name, DateTime start, DateTime end) async {
    // ആദ്യം മറ്റെല്ലാ വർഷത്തെയും 'Active' മാറ്റുന്നു (ഒരേ സമയം ഒന്ന് മാത്രം ആക്ടീവ്)
    await _deactivateAllYears();

    await _db.collection('academic_years').add({
      'name': name, // Ex: "2025-2026"
      'startDate': start,
      'endDate': end,
      'isActive': true, // പുതിയത് ചേർക്കുമ്പോൾ അത് ആക്ടീവ് ആകുന്നു
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. എല്ലാ വർഷങ്ങളും ഇനാക്ടീവ് ആക്കാൻ (Helper function)
  Future<void> _deactivateAllYears() async {
    final activeYears = await _db.collection('academic_years')
        .where('isActive', isEqualTo: true)
        .get();
    
    for (var doc in activeYears.docs) {
      await doc.reference.update({'isActive': false});
    }
  }

  // 3. വർഷങ്ങളുടെ ലിസ്റ്റ് എടുക്കാൻ (Stream)
  Stream<QuerySnapshot> getAcademicYears() {
    return _db.collection('academic_years')
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  // --- HR MANAGEMENT (STAFF & MGMT) ---

  // 4. പുതിയ സ്റ്റാഫിനെ ചേർക്കാൻ
  Future<void> addStaffMember({
    required String name,
    required String phone,
    required String role, // 'admin' or 'staff'
    required String designation, // 'Teacher', 'Clerk', 'Principal'
    required String email, // Login Email
    required String password, // Login Password (For reference or manual creation)
  }) async {
    
    await _db.collection('users').add({
      'name': name,
      'phone': phone,
      'role': role,
      'designation': designation,
      'email': email,
      'password': password, // ശ്രദ്ധിക്കുക: റിയൽ ആപ്പിൽ പാസ്‌വേഡ് ഇങ്ങനെ സേവ് ചെയ്യരുത്.
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 5. സ്റ്റാഫ് ലിസ്റ്റ് എടുക്കാൻ
  Stream<QuerySnapshot> getStaffList() {
    return _db.collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // 6. സ്റ്റാഫിനെ ഡിലീറ്റ് ചെയ്യാൻ
  Future<void> deleteStaff(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }
}
