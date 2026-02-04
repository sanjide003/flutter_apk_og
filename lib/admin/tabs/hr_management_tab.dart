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
  String _filter = "All"; // Filter State: All, Staff, Management

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- FILTER SECTION ---
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
          
          // --- LIST SECTION ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStaffList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allDocs = snapshot.data!.docs;
                // Filtering Logic
                var filteredDocs = allDocs.where((doc) {
                  if (_filter == "All") return true;
                  var data = doc.data() as Map<String, dynamic>;
                  String category = data['category'] ?? 'staff'; // 'management' or 'staff'
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Photo / Avatar
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
                            
                            // 2. Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? "No Name",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isMgmt ? Colors.orange.shade50 : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: isMgmt ? Colors.orange.shade200 : Colors.blue.shade200, width: 0.5)
                                    ),
                                    child: Text(
                                      data['designation'] ?? "Staff", // Custom Role
                                      style: TextStyle(fontSize: 12, color: isMgmt ? Colors.orange.shade900 : Colors.blue.shade900, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("📞 ${data['phone']}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  if (!isMgmt && data['msrNumber'] != null && data['msrNumber'].isNotEmpty)
                                    Text("🆔 MSR: ${data['msrNumber']}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ),

                            // 3. Edit/Delete Menu
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _showMemberDialog(docId: doc.id, existingData: data);
                                if (value == 'delete') _confirmDelete(doc.id);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
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

  // --- WIDGET HELPER ---
  Widget _buildFilterChip(String label) {
    bool isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() => _filter = label);
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
      ),
    );
  }

  // --- ACTIONS ---

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Member?"),
        content: const Text("Are you sure? They won't be able to login anymore."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () {
              _adminService.deleteStaff(docId);
              Navigator.pop(ctx);
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ADD / EDIT DIALOG
  void _showMemberDialog({String? docId, Map<String, dynamic>? existingData}) {
    // Controllers
    final nameCtrl = TextEditingController(text: existingData?['name']);
    final roleCtrl = TextEditingController(text: existingData?['designation']); // Custom Role Input
    final phoneCtrl = TextEditingController(text: existingData?['phone']);
    final addressCtrl = TextEditingController(text: existingData?['address']);
    final msrCtrl = TextEditingController(text: existingData?['msrNumber']);
    final photoCtrl = TextEditingController(text: existingData?['photoUrl']);
    
    // State for Radio Button inside Dialog
    String category = existingData?['category'] ?? "staff"; // Default

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(docId == null ? "Add New Member" : "Edit Member Details"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Category Selection (Radio Buttons)
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Staff"),
                          value: "staff",
                          groupValue: category,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => category = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Management"),
                          value: "management",
                          groupValue: category,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => category = val!),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // 2. Mandatory Fields
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name (Required)", prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 10),
                  TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: "Role (Ex: Teacher, Clerk) (Required)", prefixIcon: Icon(Icons.badge))),
                  const SizedBox(height: 10),
                  
                  // 3. Contact & Login Info
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone (Login Password)", prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  
                  // 4. MSR Number (Only for Staff)
                  if (category == "staff")
                    TextField(controller: msrCtrl, decoration: const InputDecoration(labelText: "MSR Number", prefixIcon: Icon(Icons.numbers))),
                  if (category == "staff") const SizedBox(height: 10),

                  // 5. Other Details
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.home)), maxLines: 2),
                  const SizedBox(height: 10),
                  TextField(controller: photoCtrl, decoration: const InputDecoration(labelText: "Photo URL (Optional)", prefixIcon: Icon(Icons.link))),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  // Basic Validation
                  if (nameCtrl.text.isEmpty || roleCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill required fields (Name, Role, Phone)")));
                    return;
                  }

                  if (docId == null) {
                    // CREATE
                    _adminService.addStaffMember(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      category: category,
                      role: roleCtrl.text, // Custom Input
                      address: addressCtrl.text,
                      photoUrl: photoCtrl.text,
                      msrNumber: msrCtrl.text,
                    );
                  } else {
                    // UPDATE
                    _adminService.updateStaffMember(docId, {
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                      'category': category,
                      'designation': roleCtrl.text,
                      'address': addressCtrl.text,
                      'photoUrl': photoCtrl.text,
                      'msrNumber': category == 'staff' ? msrCtrl.text : "",
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text(docId == null ? "Save" : "Update"),
              ),
            ],
          );
        },
      ),
    );
  }
}