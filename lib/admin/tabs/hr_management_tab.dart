import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class HrManagementTab extends StatefulWidget {
  const HrManagementTab({super.key});

  @override
  State<HrManagementTab> createState() => _HrManagementTabState();
}

class _HrManagementTabState extends State<HrManagementTab> {
  final AdminService _adminService = AdminService();
  String _filter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip("All"),
                _buildFilterChip("Staff"),
                _buildFilterChip("Management"),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStaffList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allDocs = snapshot.data!.docs;
                var filteredDocs = allDocs.where((doc) {
                  if (_filter == "All") return true;
                  var data = doc.data() as Map<String, dynamic>;
                  String category = data['category'] ?? 'staff';
                  return category.toLowerCase() == _filter.toLowerCase();
                }).toList();

                if (filteredDocs.isEmpty) return const Center(child: Text("No records found"));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isMgmt = data['category'] == 'management';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: isMgmt ? Colors.orange.shade100 : Colors.blue.shade100,
                              backgroundImage: (data['photoUrl'] != null && data['photoUrl'].isNotEmpty) 
                                  ? NetworkImage(data['photoUrl']) 
                                  : null,
                              child: (data['photoUrl'] == null || data['photoUrl'].isEmpty)
                                  ? Icon(isMgmt ? Icons.security : Icons.person, color: isMgmt ? Colors.orange : Colors.blue)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['name'] ?? "No Name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(data['designation'] ?? "Staff", style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                                  Text("📞 ${data['phone']}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _showMemberDialog(docId: doc.id, existingData: data);
                                if (value == 'delete') _confirmDelete(doc.id);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text("Edit")),
                                const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMemberDialog(),
        label: const Text("Add Member"),
        icon: const Icon(Icons.person_add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _filter = label),
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete?"),
        content: const Text("Are you sure? This user won't be able to login."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () { _adminService.deleteStaff(docId); Navigator.pop(ctx); },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMemberDialog({String? docId, Map<String, dynamic>? existingData}) {
    final nameCtrl = TextEditingController(text: existingData?['name']);
    final roleCtrl = TextEditingController(text: existingData?['designation']);
    final phoneCtrl = TextEditingController(text: existingData?['phone']);
    final passCtrl = TextEditingController(text: existingData?['password']); // New Password Field
    final addressCtrl = TextEditingController(text: existingData?['address']);
    final msrCtrl = TextEditingController(text: existingData?['msrNumber']);
    final photoCtrl = TextEditingController(text: existingData?['photoUrl']);
    
    String category = existingData?['category'] ?? "staff";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(docId == null ? "Add New Member" : "Edit Member"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: RadioListTile<String>(title: const Text("Staff"), value: "staff", groupValue: category, onChanged: (val) => setState(() => category = val!))),
                      Expanded(child: RadioListTile<String>(title: const Text("Mgmt"), value: "management", groupValue: category, onChanged: (val) => setState(() => category = val!))),
                    ],
                  ),
                  const Divider(),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name (Required)")),
                  const SizedBox(height: 10),
                  TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: "Role (Ex: Teacher)")),
                  const SizedBox(height: 10),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  // PASSWORD FIELD
                  TextField(
                    controller: passCtrl, 
                    decoration: const InputDecoration(labelText: "Create Login Password", prefixIcon: Icon(Icons.lock_outline)),
                  ),
                  const SizedBox(height: 10),
                  if (category == "staff") TextField(controller: msrCtrl, decoration: const InputDecoration(labelText: "MSR Number")),
                  if (category == "staff") const SizedBox(height: 10),
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address"), maxLines: 2),
                  const SizedBox(height: 10),
                  TextField(controller: photoCtrl, decoration: const InputDecoration(labelText: "Photo URL (Optional)")),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Password are required")));
                    return;
                  }
                  if (docId == null) {
                    _adminService.addStaffMember(
                      name: nameCtrl.text, phone: phoneCtrl.text, password: passCtrl.text, // Sending Password
                      category: category, role: roleCtrl.text, address: addressCtrl.text, photoUrl: photoCtrl.text, msrNumber: msrCtrl.text,
                    );
                  } else {
                    _adminService.updateStaffMember(docId, {
                      'name': nameCtrl.text, 'phone': phoneCtrl.text, 'password': passCtrl.text,
                      'category': category, 'designation': roleCtrl.text, 'address': addressCtrl.text, 
                      'photoUrl': photoCtrl.text, 'msrNumber': category == 'staff' ? msrCtrl.text : "",
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }
}