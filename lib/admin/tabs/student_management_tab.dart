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
  
  String? _selectedClassFilter;
  String? _selectedGenderFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- TOP BAR (Filter & Search) ---
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search Student...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // REAL CLASS FILTER (FROM DB)
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _adminService.getClasses(),
                        builder: (context, snapshot) {
                          List<DropdownMenuItem<String>> classItems = [
                            const DropdownMenuItem(value: null, child: Text("All Classes")),
                          ];
                          
                          if (snapshot.hasData) {
                            var classes = snapshot.data!.docs;
                            for (var doc in classes) {
                              var name = doc['name'];
                              classItems.add(DropdownMenuItem(value: name, child: Text(name)));
                            }
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedClassFilter,
                            decoration: const InputDecoration(labelText: "Filter Class", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                            items: classItems,
                            onChanged: (val) => setState(() => _selectedClassFilter = val),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGenderFilter,
                        decoration: const InputDecoration(labelText: "Filter Gender", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
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
                // ADD CLASS BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _showAddClassDialog,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text("Manage Classes"),
                  ),
                )
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
                var filtered = allStudents.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? "").toString().toLowerCase();
                  
                  if (!name.contains(_searchQuery)) return false;
                  if (_selectedClassFilter != null && data['className'] != _selectedClassFilter) return false;
                  if (_selectedGenderFilter != null && data['gender'] != _selectedGenderFilter) return false;
                  return true;
                }).toList();

                if (filtered.isEmpty) return const Center(child: Text("No Students Found"));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var doc = filtered[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isMale = data['gender'] == 'Male';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
                          child: Text("${data['serialNo']}", style: TextStyle(fontWeight: FontWeight.bold, color: isMale ? Colors.blue.shade900 : Colors.pink.shade900)),
                        ),
                        title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${data['className']}  •  ${data['gender']}"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _showEditStudentDialog(doc.id, data);
                            if (v == 'delete') _confirmDelete(doc.id, data['name']);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text("Edit")),
                            const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "bulk",
            onPressed: _showColumnBulkAddDialog,
            label: const Text("Bulk Add"),
            icon: const Icon(Icons.table_chart),
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

  // --- ACTIONS ---

  void _showAddClassDialog() {
    final classCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Class"),
        content: TextField(controller: classCtrl, decoration: const InputDecoration(labelText: "Class Name (Ex: 10 A)")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (classCtrl.text.isNotEmpty) {
                _adminService.addClass(classCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _confirmDelete(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete?"),
        content: Text("Delete student '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(onPressed: () { _adminService.deleteStudent(docId); Navigator.pop(ctx); }, child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  // --- SINGLE ADD DIALOG (REAL CLASSES) ---
  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String gender = "Male";
    String? selectedClass;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Student"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _adminService.getClasses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                    if (classes.isEmpty) return const Text("Please Add Classes First", style: TextStyle(color: Colors.red));
                    
                    return DropdownButtonFormField<String>(
                      value: selectedClass,
                      items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => selectedClass = v),
                      decoration: const InputDecoration(labelText: "Class *"),
                    );
                  },
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => gender = v!),
                  decoration: const InputDecoration(labelText: "Gender *"),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name *")),
                const Divider(),
                TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: "Parent Name")),
                TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: "UID")),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone"), keyboardType: TextInputType.phone),
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
                    name: nameCtrl.text, gender: gender, className: selectedClass!,
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

  // --- BULK ADD DIALOG (REAL CLASSES) ---
  void _showColumnBulkAddDialog() {
    final nameCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String gender = "Male";
    String? selectedClass;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Bulk Add"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _adminService.getClasses(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                      return DropdownButtonFormField<String>(
                        value: selectedClass,
                        items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => selectedClass = v),
                        decoration: const InputDecoration(labelText: "Select Batch Class"),
                      );
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => gender = v!),
                    decoration: const InputDecoration(labelText: "Select Batch Gender"),
                  ),
                  const Divider(),
                  _buildBulkTextField(nameCtrl, "Paste NAMES Column Here (Required)"),
                  _buildBulkTextField(parentCtrl, "Paste PARENTS Column"),
                  _buildBulkTextField(phoneCtrl, "Paste PHONE Column"),
                  _buildBulkTextField(uidCtrl, "Paste UID Column"),
                  _buildBulkTextField(addressCtrl, "Paste ADDRESS Column"),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (selectedClass != null && nameCtrl.text.isNotEmpty) {
                  _processBulkData(selectedClass!, gender, nameCtrl.text, parentCtrl.text, phoneCtrl.text, uidCtrl.text, addressCtrl.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Process"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    String selectedClass = data['className']; // For edit, we assume class exists or keep old one
    String gender = data['gender'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            // More fields can be added here
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _adminService.updateStudent(docId, {'name': nameCtrl.text});
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  Widget _buildBulkTextField(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(controller: ctrl, maxLines: 3, style: const TextStyle(fontSize: 12), decoration: InputDecoration(labelText: hint, border: const OutlineInputBorder())),
    );
  }

  void _processBulkData(String className, String gender, String namesRaw, String parentsRaw, String phonesRaw, String uidsRaw, String addrRaw) {
    List<String> names = namesRaw.split('\n').where((s) => s.trim().isNotEmpty).toList();
    List<String> parents = parentsRaw.split('\n');
    List<String> phones = phonesRaw.split('\n');
    List<String> uids = uidsRaw.split('\n');
    List<String> addrs = addrRaw.split('\n');

    List<Map<String, String>> students = [];
    for (int i = 0; i < names.length; i++) {
      students.add({
        'name': names[i].trim(),
        'parent': (i < parents.length) ? parents[i].trim() : "",
        'phone': (i < phones.length) ? phones[i].trim() : "",
        'uid': (i < uids.length) ? uids[i].trim() : "",
        'address': (i < addrs.length) ? addrs[i].trim() : "",
      });
    }
    _adminService.addBulkStudents(className, gender, students);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Processing ${names.length} students...")));
  }
}