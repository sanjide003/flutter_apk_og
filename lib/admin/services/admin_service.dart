import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- DASHBOARD STATS ---
  Future<Map<String, dynamic>> getDashboardStats() async {
    // 1. Students Count
    var students = await _db.collection('students').where('isActive', isEqualTo: true).get();
    int totalStudents = students.docs.length;
    int male = students.docs.where((d) => d['gender'] == 'Male').length;
    int female = students.docs.where((d) => d['gender'] == 'Female').length;

    // 2. Staff Count
    var staff = await _db.collection('users').where('isActive', isEqualTo: true).get();
    int totalStaff = staff.docs.length;

    // 3. Monthly Collection
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    var fees = await _db.collection('fees_collected')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();
    
    double collected = 0;
    for (var doc in fees.docs) collected += (doc['amount'] ?? 0);

    return {
      'totalStudents': totalStudents,
      'male': male,
      'female': female,
      'totalStaff': totalStaff,
      'monthlyCollection': collected,
    };
  }

  // --- ACADEMIC YEAR --- (Existing Logic Kept)
  Future<void> addAcademicYear(String name, DateTime start, DateTime end) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').add({'name': name, 'startDate': start, 'endDate': end, 'isActive': true, 'createdAt': FieldValue.serverTimestamp()});
  }
  Future<void> setAcademicYearActive(String docId) async {
    await _deactivateAllYears();
    await _db.collection('academic_years').doc(docId).update({'isActive': true});
  }
  Future<void> _deactivateAllYears() async {
    final activeYears = await _db.collection('academic_years').where('isActive', isEqualTo: true).get();
    for (var doc in activeYears.docs) await doc.reference.update({'isActive': false});
  }
  Stream<QuerySnapshot> getAcademicYears() => _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();
  // ... (Delete/Update kept same)

  // --- HR MANAGEMENT --- (Updated Fields)
  Future<void> addStaffMember({required String name, required String category, required String role, String? username, String? password, String? phone, String? address, String? msrNumber, String? photoUrl}) async {
    String systemRole = category == 'management' ? 'admin' : 'staff';
    await _db.collection('users').add({
      'name': name, 'category': category, 'role': systemRole, 'designation': role,
      'username': username ?? "", 'password': password ?? "", 'phone': phone ?? "",
      'address': address ?? "", 'msrNumber': msrNumber ?? "", 'photoUrl': photoUrl ?? "",
      'isActive': true, 'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Stream<QuerySnapshot> getStaffList() => _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  Future<void> deleteStaff(String docId) async => await _db.collection('users').doc(docId).delete();
  Future<void> updateStaffMember(String docId, Map<String, dynamic> data) async => await _db.collection('users').doc(docId).update(data);

  // --- STUDENT MANAGEMENT --- (Bulk/Single/Class)
  Stream<QuerySnapshot> getClasses() => _db.collection('classes').orderBy('name').snapshots();
  Future<void> addClass(String className) async {
    // Check duplicate
    var exist = await _db.collection('classes').where('name', isEqualTo: className).get();
    if (exist.docs.isEmpty) await _db.collection('classes').add({'name': className, 'createdAt': FieldValue.serverTimestamp()});
  }
  Stream<QuerySnapshot> getStudents() => _db.collection('students').orderBy('createdAt', descending: true).snapshots();
  
  // (Add/Update/Delete/BulkAdd logic kept from previous step)
  Future<int> _generateNextSerialNo(String className, String gender) async {
    final snapshot = await _db.collection('students').where('className', isEqualTo: className).where('gender', isEqualTo: gender).get();
    return snapshot.docs.length + 1;
  }
  Future<void> addStudent({required String name, required String gender, required String className, String? parentName, String? uidNumber, String? phone, String? address}) async {
    int serialNo = await _generateNextSerialNo(className, gender);
    await _db.collection('students').add({'serialNo': serialNo, 'name': name, 'gender': gender, 'className': className, 'parentName': parentName??"", 'uidNumber': uidNumber??"", 'phone': phone??"", 'address': address??"", 'isActive': true, 'createdAt': FieldValue.serverTimestamp()});
  }
  // ... (Bulk add kept same)

  // --- FEE STRUCTURE (DEFAULT 12 MONTHS) ---
  Future<void> initDefaultFeeStructure(String academicYearId, double monthlyAmount) async {
    List<String> months = ["June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May"];
    final batch = _db.batch();
    for(int i=0; i<months.length; i++) {
      var ref = _db.collection('default_fees').doc();
      batch.set(ref, {
        'academicYearId': academicYearId,
        'month': months[i],
        'order': i+1,
        'amount': monthlyAmount,
        'type': 'Monthly'
      });
    }
    await batch.commit();
  }
  Stream<QuerySnapshot> getDefaultFees() => _db.collection('default_fees').orderBy('order').snapshots();
  
  // --- FEE CONCESSION / GROUPS ---
  Future<void> createStudentGroup(String groupName, List<String> studentIds) async {
    await _db.collection('student_groups').add({
      'name': groupName,
      'studentIds': studentIds,
      'createdAt': FieldValue.serverTimestamp()
    });
  }
  Stream<QuerySnapshot> getStudentGroups() => _db.collection('student_groups').snapshots();

  // --- REPORTS ---
  Future<List<Map<String, dynamic>>> getDailyReport(DateTime date) async {
    DateTime start = DateTime(date.year, date.month, date.day);
    DateTime end = start.add(const Duration(days: 1));
    
    var snapshot = await _db.collection('fees_collected')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();
        
    return snapshot.docs.map((d) => d.data()).toList();
  }
}