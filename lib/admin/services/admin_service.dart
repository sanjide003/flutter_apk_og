import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ACADEMIC YEAR MANAGEMENT ---

  // 1. Add Year
  Future<void> addAcademicYear(String name, DateTime start, DateTime end) async {
    // പുതിയത് ചേർക്കുമ്പോൾ അത് ഓട്ടോമാറ്റിക് ആയി ആക്ടീവ് ആക്കുന്നു
    await _deactivateAllYears();
    await _db.collection('academic_years').add({
      'name': name,
      'startDate': start,
      'endDate': end,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Update Year (Edit)
  Future<void> updateAcademicYear(String docId, String name, DateTime start, DateTime end) async {
    await _db.collection('academic_years').doc(docId).update({
      'name': name,
      'startDate': start,
      'endDate': end,
    });
  }

  // 3. Delete Year
  Future<void> deleteAcademicYear(String docId) async {
    await _db.collection('academic_years').doc(docId).delete();
  }

  // 4. Set Active Year (Toggle)
  Future<void> setAcademicYearActive(String docId) async {
    // ബാക്കിയുള്ളവ എല്ലാം Deactivate ചെയ്യുന്നു
    await _deactivateAllYears();
    // ഒരെണ്ണം മാത്രം Activate ചെയ്യുന്നു
    await _db.collection('academic_years').doc(docId).update({'isActive': true});
  }

  // Helper: Deactivate All
  Future<void> _deactivateAllYears() async {
    final activeYears = await _db.collection('academic_years')
        .where('isActive', isEqualTo: true)
        .get();
    for (var doc in activeYears.docs) {
      await doc.reference.update({'isActive': false});
    }
  }

  Stream<QuerySnapshot> getAcademicYears() {
    return _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();
  }

  // --- HR MANAGEMENT (STAFF & MGMT) ---

  // 5. Add Staff/Management (Updated with Full Details)
  Future<void> addStaffMember({
    required String name,
    required String phone, // Used as Password
    required String category, // 'management' or 'staff' (Radio Button)
    required String role, // Custom Input (e.g. Principal, Clerk)
    required String address,
    required String photoUrl,
    String? msrNumber, // Only for Staff
    String? email, 
  }) async {
    
    // System Role logic: Management -> admin, Staff -> staff
    String systemRole = category == 'management' ? 'admin' : 'staff';

    await _db.collection('users').add({
      'name': name,
      'phone': phone,
      'password': phone, // Phone itself is the password
      'category': category, // 'management' or 'staff'
      'role': systemRole, // 'admin' or 'staff' (For app logic)
      'designation': role, // Display Role (e.g. "Maths Teacher")
      'address': address,
      'photoUrl': photoUrl,
      'msrNumber': msrNumber ?? "", // Empty if management
      'email': email ?? "",
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 6. Update Staff
  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(docId).update(data);
  }

  // 7. Delete Staff
  Future<void> deleteStaff(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  Stream<QuerySnapshot> getStaffList() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  }
}