import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StaffService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. DASHBOARD DATA ---
  // ഇന്നത്തെ കളക്ഷൻ എടുക്കാൻ
  Stream<QuerySnapshot> getTodayCollection(String staffId) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day); // 12:00 AM
    
    return _db.collection('fees_collected')
        .where('collectedBy', isEqualTo: staffId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots();
  }

  // --- 2. FEE COLLECTION UTILS ---
  
  // ക്ലാസ്സുകൾ എടുക്കാൻ
  Stream<QuerySnapshot> getClasses() {
    return _db.collection('classes').orderBy('name').snapshots();
  }

  // കുട്ടികളെ തിരയാൻ (ഫീസ് അടയ്ക്കാനുള്ളവരെ)
  Future<List<Map<String, dynamic>>> searchStudents(String className, String gender) async {
    final snapshot = await _db.collection('students')
        .where('className', isEqualTo: className)
        .where('gender', isEqualTo: gender)
        .where('isActive', isEqualTo: true)
        .get();
        
    return snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id; // ID കൂടി ചേർക്കുന്നു
      return data;
    }).toList();
  }

  // ഫീസ് ഇനങ്ങൾ (Fee Structure) എടുക്കാൻ
  Future<List<Map<String, dynamic>>> getFeeStructures() async {
    final snapshot = await _db.collection('fee_structures').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ഓട്ടോമാറ്റിക് രസീത് നമ്പർ (Auto Increment)
  Future<int> getNextReceiptNo() async {
    var doc = await _db.collection('counters').doc('receipts').get();
    if (!doc.exists) {
      await _db.collection('counters').doc('receipts').set({'count': 100}); // Start from 100
      return 101;
    }
    return (doc.data()!['count'] as int) + 1;
  }

  // --- 3. SAVE PAYMENT (CORE FUNCTION) ---
  Future<void> collectFee({
    required String studentId,
    required String studentName,
    required String className,
    required String feeName, // Exam Fee, Tuition Fee etc.
    required double amount,
    required String staffId,
    required String staffName,
    String? remarks,
  }) async {
    int receiptNo = await getNextReceiptNo();
    
    await _db.collection('fees_collected').add({
      'receiptNo': receiptNo,
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'feeName': feeName,
      'amount': amount,
      'collectedBy': staffId, // Staff ID
      'collectedByName': staffName, // Staff Name
      'remarks': remarks ?? "",
      'date': FieldValue.serverTimestamp(),
      'searchDate': DateFormat('yyyy-MM-dd').format(DateTime.now()), // For easy filtering
    });

    // കൗണ്ടർ അപ്ഡേറ്റ് ചെയ്യുന്നു
    await _db.collection('counters').doc('receipts').update({
      'count': FieldValue.increment(1)
    });
  }

  // --- 4. HISTORY ---
  // സ്റ്റാഫിന്റെ പഴയ ഇടപാടുകൾ
  Stream<QuerySnapshot> getStaffTransactions(String staffId) {
    return _db.collection('fees_collected')
        .where('collectedBy', isEqualTo: staffId)
        .orderBy('date', descending: true)
        .snapshots();
  }
}