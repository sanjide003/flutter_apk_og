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
            // --- TOP OPERATIONS CARD ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Class Operations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOpButton(Icons.upload_file, "Promote\nStudents", Colors.blue, _showPromotionDialog),
                        _buildOpButton(Icons.merge_type, "Merge\nClasses", Colors.orange, _showMergeDialog),
                        _buildOpButton(Icons.call_split, "Split/Move\nClass", Colors.purple, _showSplitDialog),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ACADEMIC YEAR LIST ---
            const Align(alignment: Alignment.centerLeft, child: Text("Academic Years History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),
            
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
                          leading: CircleAvatar(
                            backgroundColor: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                            child: Icon(isActive ? Icons.check_circle : Icons.history, color: isActive ? Colors.green : Colors.grey),
                          ),
                          title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isActive ? "Currently Active" : "Tap to Activate"),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddYearDialog,
        label: const Text("New Year"),
        icon: const Icon(Icons.calendar_month),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildOpButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- DIALOGS ---

  void _showPromotionDialog() {
    // This is a complex dialog, simplifying for concept
    // Needs: Target Year Dropdown, List of Classes with "To Class" Dropdown
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Promote Students"),
        content: const SizedBox(
          width: 300,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, color: Colors.blue, size: 40),
              SizedBox(height: 10),
              Text("Promotion Logic requires selecting a Target Year and mapping each class. (Backend Logic Ready)", textAlign: TextAlign.center),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
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
            TextField(controller: class1Ctrl, decoration: const InputDecoration(labelText: "Source Class 1 (Ex: 10A)")),
            TextField(controller: class2Ctrl, decoration: const InputDecoration(labelText: "Source Class 2 (Ex: 10B)")),
            const Divider(),
            TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: "Target Class (Ex: 10C)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (class1Ctrl.text.isNotEmpty && targetCtrl.text.isNotEmpty) {
                _adminService.mergeClasses(class1Ctrl.text, class2Ctrl.text, targetCtrl.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Classes Merged!")));
              }
            },
            child: const Text("Merge"),
          ),
        ],
      ),
    );
  }

  void _showSplitDialog() {
    // Placeholder for Split Logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Split / Move Class"),
        content: const Text("To split a class, please go to 'Student Management', search for the class, select students, and use the 'Edit Class' option to move them in bulk."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showAddYearDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Academic Year"),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: "Year Name (Ex: 2025-2026)")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
        title: const Text("Activate Year?"),
        content: Text("Set '$name' as active?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          ElevatedButton(
            onPressed: () { _adminService.setAcademicYearActive(docId); Navigator.pop(ctx); },
            child: const Text("Activate"),
          ),
        ],
      ),
    );
  }
}