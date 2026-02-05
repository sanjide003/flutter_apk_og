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

  // MULTI-SELECTION STATE
  final Set<String> _selectedIds = {}; // സെലക്ട് ചെയ്ത ഐഡികൾ സൂക്ഷിക്കാൻ
  bool _isSelectionMode = false; // സെലക്ഷൻ മോഡ് ഓൺ ആണോ എന്ന് നോക്കാൻ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- TOP BAR (DYNAMIC) ---
          // സെലക്ഷൻ മോഡിൽ ആണെങ്കിൽ ആക്ഷൻ ബാർ കാണിക്കും, അല്ലെങ്കിൽ സെർച്ച് ബാർ കാണിക്കും
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSelectionMode 
              ? _buildSelectionBar() 
              : _buildFilterBar(),
          ),

          // --- LIST VIEW ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStudents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allDocs = snapshot.data!.docs;
                
                // Filtering Logic
                var filtered = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? "").toString().toLowerCase();
                  if (!name.contains(_searchQuery)) return false;
                  if (_selectedClassFilter != null && data['className'] != _selectedClassFilter) return false;
                  if (_selectedGenderFilter != null && data['gender'] != _selectedGenderFilter) return false;
                  return true;
                }).toList();

                // SORTING (Class -> Gender -> SerialNo)
                filtered.sort((a, b) {
                  var da = a.data() as Map<String, dynamic>;
                  var db = b.data() as Map<String, dynamic>;
                  int classComp = (da['className'] ?? "").compareTo(db['className'] ?? "");
                  if (classComp != 0) return classComp;
                  int genderComp = (da['gender'] ?? "").compareTo(db['gender'] ?? "");
                  if (genderComp != 0) return genderComp;
                  return (da['serialNo'] ?? 0).compareTo(db['serialNo'] ?? 0);
                });

                if (filtered.isEmpty) return const Center(child: Text("No Students Found"));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var doc = filtered[index];
                    return _buildStudentCard(doc, filtered); // Pass filtered list for 'Select All' logic
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : Column(
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
            label: const Text("Add Single"),
            icon: const Icon(Icons.person_add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  // 1. NORMAL FILTER BAR
  Widget _buildFilterBar() {
    return Container(
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
                        classItems.add(DropdownMenuItem(value: doc['name'], child: Text(doc['name'])));
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
    );
  }

  // 2. SELECTION ACTION BAR
  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.blue.shade50,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedIds.clear();
                    });
                  },
                ),
                Text(
                  "${_selectedIds.length} Selected",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900),
                ),
              ],
            ),
            Row(
              children: [
                // Select All Button logic needs access to visible list, implemented in card interaction usually, 
                // but here we can toggle. For simplicity, "Select All" logic is triggered from here by passing visible list context if needed
                // or we rely on manual selection. Let's add a Delete button.
                TextButton.icon(
                  onPressed: () => _confirmBulkDelete(), 
                  icon: const Icon(Icons.delete, color: Colors.red), 
                  label: const Text("Delete All", style: TextStyle(color: Colors.red))
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 3. STUDENT CARD
  Widget _buildStudentCard(QueryDocumentSnapshot doc, List<QueryDocumentSnapshot> visibleList) {
    var data = doc.data() as Map<String, dynamic>;
    bool isMale = data['gender'] == 'Male';
    bool isSelected = _selectedIds.contains(doc.id);

    return InkWell(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _selectedIds.add(doc.id);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(doc.id);
              if (_selectedIds.isEmpty) _isSelectionMode = false;
            } else {
              _selectedIds.add(doc.id);
            }
          });
        } else {
          // Show Edit Dialog on Tap (or details)
          _showEditStudentDialog(doc.id, data);
        }
      },
      child: Card(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected ? const BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
        ),
        child: ListTile(
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedIds.add(doc.id);
                      } else {
                        _selectedIds.remove(doc.id);
                        if (_selectedIds.isEmpty) _isSelectionMode = false;
                      }
                    });
                  },
                )
              : CircleAvatar(
                  backgroundColor: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
                  child: Text("${data['serialNo']}", style: TextStyle(fontWeight: FontWeight.bold, color: isMale ? Colors.blue.shade900 : Colors.pink.shade900)),
                ),
          title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${data['className']}  •  ${data['gender']}"),
          trailing: _isSelectionMode 
            ? null 
            : IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditStudentDialog(doc.id, data),
              ),
        ),
      ),
    );
  }

  // --- ACTIONS ---

  void _confirmBulkDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Selected?"),
        content: Text("Are you sure you want to delete ${_selectedIds.length} students?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _adminService.deleteBulkStudents(_selectedIds.toList());
              setState(() {
                _selectedIds.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Students Deleted")));
            },
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
  }

  // FULL EDIT DIALOG
  void _showEditStudentDialog(String docId, Map<String, dynamic> data) {
    // Controllers populated with existing data
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
          title: const Text("Edit Student Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Academic Info", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Class & Gender Dropdowns (Requires Stream for Classes)
                StreamBuilder<QuerySnapshot>(
                  stream: _adminService.getClasses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                    // Ensure current class is in list, else add it temporarily to avoid crash
                    if (!classes.contains(selectedClass)) classes.add(selectedClass);
                    
                    return DropdownButtonFormField<String>(
                      value: selectedClass,
                      items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => selectedClass = v!),
                      decoration: const InputDecoration(labelText: "Class"),
                    );
                  },
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => gender = v!),
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                const Divider(),
                const Text("Personal Info", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person))),
                TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: "Parent Name", prefixIcon: Icon(Icons.people))),
                TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: "UID Number", prefixIcon: Icon(Icons.badge))),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone", prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.home)), maxLines: 2),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Updated Successfully")));
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  // --- EXISTING ACTIONS (ADD/BULK) ---
  void _showAddClassDialog() {
    final classCtrl = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Add New Class"), content: TextField(controller: classCtrl, decoration: const InputDecoration(labelText: "Class Name (Ex: 10 A)")), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () { if (classCtrl.text.isNotEmpty) { _adminService.addClass(classCtrl.text); Navigator.pop(context); }}, child: const Text("Add"))]));
  }

  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String gender = "Male";
    String? selectedClass;

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(title: const Text("Add Student"), content: SingleChildScrollView(child: Column(children: [StreamBuilder<QuerySnapshot>(stream: _adminService.getClasses(), builder: (context, snapshot) { if (!snapshot.hasData) return const SizedBox(); var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList(); return DropdownButtonFormField<String>(value: selectedClass, items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => selectedClass = v), decoration: const InputDecoration(labelText: "Class *")); }), DropdownButtonFormField<String>(value: gender, items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => gender = v!), decoration: const InputDecoration(labelText: "Gender *")), const SizedBox(height: 10), TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name *")), const Divider(), TextField(controller: parentCtrl, decoration: const InputDecoration(labelText: "Parent Name")), TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: "UID")), TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")), TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address"))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () { if (nameCtrl.text.isNotEmpty && selectedClass != null) { _adminService.addStudent(name: nameCtrl.text, gender: gender, className: selectedClass!, parentName: parentCtrl.text, uidNumber: uidCtrl.text, phone: phoneCtrl.text, address: addressCtrl.text); Navigator.pop(context); } }, child: const Text("Save"))])));
  }

  void _showColumnBulkAddDialog() {
    final nameCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final uidCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String gender = "Male";
    String? selectedClass;

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(title: const Text("Bulk Add (Excel Columns)"), content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Column(children: [StreamBuilder<QuerySnapshot>(stream: _adminService.getClasses(), builder: (context, snapshot) { if (!snapshot.hasData) return const SizedBox(); var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList(); return DropdownButtonFormField<String>(value: selectedClass, items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => selectedClass = v), decoration: const InputDecoration(labelText: "Class")); }), DropdownButtonFormField<String>(value: gender, items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => gender = v!), decoration: const InputDecoration(labelText: "Gender")), const Divider(), _buildBulkTextField(nameCtrl, "Paste NAMES Column"), _buildBulkTextField(parentCtrl, "Paste PARENTS Column"), _buildBulkTextField(phoneCtrl, "Paste PHONE Column"), _buildBulkTextField(uidCtrl, "Paste UIDs Column"), _buildBulkTextField(addressCtrl, "Paste ADDRESS Column")]))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () { if (selectedClass != null && nameCtrl.text.isNotEmpty) { _processBulkData(selectedClass!, gender, nameCtrl.text, parentCtrl.text, phoneCtrl.text, uidCtrl.text, addressCtrl.text); Navigator.pop(context); } }, child: const Text("Process"))])));
  }

  Widget _buildBulkTextField(TextEditingController ctrl, String hint) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: TextField(controller: ctrl, maxLines: 3, style: const TextStyle(fontSize: 12), decoration: InputDecoration(labelText: hint, border: const OutlineInputBorder())));
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