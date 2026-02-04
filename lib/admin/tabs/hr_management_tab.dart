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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getStaffList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var staffList = snapshot.data!.docs;

          if (staffList.isEmpty) {
            return const Center(child: Text("No Staff Members Added Yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              var data = staffList[index].data() as Map<String, dynamic>;
              String role = data['role'] ?? 'staff';
              bool isAdmin = role == 'admin';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? Colors.orange.shade100 : Colors.blue.shade100,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: isAdmin ? Colors.orange : Colors.blue,
                    ),
                  ),
                  title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['designation']} • ${data['phone']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete Confirmation
                      _confirmDelete(staffList[index].id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffDialog,
        label: const Text("Add New Staff"),
        icon: const Icon(Icons.person_add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Staff?"),
        content: const Text("Are you sure you want to remove this member? They won't be able to login."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _adminService.deleteStaff(docId);
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String designation = "Teacher"; // Default
    String role = "staff"; // Default

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Staff / Management"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
                  const SizedBox(height: 10),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number (Password)"), keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email ID (For Auth)")),
                  const SizedBox(height: 10),
                  
                  // Designation Dropdown
                  DropdownButtonFormField<String>(
                    value: designation,
                    decoration: const InputDecoration(labelText: "Designation"),
                    items: ["Principal", "Manager", "Teacher", "Clerk", "Accountant"]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        designation = val!;
                        // Role Logic: Principal/Manager = Admin, Others = Staff
                        if (val == "Principal" || val == "Manager") {
                          role = "admin";
                        } else {
                          role = "staff";
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text("System Role: ${role.toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                    _adminService.addStaffMember(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      email: emailCtrl.text,
                      designation: designation,
                      role: role,
                      password: phoneCtrl.text, // Phone is used as password reference
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member Added Successfully")));
                  }
                },
                child: const Text("Add Member"),
              ),
            ],
          );
        },
      ),
    );
  }
}
