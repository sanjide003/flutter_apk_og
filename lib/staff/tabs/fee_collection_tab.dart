import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/staff_service.dart';

class FeeCollectionTab extends StatefulWidget {
  const FeeCollectionTab({super.key});

  @override
  State<FeeCollectionTab> createState() => _FeeCollectionTabState();
}

class _FeeCollectionTabState extends State<FeeCollectionTab> {
  final StaffService _service = StaffService();
  
  // Selections
  String? _selectedClass;
  String _selectedGender = "Male";
  Map<String, dynamic>? _selectedStudent;
  
  // Controllers
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  
  // Data
  List<Map<String, dynamic>> _studentsList = [];
  List<Map<String, dynamic>> _feeTypes = [];
  String? _selectedFeeType;
  bool _isLoadingStudent = false;

  @override
  void initState() {
    super.initState();
    _loadFeeStructures();
  }

  void _loadFeeStructures() async {
    var fees = await _service.getFeeStructures();
    if (mounted) {
      setState(() {
        _feeTypes = fees;
      });
    }
  }

  // കുട്ടികളെ തിരയുന്നു
  void _fetchStudents() async {
    if (_selectedClass == null) return;
    setState(() => _isLoadingStudent = true);
    
    var students = await _service.searchStudents(_selectedClass!, _selectedGender);
    
    if (mounted) {
      setState(() {
        _studentsList = students;
        _selectedStudent = null; // Reset selection
        _isLoadingStudent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Student", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                const SizedBox(height: 15),
                
                // 1. CLASS & GENDER ROW
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _service.getClasses(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                          return DropdownButtonFormField<String>(
                            value: _selectedClass,
                            decoration: const InputDecoration(labelText: "Class", border: OutlineInputBorder()),
                            items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              setState(() => _selectedClass = val);
                              _fetchStudents(); // ക്ലാസ് മാറുമ്പോൾ കുട്ടികളെ വിളിക്കുന്നു
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                        items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) {
                          setState(() => _selectedGender = val!);
                          _fetchStudents(); // ജെൻഡർ മാറുമ്പോൾ കുട്ടികളെ വിളിക്കുന്നു
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),

                // 2. STUDENT SEARCH DROPDOWN
                _isLoadingStudent 
                  ? const Center(child: LinearProgressIndicator()) 
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedStudent,
                      decoration: const InputDecoration(labelText: "Select Student Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_search)),
                      items: _studentsList.map((s) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: s,
                          child: Text("${s['name']} (Adm: ${s['serialNo']})"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedStudent = val;
                        });
                      },
                      hint: const Text("Choose a student"),
                    ),

                const Divider(height: 30),
                const Text("Payment Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                const SizedBox(height: 15),

                // 3. RECEIPT NO (AUTO)
                FutureBuilder<int>(
                  future: _service.getNextReceiptNo(),
                  builder: (context, snapshot) {
                    return TextField(
                      enabled: false, // Read only
                      decoration: InputDecoration(
                        labelText: "Receipt No (Auto)", 
                        hintText: snapshot.hasData ? "${snapshot.data}" : "Loading...",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade200
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),

                // 4. FEE ITEM
                DropdownButtonFormField<String>(
                  value: _selectedFeeType,
                  decoration: const InputDecoration(labelText: "Select Fee Item", border: OutlineInputBorder()),
                  items: _feeTypes.map((f) => DropdownMenuItem<String>(
                    value: f['name'],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(f['name']),
                        Text("₹${f['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedFeeType = val;
                      // തുക ഓട്ടോമാറ്റിക് ആയി വരുന്നു
                      var fee = _feeTypes.firstWhere((f) => f['name'] == val);
                      _amountCtrl.text = fee['amount'].toString();
                    });
                  },
                ),

                const SizedBox(height: 15),

                // 5. AMOUNT & REMARKS
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Total Amount (₹)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _remarksCtrl,
                  decoration: const InputDecoration(labelText: "Remarks (Optional)", border: OutlineInputBorder()),
                ),

                const SizedBox(height: 25),

                // 6. SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _savePayment,
                    icon: const Icon(Icons.save),
                    label: const Text("COLLECT FEE & GENERATE RECEIPT"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _savePayment() {
    if (_selectedStudent == null || _selectedFeeType == null || _amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    // Confirmation
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text("Collect ₹${_amountCtrl.text} from ${_selectedStudent!['name']} for $_selectedFeeType?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Get current user (Staff)
              User? user = FirebaseAuth.instance.currentUser;
              
              // Save Logic
              await _service.collectFee(
                studentId: _selectedStudent!['id'], // Doc ID from Search
                studentName: _selectedStudent!['name'],
                className: _selectedClass!,
                feeName: _selectedFeeType!,
                amount: double.tryParse(_amountCtrl.text) ?? 0,
                staffId: user?.uid ?? "unknown",
                staffName: user?.displayName ?? "Staff", // പേര് കിട്ടാൻ ലോഗിൻ ലോജിക് നന്നാക്കണം
                remarks: _remarksCtrl.text
              );

              // Reset Form
              setState(() {
                _selectedStudent = null;
                _selectedFeeType = null;
                _amountCtrl.clear();
                _remarksCtrl.clear();
              });

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Receipt Generated Successfully!"), backgroundColor: Colors.green));
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}