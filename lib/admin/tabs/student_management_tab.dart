import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class StudentManagementTab extends StatefulWidget {
  const StudentManagementTab({super.key});

  @override
  State<StudentManagementTab> createState() => _StudentManagementTabState();
}

class _StudentManagementTabState extends State<StudentManagementTab> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Student...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white, filled: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allStudents = snapshot.data!.docs;
                var filteredStudents = allStudents.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredStudents.isEmpty) return const Center(child: Text("No Students Added"));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    var data = filteredStudents[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(data['admissionNumber'].toString().substring(data['admissionNumber'].toString().length - 2), 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Class: ${data['className']} • Adm No: ${data['admissionNumber']}"),
                        trailing: Text(data['gender'] == 'Male' ? 'M' : 'F', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "bulk",
            onPressed: _showBulkAddDialog,
            label: const Text("Bulk Add (Copy-Paste)"),
            icon: const Icon(Icons.copy),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "single",
            onPressed: _showAddStudentDialog,
            label: const Text("Add Single Student"),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String gender = "Male";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Student"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Mandatory Fields", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name *")),
                TextField(controller: classCtrl, decoration: const InputDecoration(labelText: "Class *")),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => gender = v!),
                  decoration: const InputDecoration(labelText: "Gender *"),
                ),
                const Divider(height: 30),
                const Text("Optional Fields", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: "Parent Name")),
                TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: "UID Number")),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone"), keyboardType: TextInputType.phone),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && classCtrl.text.isNotEmpty) {
                  _adminService.addStudent(
                    name: nameCtrl.text, className: classCtrl.text, gender: gender,
                    parentName: parentCtrl.text, uidNumber: uidCtrl.text, phone: phoneCtrl.text, address: addressCtrl.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkAddDialog() {
    final dataCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    String gender = "Male";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Bulk Add Students"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: classCtrl, decoration: const InputDecoration(labelText: "Class (For all names below)")),
              DropdownButtonFormField<String>(
                  value: gender,
                  items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => gender = v!),
                  decoration: const InputDecoration(labelText: "Gender (For all names below)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dataCtrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: "Paste Names Here (One per line)\nExample:\nArjun\nRahul\n...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (classCtrl.text.isNotEmpty && dataCtrl.text.isNotEmpty) {
                  List<String> names = dataCtrl.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
                  _adminService.addBulkStudents(classCtrl.text, gender, names);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${names.length} Students Added!")));
                }
              },
              child: const Text("Add All"),
            ),
          ],
        ),
      ),
    );
  }
}