import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/student_service.dart';

class StudentProfileTab extends StatelessWidget {
  final String studentId;

  const StudentProfileTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final StudentService _service = StudentService();

    return StreamBuilder<DocumentSnapshot>(
      stream: _service.getStudentProfile(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const Center(child: Text("Profile Not Found"));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Pic
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                data['name'], 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
              Text(
                "UID: ${data['uidNumber'] ?? 'N/A'}", 
                style: const TextStyle(fontSize: 14, color: Colors.grey)
              ),
              const SizedBox(height: 30),

              // Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.class_, "Class", data['className']),
                      const Divider(),
                      _buildDetailRow(Icons.people, "Parent Name", data['parentName']),
                      const Divider(),
                      _buildDetailRow(Icons.phone, "Phone", data['phone']),
                      const Divider(),
                      _buildDetailRow(Icons.home, "Address", data['address']),
                      const Divider(),
                      _buildDetailRow(Icons.male, "Gender", data['gender']),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Request Change Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Request sent to Admin!"))
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Request Profile Correction"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}