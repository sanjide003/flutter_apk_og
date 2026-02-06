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
  
  // Filter State
  String _filter = "All"; // 'All', 'Staff', 'Management'
  
  // Multi-select State
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- FILTER CHIPS ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
          
          // --- STAFF LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getStaffList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allDocs = snapshot.data!.docs;
                var filteredDocs = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String category = data['category'] ?? 'staff';
                  
                  if (_filter == "All") return true;
                  return category.toLowerCase() == _filter.toLowerCase();
                }).toList();

                if (filteredDocs.isEmpty) return const Center(child: Text("No records found"));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildMemberCard(doc, data);
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

  // --- WIDGETS ---

  Widget _buildFilterChip(String label) {
    bool isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _filter = label),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent),
      ),
    );
  }

  Widget _buildMemberCard(QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    bool isMgmt = data['category'] == 'management';
    bool isActive = data['isActive'] ?? true;
    bool isSelected = _selectedIds.contains(doc.id);

    return InkWell(
      onLongPress: () {
        // Multi-select Logic (Simple delete toggle)
        setState(() {
          _isSelectionMode = true;
          _selectedIds.add(doc.id);
        });
        // Show delete bar logic can be added here similar to Student Tab
      },
      child: Card(
        color: isActive ? Colors.white : Colors.grey.shade200,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          // Photo / Avatar
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: isMgmt ? Colors.orange.shade100 : Colors.blue.shade100,
            backgroundImage: (data['photoUrl'] != null && data['photoUrl'].isNotEmpty) 
                ? NetworkImage(data['photoUrl']) 
                : null,
            child: (data['photoUrl'] == null || data['photoUrl'].isEmpty)
                ? Icon(isMgmt ? Icons.security : Icons.person, color: isMgmt ? Colors.orange : Colors.blue)
                : null,
          ),
          
          // Info
          title: Text(
            data['name'] ?? "No Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: isActive ? null : TextDecoration.lineThrough,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isMgmt ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(data['designation'] ?? "Staff", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMgmt ? Colors.orange.shade900 : Colors.blue.shade900)),
              ),
              const SizedBox(height: 4),
              Text("📞 ${data['phone']}", style: const TextStyle(fontSize: 12)),
              if (!isMgmt && data['msrNumber'] != null && data['msrNumber'].isNotEmpty)
                Text("🆔 MSR: ${data['msrNumber']}", style: const TextStyle(fontSize: 12)),
            ],
          ),
          
          // Actions
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _showMemberDialog(docId: doc.id, existingData: data);
              if (value == 'deactivate') _adminService.toggleUserStatus(doc.id, isActive);
              if (value == 'delete') _confirmDelete(doc.id, data['name']);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
              PopupMenuItem(
                value: 'deactivate', 
                child: Row(children: [
                  Icon(isActive ? Icons.block : Icons.check_circle, size: 18, color: isActive ? Colors.orange : Colors.green), 
                  const SizedBox(width: 8), 
                  Text(isActive ? "Deactivate" : "Activate")
                ])
              ),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
            ],
          ),
        ),
      ),
    );
  }

  // --- ACTIONS ---

  void _confirmDelete(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User?"),
        content: Text("Delete '$name'? History will remain, but login access will be removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _adminService.deleteStaff(docId);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showMemberDialog({String? docId, Map<String, dynamic>? existingData}) {
    // Controllers
    final nameCtrl = TextEditingController(text: existingData?['name']);
    final roleCtrl = TextEditingController(text: existingData?['designation']);
    final phoneCtrl = TextEditingController(text: existingData?['phone']);
    final userCtrl = TextEditingController(text: existingData?['username']);
    final passCtrl = TextEditingController(text: existingData?['password']);
    final msrCtrl = TextEditingController(text: existingData?['msrNumber']);
    final addressCtrl = TextEditingController(text: existingData?['address']);
    final photoCtrl = TextEditingController(text: existingData?['photoUrl']);
    
    String category = existingData?['category'] ?? "staff";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(docId == null ? "Add New Member" : "Edit Details"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  Row(
                    children: [
                      Expanded(child: RadioListTile<String>(title: const Text("Staff"), value: "staff", groupValue: category, onChanged: (val) => setState(() => category = val!))),
                      Expanded(child: RadioListTile<String>(title: const Text("Mgmt"), value: "management", groupValue: category, onChanged: (val) => setState(() => category = val!))),
                    ],
                  ),
                  const Divider(),
                  
                  // Basic Info
                  const Text("Basic Info", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name *", prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 8),
                  TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: "Role (Ex: Teacher) *", prefixIcon: Icon(Icons.badge))),
                  
                  const SizedBox(height: 15),
                  // Login Info
                  const Text("Login Credentials (Optional)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username / Gmail", prefixIcon: Icon(Icons.alternate_email))),
                  const SizedBox(height: 8),
                  TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline))),
                  
                  const SizedBox(height: 15),
                  // Official Info
                  const Text("Official Details", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                  const SizedBox(height: 8),
                  if (category == "staff") 
                    TextField(controller: msrCtrl, decoration: const InputDecoration(labelText: "MSR Number", prefixIcon: Icon(Icons.numbers))),
                  const SizedBox(height: 8),
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.home)), maxLines: 2),
                  const SizedBox(height: 8),
                  TextField(controller: photoCtrl, decoration: const InputDecoration(labelText: "Photo URL", prefixIcon: Icon(Icons.link))),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty || roleCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Role are required")));
                    return;
                  }

                  Map<String, dynamic> data = {
                    'name': nameCtrl.text,
                    'category': category,
                    'role': category == 'management' ? 'admin' : 'staff', // System Role
                    'designation': roleCtrl.text,
                    'username': userCtrl.text,
                    'password': passCtrl.text,
                    'phone': phoneCtrl.text,
                    'address': addressCtrl.text,
                    'msrNumber': category == 'staff' ? msrCtrl.text : "",
                    'photoUrl': photoCtrl.text,
                  };

                  if (docId == null) {
                    _adminService.addStaffMember(
                      name: nameCtrl.text, category: category, role: roleCtrl.text,
                      username: userCtrl.text, password: passCtrl.text, phone: phoneCtrl.text,
                      address: addressCtrl.text, msrNumber: msrCtrl.text, photoUrl: photoCtrl.text
                    );
                  } else {
                    _adminService.updateStaffMember(docId, data);
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