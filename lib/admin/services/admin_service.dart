// File: lib/admin/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// intl പാക്കേജ് ഇല്ലാത്തതുകൊണ്ട് ഡേറ്റ് ഫോർമാറ്റിംഗിന് തൽക്കാലം അത് ഒഴിവാക്കുന്നു
// അല്ലെങ്കിൽ pubspec.yaml-ൽ ചേർത്ത ശേഷം import 'package:intl/intl.dart'; ഉപയോഗിക്കാം.

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================================================
  // 1. DASHBOARD OVERVIEW
  // ==================================================
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      var students = await _db.collection('students').where('isActive', isEqualTo: true).get();
      int totalStudents = students.docs.length;
      int male = students.docs.where((d) => d['gender'] == 'Male').length;
      int female = students.docs.where((d) => d['gender'] == 'Female').length;

      var staff = await _db.collection('users').where('isActive', isEqualTo: true).get();
      int totalStaff = staff.docs.length;

      // ലളിതമായ ടോട്ടൽ കണക്ക്
      double collected = 0; // ഇവിടെ പിന്നീട് ഫീസ് കളക്ഷൻ ലോജിക് വെക്കാം

      return {
        'totalStudents': totalStudents,
        'male': male,
        'female': female,
        'totalStaff': totalStaff,
        'monthlyCollection': collected,
      };
    } catch (e) {
      return {'totalStudents': 0, 'male': 0, 'female': 0, 'totalStaff': 0, 'monthlyCollection': 0};
    }
  }

  // ==================================================
  // 2. ACADEMIC YEAR & CLASS MANAGEMENT
  // ==================================================
  Stream<QuerySnapshot> getAcademicYears() {
    return _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();
  }

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

  // (Error Fix: deleteAcademicYear missing)
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

  // Helper: Get Next Serial No for Students
  Future<int> _generateNextSerialNo(String className, String gender) async {
    final snapshot = await _db.collection('students')
        .where('className', isEqualTo: className)
        .where('gender', isEqualTo: gender)
        .get();
    return snapshot.docs.length + 1;
  }

  // (Error Fix: mergeClasses missing)
  Future<void> mergeClasses(String classA, String classB, String targetClass) async {
    // ക്ലാസ്സ് A യിലെയും B യിലെയും കുട്ടികളെ എടുക്കുന്നു
    final studentsA = await _db.collection('students').where('className', isEqualTo: classA).where('isActive', isEqualTo: true).get();
    final studentsB = await _db.collection('students').where('className', isEqualTo: classB).where('isActive', isEqualTo: true).get();
    
    List<QueryDocumentSnapshot> allStudents = [...studentsA.docs, ...studentsB.docs];
    final batch = _db.batch();
    
    // പുതിയ സീരിയൽ നമ്പർ
    int nextMaleSerial = await _generateNextSerialNo(targetClass, "Male");
    int nextFemaleSerial = await _generateNextSerialNo(targetClass, "Female");

    for (var doc in allStudents) {
      String gender = doc['gender'];
      int serialToUse = (gender == "Male") ? nextMaleSerial++ : nextFemaleSerial++;
      
      batch.update(doc.reference, {
        'className': targetClass, 
        'serialNo': serialToUse
      });
    }
    await batch.commit();
  }

  // Split Logic (Placeholder for future)
  Future<void> moveSelectedStudents(List<String> studentIds, String targetClass) async {
    // Logic implementation
  }

  // ==================================================
  // 3. HR MANAGEMENT (STAFF)
  // ==================================================
  Stream<QuerySnapshot> getStaffList() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addStaffMember({
    required String name, required String phone, required String password,
    required String category, required String role, required String address,
    required String photoUrl, String? msrNumber, String? email, String? username
  }) async {
    String systemRole = category == 'management' ? 'admin' : 'staff';
    await _db.collection('users').add({
      'name': name, 'phone': phone, 'password': password, 'username': username ?? "",
      'category': category, 'role': systemRole, 'designation': role,
      'address': address, 'photoUrl': photoUrl, 'msrNumber': msrNumber ?? "",
      'email': email ?? "", 'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(docId).update(data);
  }

  Future<void> deleteStaff(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  // (Error Fix: toggleUserStatus missing)
  Future<void> toggleUserStatus(String docId, bool currentStatus) async {
    await _db.collection('users').doc(docId).update({'isActive': !currentStatus});
  }

  // ==================================================
  // 4. STUDENT MANAGEMENT
  // ==================================================
  Stream<QuerySnapshot> getClasses() {
    return _db.collection('classes').orderBy('name').snapshots();
  }

  Future<void> addClass(String className) async {
    await _db.collection('classes').add({
      'name': className,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getStudents() {
    // ലളിതമായ സോർട്ടിംഗ് (എറർ ഒഴിവാക്കാൻ)
    return _db.collection('students').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addStudent({
    required String name, required String gender, required String className,
    String? parentName, String? uidNumber, String? phone, String? address,
  }) async {
    int serialNo = await _generateNextSerialNo(className, gender);
    await _db.collection('students').add({
      'serialNo': serialNo, 'name': name, 'gender': gender, 'className': className,
      'parentName': parentName ?? "", 'uidNumber': uidNumber ?? "", 'phone': phone ?? "",
      'address': address ?? "", 'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // (Error Fix: updateStudent missing)
  Future<void> updateStudent(String docId, Map<String, dynamic> data) async {
    await _db.collection('students').doc(docId).update(data);
  }

  Future<void> deleteStudent(String docId) async {
    await _db.collection('students').doc(docId).delete();
  }

  // (Error Fix: deleteBulkStudents missing)
  Future<void> deleteBulkStudents(List<String> docIds) async {
    final batch = _db.batch();
    for (var id in docIds) {
      batch.delete(_db.collection('students').doc(id));
    }
    await batch.commit();
  }

  // (Error Fix: addBulkStudents missing)
  Future<void> addBulkStudents(String className, String gender, List<Map<String, String>> studentsData) async {
    final batch = _db.batch();
    int currentSerial = await _generateNextSerialNo(className, gender);

    for (var student in studentsData) {
      var docRef = _db.collection('students').doc();
      batch.set(docRef, {
        'serialNo': currentSerial,
        'className': className,
        'gender': gender,
        'name': student['name'] ?? "",
        'parentName': student['parent'] ?? "",
        'phone': student['phone'] ?? "",
        'uidNumber': student['uid'] ?? "",
        'address': student['address'] ?? "",
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      currentSerial++;
    }
    await batch.commit();
  }

  // ==================================================
  // 5. FEE & NOTICES
  // ==================================================
  Stream<QuerySnapshot> getFeeStructures() => _db.collection('fee_structures').snapshots();

  Future<void> addFeeStructure(String name, double amount, String type) async {
    await _db.collection('fee_structures').add({
      'name': name, 'amount': amount, 'type': type, 'createdAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> deleteFeeStructure(String docId) async {
    await _db.collection('fee_structures').doc(docId).delete();
  }

  // (Error Fix: getNotices & addNotice missing)
  Stream<QuerySnapshot> getNotices() {
    return _db.collection('notices').orderBy('date', descending: true).snapshots();
  }

  Future<void> addNotice(String title, String description, String target) async {
    await _db.collection('notices').add({
      'title': title,
      'description': description,
      'target': target,
      'date': FieldValue.serverTimestamp()
    });
  }
}