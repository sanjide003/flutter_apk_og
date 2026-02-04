import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ACADEMIC YEAR MANAGEMANAGEMENTMENT ---
  
  Future<void> addAcademicYear(String name, DateTime start, DateTime end) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').add({
      'name': name,
      'startDate': start,
      'endDate': end,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAcademicYear(String docId, String name, DateTime start, DateTime end) async {
    await _db.collection('academic_years').doc(docId).update({
      'name': name,
      'startDate': start,
      'endDate': end,
    });
  }

  Future<void> deleteAcademicYear(String docId) async {
    await _db.collection('academic_years').doc(docId).delete();
  }

  Future<void> setAcademicYearActive(String docId) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').doc(docId).update({'isActive': true});
  }

  Future<void> _deactivateAllYears() async {
    final activeYears = await _db.collection('academic_years').where('isActive', isEqualTo: true).get();
    for (var doc in activeYears.docs) {
      await doc.reference.update({'isActive': false});
    }
  }

  Stream<QuerySnapshot> getAcademicYears() {
    return _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();
  }

  // --- HR MANAGEMENT (UPDATED) ---

  Future<void> addStaffMember({
    required String name,
    required String phone,
    required String password, // New Password Field
    required String category, 
    required String role, 
    required String address,
    required String photoUrl,
    String? msrNumber,
    String? email, 
  }) async {
    
    String systemRole = category == 'management' ? 'admin' : 'staff';

    await _db.collection('users').add({
      'name': name,
      'phone': phone,
      'password': password, // Saving the custom password
      'category': category,
      'role': systemRole,
      'designation': role,
      'address': address,
      'photoUrl': photoUrl,
      'msrNumber': msrNumber ?? "",
      'email': email ?? "",
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(docId).update(data);
  }

  Future<void> deleteStaff(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  Stream<QuerySnapshot> getStaffList() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  }
}