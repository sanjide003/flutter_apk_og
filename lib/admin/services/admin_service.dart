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

  // --- 3. STUDENT MANAGEMENT (AUTO SERIAL NO & BULK ADD) ---
  
  // Get Next Admission Number Logic
  Future<int> _getNextAdmNo() async {
    var doc = await _db.collection('counters').doc('students').get();
    if (!doc.exists) {
      await _db.collection('counters').doc('students').set({'count': 1000}); // Start from 1000
      return 1001;
    }
    return (doc.data()!['count'] as int) + 1;
  }

  // Increment Counter
  Future<void> _incrementAdmNo(int countToAdd) async {
    await _db.collection('counters').doc('students').update({
      'count': FieldValue.increment(countToAdd)
    });
  }

  Future<void> addStudent({
    required String name, required String gender, required String className,
    String? parentName, String? uidNumber, String? phone, String? address,
  }) async {
    int admNo = await _getNextAdmNo();
    await _db.collection('students').add({
      'admissionNumber': admNo.toString(),
      'name': name, 'gender': gender, 'className': className,
      'parentName': parentName ?? "", 'uidNumber': uidNumber ?? "",
      'phone': phone ?? "", 'address': address ?? "",
      'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
    await _incrementAdmNo(1);
  }

  Future<void> addBulkStudents(String className, String gender, List<String> names) async {
    int startAdmNo = await _getNextAdmNo();
    final batch = _db.batch();
    
    for (int i = 0; i < names.length; i++) {
      var docRef = _db.collection('students').doc();
      batch.set(docRef, {
        'admissionNumber': (startAdmNo + i).toString(),
        'name': names[i].trim(),
        'className': className,
        'gender': gender,
        'parentName': "", 'uidNumber': "", 'phone': "", 'address': "", // Empty optionals
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    await _incrementAdmNo(names.length);
  }
  
  Stream<QuerySnapshot> getStudents() => _db.collection('students').orderBy('createdAt', descending: true).snapshots();

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

  // --- 6. PUBLIC CONTENT (GALLERY) ---
  Future<void> addGalleryImage(String url, String caption) async {
    await _db.collection('gallery').add({'imageUrl': url, 'caption': caption, 'createdAt': FieldValue.serverTimestamp()});
  }
  Stream<QuerySnapshot> getGallery() => _db.collection('gallery').orderBy('createdAt', descending: true).snapshots();
}