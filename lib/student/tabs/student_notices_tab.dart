import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/student_service.dart';

class StudentNoticesTab extends StatelessWidget {
  const StudentNoticesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentService _service = StudentService();

    return StreamBuilder<QuerySnapshot>(
      stream: _service.getNotices(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var notices = snapshot.data!.docs;

        if (notices.isEmpty) {
          return const Center(child: Text("No Notices"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            var data = notices[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.orange, size: 30),
                title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['description']),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}