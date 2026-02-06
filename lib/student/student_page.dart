import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/student_service.dart';
import 'tabs/student_dashboard_tab.dart';
import 'tabs/student_fees_tab.dart';
import 'tabs/student_profile_tab.dart';
import 'tabs/student_notices_tab.dart';

class StudentPage extends StatefulWidget {
  // ലോഗിൻ പേജിൽ നിന്ന് കുട്ടിയുടെ ID ഇങ്ങോട്ട് പാസ്സ് ചെയ്യണം
  final String studentId; 
  final String studentName;

  const StudentPage({super.key, required this.studentId, required this.studentName});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final StudentService _studentService = StudentService();
  
  int _selectedIndex = 0;
  String? _selectedYearId; // നിലവിൽ തിരഞ്ഞെടുത്ത വർഷം
  String _selectedYearName = "Loading...";

  @override
  Widget build(BuildContext context) {
    // ടാബുകൾ (Selected Year പാസ്സ് ചെയ്യുന്നു)
    final List<Widget> _tabs = [
      StudentDashboardTab(studentId: widget.studentId, yearId: _selectedYearId),
      StudentFeesTab(studentId: widget.studentId, yearId: _selectedYearId),
      const StudentNoticesTab(), // നോട്ടീസ് എല്ലാ വർഷവും ഒന്നുതന്നെ
      StudentProfileTab(studentId: widget.studentId),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.studentName, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            
            // ACADEMIC YEAR DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: _studentService.getAcademicYears(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("Loading Year...", style: TextStyle(fontSize: 10, color: Colors.grey));
                
                var years = snapshot.data!.docs;
                
                // ആദ്യമായി ലോഡ് ചെയ്യുമ്പോൾ ലേറ്റസ്റ്റ് വർഷം സെലക്ട് ചെയ്യുന്നു
                if (_selectedYearId == null && years.isNotEmpty) {
                  // Active year or first year
                  var activeYear = years.firstWhere((y) => y['isActive'] == true, orElse: () => years.first);
                  _selectedYearId = activeYear.id;
                  _selectedYearName = activeYear['name'];
                }

                return DropdownButton<String>(
                  value: _selectedYearId,
                  underline: const SizedBox(), // വര ഒഴിവാക്കാൻ
                  icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.blue),
                  isDense: true,
                  style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYearId = newValue!;
                      _selectedYearName = years.firstWhere((y) => y.id == newValue)['name'];
                    });
                  },
                  items: years.map<DropdownMenuItem<String>>((DocumentSnapshot doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          )
        ],
      ),
      body: _selectedYearId == null 
          ? const Center(child: CircularProgressIndicator()) 
          : _tabs[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Fees"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Notices"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}