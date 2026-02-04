import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class FeeStructureTab extends StatelessWidget {
  const FeeStructureTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: adminService.getFeeStructures(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var fees = snapshot.data!.docs;
          if (fees.isEmpty) return const Center(child: Text("No Fee Structures Created"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fees.length,
            itemBuilder: (context, index) {
              var data = fees[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.attach_money)),
                  title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['type'] == 'monthly' ? "Monthly Fee" : "One-time Fee"),
                  trailing: Text("₹ ${data['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onLongPress: () => adminService.deleteFeeStructure(fees[index].id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Create Fee"),
        icon: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("New Fee Structure"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Fee Name (Ex: Tuition Fee)")),
                  TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      adminService.addFeeStructure(nameCtrl.text, double.tryParse(amountCtrl.text) ?? 0, 'monthly');
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Save"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}