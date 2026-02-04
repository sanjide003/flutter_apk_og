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
  
  // Filters & Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedClassFilter;
  String? _selectedGenderFilter;

  // Mock Classes for Dropdown (Real implementation can fetch from DB)
  final List<String> _classes = ["Class 8 A", "Class 8 B", "Class 9 A", "Class 10 A", "+1 Science", "+2 Science"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- TOP SECTION (Search & Filter) ---
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                // 1. Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search Student Name...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
                const SizedBox(height: 10),
                
                // 2. Filters (Class & Gender)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClassFilter,
                        decoration: const InputDecoration(
                          labelText: "Filter Class",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text("All Classes")),
                          ..._classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                        ],
                        onChanged: (val) => setState(() => _selectedClassFilter = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGenderFilter,
                        decoration: const InputDecoration(
                          labelText: "Filter Gender",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text("All")),
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                          DropdownMenuItem(value: "Female", child: Text("Female")),
                        ],
                        onChanged: (val) => setState(() => _selectedGenderFilter = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- STUDENT LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allStudents = snapshot.data!.docs;
                
                // Filtering Logic
                var filteredStudents = allStudents.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  
                  // Search Filter
                  String name = (data['name'] ?? "").toString().toLowerCase();
                  if (!name.contains(_searchQuery)) return false;

                  // Class Filter
                  if (_selectedClassFilter != null && data['className'] != _selectedClassFilter) return false;

                  // Gender Filter
                  if (_selectedGenderFilter != null && data['gender'] != _selectedGenderFilter) return false;

                  return true;
                }).toList();

                if (filteredStudents.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 40, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No Students Found", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    var doc = filteredStudents[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isMale = data['gender'] == 'Male';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        // Avatar with Serial No
                        leading: CircleAvatar(
                          backgroundColor: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
                          child: Text(
                            "${data['serialNo']}", // ക്രമനമ്പർ
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: isMale ? Colors.blue.shade900 : Colors.pink.shade900
                            ),
                          ),
                        ),
                        title: Text(
                          data['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4)
                                  ),
                                  child: Text(data['className'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Icon(isMale ? Icons.male : Icons.female, size: 14, color: Colors.grey),
                                Text(" ${data['gender']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            if (data['parentName'] != null && data['parentName'].isNotEmpty)
                              Text("Parent: ${data['parentName']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        // 3-DOT MENU
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _showEditStudentDialog(doc.id, data);
                            if (value == 'delete') _confirmDelete(doc.id, data['name']);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "bulk",
            onPressed: _showBulkAddDialog,
            label: const Text("Bulk Add"),
            icon: const Icon(Icons.file_upload),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "single",
            onPressed: _showAddStudentDialog,
            label: const Text("Add Student"),
            icon: const Icon(Icons.person_add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  // --- DELETE CONFIRMATION ---
  void _confirmDelete(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Student?"),
        content: Text("Are you sure you want to delete '$name'? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () {
              _adminService.deleteStudent(docId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Deleted")));
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- SINGLE ADD DIALOG ---
  void _showAddStudentDialog() {
    // Controllers
    final nameCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    
    // Default Values
    String gender = "Male";
    String? selectedClass = _classes.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add New Student"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mandatory Fields", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // Class Selection
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => selectedClass = v),
                  decoration: const InputDecoration(labelText: "Class *"),
                ),
                
                // Gender Selection
                Row(
                  children: [
                    const Text("Gender: "),
                    Radio<String>(value: "Male", groupValue: gender, onChanged: (v) => setState(() => gender = v!)),
                    const Text("Male"),
                    Radio<String>(value: "Female", groupValue: gender, onChanged: (v) => setState(() => gender = v!)),
                    const Text("Female"),
                  ],
                ),
                
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name *", prefixIcon: Icon(Icons.person))),
                
                const Divider(height: 20),
                const Text("Optional Fields", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                
                TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: "Parent Name")),
                TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: "UID Number")),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && selectedClass != null) {
                  _adminService.addStudent(
                    name: nameCtrl.text,
                    gender: gender,
                    className: selectedClass!,
                    parentName: parentCtrl.text,
                    uidNumber: uidCtrl.text,
                    phone: phoneCtrl.text,
                    address: addressCtrl.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Added Successfully")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill Mandatory fields")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // --- EDIT STUDENT DIALOG ---
  void _showEditStudentDialog(String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    final parentCtrl = TextEditingController(text: data['parentName']);
    final uidCtrl = TextEditingController(text: data['uidNumber']);
    final phoneCtrl = TextEditingController(text: data['phone']);
    final addressCtrl = TextEditingController(text: data['address']);
    String gender = data['gender'];
    String selectedClass = data['className'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Student"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => selectedClass = v!),
                  decoration: const InputDecoration(labelText: "Class"),
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => gender = v!),
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: "Parent Name")),
                TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: "UID")),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                _adminService.updateStudent(docId, {
                  'name': nameCtrl.text,
                  'className': selectedClass,
                  'gender': gender,
                  'parentName': parentCtrl.text,
                  'uidNumber': uidCtrl.text,
                  'phone': phoneCtrl.text,
                  'address': addressCtrl.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated Successfully")));
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  // --- BULK ADD DIALOG (SMART COPY PASTE) ---
  void _showBulkAddDialog() {
    final dataCtrl = TextEditingController();
    String gender = "Male";
    String? selectedClass = _classes.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Bulk Add Students"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Common Selection
                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => selectedClass = v),
                    decoration: const InputDecoration(labelText: "Select Class (For Batch)"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => gender = v!),
                    decoration: const InputDecoration(labelText: "Select Gender (For Batch)"),
                  ),
                  
                  const SizedBox(height: 15),
                  const Text("Paste Data Below:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(
                    "Format: Name, Parent, Phone, UID, Address\n(Use comma to separate fields. Or just Name)",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  
                  // 2. Text Area
                  TextField(
                    controller: dataCtrl,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: "Arjun, Ravi, 9876543210\nBimal, , 9998887776\nRahul",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (selectedClass != null && dataCtrl.text.isNotEmpty) {
                  // Split lines
                  List<String> lines = dataCtrl.text.split('\n');
                  
                  // Send to Service
                  _adminService.addBulkStudents(selectedClass!, gender, lines);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${lines.length} Students Processing...")));
                }
              },
              child: const Text("Process Bulk Add"),
            ),
          ],
        ),
      ),
    );
  }
}