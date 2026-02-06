import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. അക്കാദമിക് വർഷങ്ങൾ ലഭിക്കാൻ
  Stream<QuerySnapshot> getAcademicYears() {
    return _db.collection('academic_years').orderBy('startDate', descending: true).snapshots();
  }

  // 2. കുട്ടിയുടെ പ്രൊഫൈൽ ലഭിക്കാൻ
  Stream<DocumentSnapshot> getStudentProfile(String studentId) {
    return _db.collection('students').doc(studentId).snapshots();
  }

  // 3. ഫീസ് വിവരങ്ങൾ (സെലക്ട് ചെയ്ത വർഷത്തെ മാത്രം)
  Stream<QuerySnapshot> getFeeRecords(String studentId, String academicYearId) {
    return _db.collection('fees_collected')
        .where('studentId', isEqualTo: studentId)
        .where('academicYearId', isEqualTo: academicYearId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // 4. അസൈൻ ചെയ്ത ഫീസ് (Fee Structure for Class)
  // കുട്ടിക്ക് എത്ര രൂപ അടയ്ക്കാനുണ്ട് എന്ന് അറിയാൻ
  Future<List<Map<String, dynamic>>> getAssignedFees(String className) async {
    // ഇവിടെ ലോജിക് പിന്നീട് വിപുലീകരിക്കാം. ഇപ്പോൾ ഫീസ് സ്ട്രക്ചർ മൊത്തം എടുക്കുന്നു.
    // യഥാർത്ഥത്തിൽ 'Fee Assignment' ടാബ് അഡ്മിനിൽ വന്നാൽ അവിടെ നിന്നാണ് എടുക്കേണ്ടത്.
    final snapshot = await _db.collection('fee_structures').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // 5. നോട്ടീസുകൾ
  Stream<QuerySnapshot> getNotices() {
    return _db.collection('notices').orderBy('date', descending: true).snapshots();
  }
}