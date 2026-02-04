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
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: adminService.getNotices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var notices = snapshot.data!.docs;
          if (notices.isEmpty) return const Center(child: Text("No Notices Published"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var data = notices[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.campaign, color: Colors.orange),
                  title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Chip(label: Text(data['target'] ?? "All"), backgroundColor: Colors.blue.shade50),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Post Notice"),
        icon: const Icon(Icons.send),
        backgroundColor: Colors.orange,
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("New Notice"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) {
                      adminService.addNotice(titleCtrl.text, descCtrl.text, "All");
                      Navigator.pop(ctx);
                    }
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