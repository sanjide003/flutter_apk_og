import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CLASS & ACADEMIC YEAR UTILS ---
  Stream<QuerySnapshot> getClasses() {
    return _db.collection('classes').orderBy('name').snapshots();
  }

  Future<void> addClass(String className) async {
    await _db.collection('classes').add({
      'name': className,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAcademicYears() => _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();

  Future<void> addAcademicYear(String name, DateTime start, DateTime end) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').add({
      'name': name, 'startDate': start, 'endDate': end, 'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAcademicYear(String docId, String name, DateTime start, DateTime end) async {
    await _db.collection('academic_years').doc(docId).update({'name': name, 'startDate': start, 'endDate': end});
  }

  Future<void> deleteAcademicYear(String docId) async => await _db.collection('academic_years').doc(docId).delete();

  Future<void> setAcademicYearActive(String docId) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').doc(docId).update({'isActive': true});
  }

  Future<void> _deactivateAllYears() async {
    final activeYears = await _db.collection('academic_years').where('isActive', isEqualTo: true).get();
    for (var doc in activeYears.docs) await doc.reference.update({'isActive': false});
  }

  // --- SMART SERIAL NUMBER GENERATOR ---
  Future<int> _generateNextSerialNo(String className, String gender) async {
    final snapshot = await _db.collection('students')
        .where('className', isEqualTo: className)
        .where('gender', isEqualTo: gender)
        .get();
    return snapshot.docs.length + 1;
  }

  // --- PROMOTION & CLASS OPS ---
  Future<void> promoteClassBatch({required String currentClassName, required String targetClassName, required String targetYearId}) async {
    final batch = _db.batch();
    final studentsSnapshot = await _db.collection('students').where('className', isEqualTo: currentClassName).where('isActive', isEqualTo: true).get();
    int nextMaleSerial = await _generateNextSerialNo(targetClassName, "Male");
    int nextFemaleSerial = await _generateNextSerialNo(targetClassName, "Female");

    for (var doc in studentsSnapshot.docs) {
      var data = doc.data();
      String gender = data['gender'];
      var newDocRef = _db.collection('students').doc();
      int serialToUse = (gender == "Male") ? nextMaleSerial++ : nextFemaleSerial++;

      batch.set(newDocRef, {
        ...data, 'className': targetClassName, 'academicYearId': targetYearId, 'serialNo': serialToUse, 'promotedFrom': doc.id, 'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> mergeClasses(String classA, String classB, String targetClass) async {
    final studentsA = await _db.collection('students').where('className', isEqualTo: classA).where('isActive', isEqualTo: true).get();
    final studentsB = await _db.collection('students').where('className', isEqualTo: classB).where('isActive', isEqualTo: true).get();
    List<QueryDocumentSnapshot> allStudents = [...studentsA.docs, ...studentsB.docs];
    final batch = _db.batch();
    int nextMaleSerial = await _generateNextSerialNo(targetClass, "Male");
    int nextFemaleSerial = await _generateNextSerialNo(targetClass, "Female");

    for (var doc in allStudents) {
      String gender = doc['gender'];
      int serialToUse = (gender == "Male") ? nextMaleSerial++ : nextFemaleSerial++;
      batch.update(doc.reference, {'className': targetClass, 'serialNo': serialToUse});
    }
    await batch.commit();
  }

  Future<void> moveSelectedStudents(List<String> studentIds, String targetClass) async {
    final batch = _db.batch();
    int nextMaleSerial = await _generateNextSerialNo(targetClass, "Male");
    int nextFemaleSerial = await _generateNextSerialNo(targetClass, "Female");

    for (String id in studentIds) {
      var doc = await _db.collection('students').doc(id).get();
      if (!doc.exists) continue;
      String gender = doc['gender'];
      int serialToUse = (gender == "Male") ? nextMaleSerial++ : nextFemaleSerial++;
      batch.update(doc.reference, {'className': targetClass, 'serialNo': serialToUse});
    }
    await batch.commit();
  }

  // --- STUDENT MANAGEMENT ---
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

  // --- FIX: SIMPLIFIED QUERY ---
  // സങ്കീർണ്ണമായ orderBy ഒഴിവാക്കി, ആപ്പിനുള്ളിൽ സോർട്ട് ചെയ്യുന്നു
  Stream<QuerySnapshot> getStudents() {
    return _db.collection('students')
        .orderBy('createdAt', descending: true) 
        .snapshots();
  }
  
  // --- OTHER ---
  Future<void> addStaffMember({required String name, required String phone, required String password, required String category, required String role, required String address, required String photoUrl, String? msrNumber, String? email}) async {
    String systemRole = category == 'management' ? 'admin' : 'staff';
    await _db.collection('users').add({ 'name': name, 'phone': phone, 'password': password, 'category': category, 'role': systemRole, 'designation': role, 'address': address, 'photoUrl': photoUrl, 'msrNumber': msrNumber ?? "", 'email': email ?? "", 'isActive': true, 'createdAt': FieldValue.serverTimestamp() });
  }
  Stream<QuerySnapshot> getStaffList() => _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  Future<void> deleteStaff(String docId) async => await _db.collection('users').doc(docId).delete();
  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async => await _db.collection('users').doc(docId).update(data);
  
  Future<void> addFeeStructure(String name, double amount, String type) async => await _db.collection('fee_structures').add({'name': name, 'amount': amount, 'type': type, 'createdAt': FieldValue.serverTimestamp()});
  Stream<QuerySnapshot> getFeeStructures() => _db.collection('fee_structures').snapshots();
  Future<void> deleteFeeStructure(String docId) async => await _db.collection('fee_structures').doc(docId).delete();
  Future<void> addNotice(String title, String description, String target) async => await _db.collection('notices').add({'title': title, 'description': description, 'target': target, 'date': FieldValue.serverTimestamp()});
  Stream<QuerySnapshot> getNotices() => _db.collection('notices').orderBy('date', descending: true).snapshots();
  Future<void> addGalleryImage(String url, String caption) async => await _db.collection('gallery').add({'imageUrl': url, 'caption': caption, 'createdAt': FieldValue.serverTimestamp()});
  Stream<QuerySnapshot> getGallery() => _db.collection('gallery').orderBy('createdAt', descending: true).snapshots();
}