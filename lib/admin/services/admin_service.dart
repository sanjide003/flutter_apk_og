import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. ACADEMIACADEMICC YEAR ---
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
  Stream<QuerySnapshot> getAcademicYears() => _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();

  // --- 2. HR MANAGEMENT ---
  Future<void> addStaffMember({
    required String name, required String phone, required String password,
    required String category, required String role, required String address,
    required String photoUrl, String? msrNumber, String? email,
  }) async {
    String systemRole = category == 'management' ? 'admin' : 'staff';
    await _db.collection('users').add({
      'name': name, 'phone': phone, 'password': password, 'category': category,
      'role': systemRole, 'designation': role, 'address': address,
      'photoUrl': photoUrl, 'msrNumber': msrNumber ?? "", 'email': email ?? "",
      'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async => await _db.collection('users').doc(docId).update(data);
  Future<void> deleteStaff(String docId) async => await _db.collection('users').doc(docId).delete();
  Stream<QuerySnapshot> getStaffList() => _db.collection('users').orderBy('createdAt', descending: true).snapshots();

  // --- 3. STUDENT MANAGEMENT (ADVANCED LOGIC) ---

  // ലോജിക്: ഓരോ ക്ലാസ്സിലെയും ഓരോ ജെൻഡറിനും ക്രമനമ്പർ 1 ൽ തുടങ്ങണം.
  // ഉദാഹരണത്തിന്: 10A - Male - 1, 10A - Male - 2, 10A - Female - 1...
  Future<int> _generateNextSerialNo(String className, String gender) async {
    final snapshot = await _db.collection('students')
        .where('className', isEqualTo: className)
        .where('gender', isEqualTo: gender)
        .get();
    
    // നിലവിലുള്ള എണ്ണം എടുക്കുന്നു + 1
    return snapshot.docs.length + 1;
  }

  // Add Single Student
  Future<void> addStudent({
    required String name,
    required String gender,
    required String className,
    String? parentName,
    String? uidNumber,
    String? phone,
    String? address,
  }) async {
    // 1. സീരിയൽ നമ്പർ കണ്ടുപിടിക്കുന്നു
    int serialNo = await _generateNextSerialNo(className, gender);

    await _db.collection('students').add({
      'serialNo': serialNo, // ഓട്ടോമാറ്റിക് ക്രമനമ്പർ
      'name': name,
      'gender': gender,
      'className': className,
      'parentName': parentName ?? "",
      'uidNumber': uidNumber ?? "",
      'phone': phone ?? "",
      'address': address ?? "",
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update Student
  Future<void> updateStudent(String docId, Map<String, dynamic> data) async {
    await _db.collection('students').doc(docId).update(data);
  }

  // Delete Student
  Future<void> deleteStudent(String docId) async {
    await _db.collection('students').doc(docId).delete();
  }

  // Bulk Add Students (Updated)
  // Data format expected: Name, ParentName, Phone, UID, Address (Comma separated or just Name)
  Future<void> addBulkStudents(String className, String gender, List<String> lines) async {
    final batch = _db.batch();
    
    // നിലവിലെ സീരിയൽ നമ്പർ എടുക്കുന്നു
    int currentSerial = await _generateNextSerialNo(className, gender);

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      // കോമ ഇട്ട് തിരിച്ചാണ് ഡാറ്റ എങ്കിൽ (CSV Style)
      List<String> parts = line.split(',');
      
      String name = parts[0].trim();
      String parent = parts.length > 1 ? parts[1].trim() : "";
      String phone = parts.length > 2 ? parts[2].trim() : "";
      String uid = parts.length > 3 ? parts[3].trim() : "";
      String address = parts.length > 4 ? parts[4].trim() : "";

      var docRef = _db.collection('students').doc();
      
      batch.set(docRef, {
        'serialNo': currentSerial,
        'name': name,
        'className': className,
        'gender': gender,
        'parentName': parent,
        'phone': phone,
        'uidNumber': uid,
        'address': address,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      currentSerial++; // അടുത്ത കുട്ടിക്ക് നമ്പർ കൂട്ടുന്നു
    }
    await batch.commit();
  }
  
  // ഓർഡർ ചെയ്യുന്നത്: ക്ലാസ്സ് -> ജെൻഡർ -> ക്രമനമ്പർ
  Stream<QuerySnapshot> getStudents() {
    return _db.collection('students')
        .orderBy('className')
        .orderBy('gender')
        .orderBy('serialNo')
        .snapshots();
  }

  // --- 4. FEE STRUCTURE ---
  Future<void> addFeeStructure(String name, double amount, String type) async {
    await _db.collection('fee_structures').add({'name': name, 'amount': amount, 'type': type, 'createdAt': FieldValue.serverTimestamp()});
  }
  Future<void> deleteFeeStructure(String docId) async => await _db.collection('fee_structures').doc(docId).delete();
  Stream<QuerySnapshot> getFeeStructures() => _db.collection('fee_structures').snapshots();

  // --- 5. NOTICES ---
  Future<void> addNotice(String title, String description, String target) async {
    await _db.collection('notices').add({'title': title, 'description': description, 'target': target, 'date': FieldValue.serverTimestamp()});
  }
  Stream<QuerySnapshot> getNotices() => _db.collection('notices').orderBy('date', descending: true).snapshots();

  // --- 6. PUBLIC CONTENT ---
  Future<void> addGalleryImage(String url, String caption) async {
    await _db.collection('gallery').add({'imageUrl': url, 'caption': caption, 'createdAt': FieldValue.serverTimestamp()});
  }
  Stream<QuerySnapshot> getGallery() => _db.collection('gallery').orderBy('createdAt', descending: true).snapshots();
}