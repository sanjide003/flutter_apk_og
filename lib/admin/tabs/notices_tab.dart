// File: lib/admin/tabs/notices_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class NoticesTab extends StatelessWidget {
  const NoticesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: adminService.getNotices(), // Fixed method call
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var notices = snapshot.data!.docs;
          if (notices.isEmpty) return const Center(child: Text("No Notices"));

          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var data = notices[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Text(data['description']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add Notice"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    adminService.addNotice(titleCtrl.text, descCtrl.text, "All"); // Fixed method call
                    Navigator.pop(context);
                  },
                  child: const Text("Post"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}