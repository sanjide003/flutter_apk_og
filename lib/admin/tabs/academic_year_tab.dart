// File: lib/admin/tabs/academic_year_tab.dart

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- TOP OPERATIONS ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Operations", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOpButton(Icons.merge_type, "Merge\nClasses", Colors.orange, _showMergeDialog),
                        // മറ്റ് ബട്ടണുകൾ ഇവിടെ ചേർക്കാം
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ACADEMIC YEAR LIST ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _adminService.getAcademicYears(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var years = snapshot.data!.docs;
                  if (years.isEmpty) return const Center(child: Text("No Academic Years Found"));

                  return ListView.builder(
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      var doc = years[index];
                      var data = doc.data() as Map<String, dynamic>;
                      bool isActive = data['isActive'] ?? false;

                      return Card(
                        elevation: isActive ? 4 : 1,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isActive ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
                        ),
                        child: ListTile(
                          onTap: () => _confirmToggleActive(doc.id, data['name'], isActive),
                          leading: Icon(isActive ? Icons.check_circle : Icons.history, color: isActive ? Colors.green : Colors.grey),
                          title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isActive ? "Active Year" : "Inactive"),
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'delete') _adminService.deleteAcademicYear(doc.id);
                            },
                            itemBuilder: (ctx) => [
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddYearDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOpButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void _showMergeDialog() {
    final class1Ctrl = TextEditingController();
    final class2Ctrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Merge Classes"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: class1Ctrl, decoration: const InputDecoration(labelText: "Class 1 (Ex: 10A)")),
            TextField(controller: class2Ctrl, decoration: const InputDecoration(labelText: "Class 2 (Ex: 10B)")),
            TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: "Target Class (Ex: 10C)")),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (class1Ctrl.text.isNotEmpty && targetCtrl.text.isNotEmpty) {
                _adminService.mergeClasses(class1Ctrl.text, class2Ctrl.text, targetCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Merge"),
          ),
        ],
      ),
    );
  }

  void _showAddYearDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Academic Year"),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name (2025-26)")),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _adminService.addAcademicYear(nameController.text, DateTime.now(), DateTime.now().add(const Duration(days: 365)));
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _confirmToggleActive(String docId, String name, bool active) {
    if (active) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Activate?"),
        content: Text("Set $name as active?"),
        actions: [
          ElevatedButton(
            onPressed: () { _adminService.setAcademicYearActive(docId); Navigator.pop(ctx); },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}