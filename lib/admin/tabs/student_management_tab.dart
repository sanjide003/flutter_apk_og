// File: lib/admin/tabs/student_management_tab.dart

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
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // SEARCH BAR or ACTION BAR
          _isSelectionMode 
            ? Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_selectedIds.length} Selected", style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _adminService.deleteBulkStudents(_selectedIds.toList());
                        setState(() { _selectedIds.clear(); _isSelectionMode = false; });
                      },
                    )
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(hintText: "Search...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
              ),

          // LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allDocs = snapshot.data!.docs;
                var filtered = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return (data['name'] ?? "").toString().toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) return const Center(child: Text("No Students"));

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var doc = filtered[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isSelected = _selectedIds.contains(doc.id);

                    return ListTile(
                      onLongPress: () {
                        setState(() { _isSelectionMode = true; _selectedIds.add(doc.id); });
                      },
                      onTap: () {
                        if (_isSelectionMode) {
                          setState(() {
                            isSelected ? _selectedIds.remove(doc.id) : _selectedIds.add(doc.id);
                            if (_selectedIds.isEmpty) _isSelectionMode = false;
                          });
                        } else {
                          _showEditDialog(doc.id, data);
                        }
                      },
                      selected: isSelected,
                      selectedTileColor: Colors.blue.withOpacity(0.1),
                      leading: CircleAvatar(child: Text("${data['serialNo']}")),
                      title: Text(data['name']),
                      subtitle: Text("${data['className']} - ${data['gender']}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBulkAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Student"),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
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

  void _showBulkAddDialog() {
    // ലളിതമാക്കിയ ബൾക്ക് ആഡ് ലോജിക് (പഴയ കോഡിലെ അതേ ലോജിക് ഇവിടെ വിളിക്കുന്നു)
    // ഡയലോഗ് കോഡ് വലുതാകാതിരിക്കാൻ ചുരുക്കി എഴുതുന്നു, സർവീസ് കോൾ ശരിയായിരിക്കണം
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bulk Add"),
        content: TextField(controller: nameCtrl, maxLines: 5, decoration: const InputDecoration(hintText: "Names (One per line)")),
        actions: [
          ElevatedButton(
            onPressed: () {
              List<String> names = nameCtrl.text.split('\n');
              List<Map<String, String>> students = [];
              for(var n in names) if(n.trim().isNotEmpty) students.add({'name': n});
              
              _adminService.addBulkStudents("10A", "Male", students); // Default Values for test
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}