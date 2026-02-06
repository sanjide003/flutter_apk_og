import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/staff_service.dart';

class StaffDashboardTab extends StatelessWidget {
  const StaffDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffService _service = StaffService();
    final String staffId = FirebaseAuth.instance.currentUser?.uid ?? "unknown"; // ലോഗിൻ ചെയ്ത ആളുടെ ID

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          
          // --- LIVE STATS ---
          StreamBuilder<QuerySnapshot>(
            stream: _service.getTodayCollection(staffId), // സ്റ്റാഫ് ID വഴി ഫിൽറ്റർ ചെയ്യുന്നു
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              
              var docs = snapshot.data!.docs;
              double total = 0;
              for (var doc in docs) total += (doc['amount'] ?? 0);

              return Row(
                children: [
                  Expanded(child: _buildStatCard("Collected Today", "₹ ${total.toStringAsFixed(0)}", Colors.green, Icons.attach_money)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Receipts Generated", "${docs.length}", Colors.blue, Icons.receipt)),
                ],
              );
            },
          ),

          const SizedBox(height: 30),
          const Text("Recent Collections", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // --- RECENT LIST ---
          StreamBuilder<QuerySnapshot>(
            stream: _service.getTodayCollection(staffId), // ഇവിടെ വേണമെങ്കിൽ ഫുൾ ഹിസ്റ്ററി കൊടുക്കാം
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              var docs = snapshot.data!.docs;
              
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text("No fees collected today yet.", style: TextStyle(color: Colors.grey))),
                );
              }

              // റിവേഴ്സ് ഓർഡർ (പുതിയത് ആദ്യം)
              var reversedDocs = docs.reversed.toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reversedDocs.length,
                itemBuilder: (context, index) {
                  var data = reversedDocs[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text("#${data['receiptNo']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(data['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${data['feeName']} • ${data['className']}"),
                      trailing: Text("₹ ${data['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}