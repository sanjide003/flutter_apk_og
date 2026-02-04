import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class AcademicYearTab extends StatefulWidget {
  const AcademicYearTab({super.key});

  @override
  State<AcademicYearTab> createState() => _AcademicYearTabState();
}

class _AcademicYearTabState extends State<AcademicYearTab> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAcademicYears(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var years = snapshot.data!.docs;
          if (years.isEmpty) return const Center(child: Text("No Academic Years Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: years.length,
            itemBuilder: (context, index) {
              var doc = years[index];
              var data = doc.data() as Map<String, dynamic>;
              bool isActive = data['isActive'] ?? false;

              return Card(
                elevation: isActive ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isActive ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => _confirmToggleActive(doc.id, data['name'], isActive),
                  
                  // Status Icon
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                    child: Icon(
                      isActive ? Icons.check_circle : Icons.history,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  
                  title: Text(
                    data['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    isActive ? "Currently Active Year" : "Tap to Activate",
                    style: TextStyle(color: isActive ? Colors.green : Colors.grey),
                  ),
                  
                  // 3-DOT MENU (Edit / Delete)
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _showYearDialog(docId: doc.id, existingData: data);
                      if (value == 'delete') _confirmDelete(doc.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 10), Text("Edit")])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 10), Text("Delete", style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showYearDialog(),
        label: const Text("New Academic Year"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  // --- ACTIONS ---

  void _confirmToggleActive(String docId, String name, bool currentlyActive) {
    if (currentlyActive) return; // Already active
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Activate Year?"),
        content: Text("Do you want to set '$name' as the active academic year? Other years will be deactivated."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          ElevatedButton(
            onPressed: () {
              _adminService.setAcademicYearActive(docId);
              Navigator.pop(ctx);
            },
            child: const Text("Yes, Activate"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Year?"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () {
              _adminService.deleteAcademicYear(docId);
              Navigator.pop(ctx);
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Dialog for Create & Edit
  void _showYearDialog({String? docId, Map<String, dynamic>? existingData}) {
    final nameController = TextEditingController(text: existingData?['name'] ?? "");
    // Dates can be added if needed, kept simple for now

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Create Year" : "Edit Year"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Year Name (Ex: 2025-2026)", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (docId == null) {
                  _adminService.addAcademicYear(nameController.text, DateTime.now(), DateTime.now().add(const Duration(days: 365)));
                } else {
                  _adminService.updateAcademicYear(docId, nameController.text, DateTime.now(), DateTime.now());
                }
                Navigator.pop(context);
              }
            },
            child: Text(docId == null ? "Create" : "Update"),
          ),
        ],
      ),
    );
  }
}