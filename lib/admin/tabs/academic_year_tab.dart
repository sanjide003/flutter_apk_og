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
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "The 'Active' year controls all fees and student promotions. Creating a new year automatically sets it as active.",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List of Years
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _adminService.getAcademicYears(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  var years = snapshot.data!.docs;

                  if (years.isEmpty) {
                    return const Center(child: Text("No Academic Years Found.\nCreate one to start.", textAlign: TextAlign.center));
                  }

                  return ListView.builder(
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      var data = years[index].data() as Map<String, dynamic>;
                      bool isActive = data['isActive'] ?? false;

                      return Card(
                        elevation: isActive ? 4 : 1,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isActive ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isActive ? Colors.green : Colors.grey,
                            child: const Icon(Icons.calendar_today, color: Colors.white),
                          ),
                          title: Text(
                            data['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text("Start: ${_formatDate(data['startDate'])}  •  End: ${_formatDate(data['endDate'])}"),
                          trailing: isActive 
                              ? Chip(label: const Text("ACTIVE", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)
                              : null,
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
        label: const Text("New Academic Year"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  // തീയതി കാണിക്കാൻ (Simple Formatter)
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  // പുതിയ വർഷം ചേർക്കാനുള്ള ഡയലോഗ്
  void _showAddYearDialog() {
    final nameController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Academic Year"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Year Name (Ex: 2025-2026)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("This year will be set as ACTIVE automatically.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _adminService.addAcademicYear(nameController.text, startDate, endDate);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Academic Year Created!")));
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
