import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. HR MANAGEMENT (UPDATED) ---

  // Add Member with ALL Fields
  Future<void> addStaffMember({
    required String name,
    required String category, // 'staff' or 'management'
    required String role,     // e.g. "History Teacher"
    String? username,         // Gmail (Optional)
    String? password,         // Custom Password (Optional)
    String? phone,            // Contact (Optional)
    String? address,          // Address (Optional)
    String? msrNumber,        // Staff Only
    String? photoUrl,         // Optional
  }) async {
    
    // System Role for Login logic
    String systemRole = category == 'management' ? 'admin' : 'staff';

    await _db.collection('users').add({
      'name': name,
      'category': category,
      'role': systemRole,
      'designation': role,
      'username': username ?? "",
      'password': password ?? "", 
      'phone': phone ?? "",
      'address': address ?? "",
      'msrNumber': msrNumber ?? "",
      'photoUrl': photoUrl ?? "",
      'isActive': true, // Default Active
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update Member
  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(docId).update(data);
  }

  // Soft Delete / Deactivate (To preserve history)
  Future<void> toggleUserStatus(String docId, bool currentStatus) async {
    await _db.collection('users').doc(docId).update({'isActive': !currentStatus});
  }

  // Hard Delete (Only if really needed)
  Future<void> deleteStaff(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  // Get Staff List
  Stream<QuerySnapshot> getStaffList() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 2. STUDENT MANAGEMENT ---
  // (Existing functions kept as is)
  Stream<QuerySnapshot> getClasses() => _db.collection('classes').orderBy('name').snapshots();
  Future<void> addClass(String className) async => await _db.collection('classes').add({'name': className, 'createdAt': FieldValue.serverTimestamp()});
  
  Future<int> _generateNextSerialNo(String className, String gender) async {
    final snapshot = await _db.collection('students').where('className', isEqualTo: className).where('gender', isEqualTo: gender).get();
    return snapshot.docs.length + 1;
  }

  Future<void> addStudent({required String name, required String gender, required String className, String? parentName, String? uidNumber, String? phone, String? address}) async {
    int serialNo = await _generateNextSerialNo(className, gender);
    await _db.collection('students').add({
      'serialNo': serialNo, 'name': name, 'gender': gender, 'className': className,
      'parentName': parentName ?? "", 'uidNumber': uidNumber ?? "", 'phone': phone ?? "", 'address': address ?? "",
      'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Future<void> updateStudent(String docId, Map<String, dynamic> data) async => await _db.collection('students').doc(docId).update(data);
  Future<void> deleteStudent(String docId) async => await _db.collection('students').doc(docId).delete();
  
  Future<void> addBulkStudents(String className, String gender, List<Map<String, String>> studentsData) async {
    final batch = _db.batch();
    int currentSerial = await _generateNextSerialNo(className, gender);
    for (var student in studentsData) {
      var docRef = _db.collection('students').doc();
      batch.set(docRef, {
        'serialNo': currentSerial, 'className': className, 'gender': gender,
        'name': student['name'] ?? "", 'parentName': student['parent'] ?? "",
        'phone': student['phone'] ?? "", 'uidNumber': student['uid'] ?? "",
        'address': student['address'] ?? "",
        'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
      });
      currentSerial++;
    }
    await batch.commit();
  }
  Stream<QuerySnapshot> getStudents() => _db.collection('students').orderBy('createdAt', descending: true).snapshots();

  // --- 3. OTHER TABS (Existing) ---
  Future<void> addAcademicYear(String name, DateTime start, DateTime end) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').add({'name': name, 'startDate': start, 'endDate': end, 'isActive': true, 'createdAt': FieldValue.serverTimestamp()});
  }
  Future<void> updateAcademicYear(String docId, String name, DateTime start, DateTime end) async => await _db.collection('academic_years').doc(docId).update({'name': name, 'startDate': start, 'endDate': end});
  Future<void> deleteAcademicYear(String docId) async => await _db.collection('academic_years').doc(docId).delete();
  Future<void> setAcademicYearActive(String docId) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').doc(docId).update({'isActive': true});
  }
  Future<void> _deactivateAllYears() async {
    final activeYears = await _db.collection('academic_years').where('isActive', isEqualTo: true).get();
    for (var doc in activeYears.docs) await doc.reference.update({'isActive': false});
  }
  Stream<QuerySnapshot> getAcademicYears() => _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();
  
  Future<void> addFeeStructure(String name, double amount, String type) async => await _db.collection('fee_structures').add({'name': name, 'amount': amount, 'type': type, 'createdAt': FieldValue.serverTimestamp()});
  Stream<QuerySnapshot> getFeeStructures() => _db.collection('fee_structures').snapshots();
  Future<void> deleteFeeStructure(String docId) async => await _db.collection('fee_structures').doc(docId).delete();
  Future<void> addNotice(String title, String description, String target) async => await _db.collection('notices').add({'title': title, 'description': description, 'target': target, 'date': FieldValue.serverTimestamp()});
  Stream<QuerySnapshot> getNotices() => _db.collection('notices').orderBy('date', descending: true).snapshots();
  Future<void> addGalleryImage(String url, String caption) async => await _db.collection('gallery').add({'imageUrl': url, 'caption': caption, 'createdAt': FieldValue.serverTimestamp()});
  Stream<QuerySnapshot> getGallery() => _db.collection('gallery').orderBy('createdAt', descending: true).snapshots();
}