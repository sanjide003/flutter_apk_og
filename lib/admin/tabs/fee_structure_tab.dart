import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class FeeStructureTab extends StatefulWidget {
  const FeeStructureTab({super.key});

  @override
  State<FeeStructureTab> createState() => _FeeStructureTabState();
}

class _FeeStructureTabState extends State<FeeStructureTab> {
  final AdminService _service = AdminService();
  final TextEditingController _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DEFAULT FEE SETUP
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("Default Monthly Fee Setup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Monthly Amount (₹)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // In real implementation, get active Year ID
                        _service.initDefaultFeeStructure("YEAR_ID_PLACEHOLDER", double.tryParse(_amountCtrl.text) ?? 0);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Default 12 Months Generated")));
                      },
                      child: const Text("Generate 12 Months"),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text("Fee Structures", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // LIST (Streams)
            StreamBuilder<QuerySnapshot>(
              stream: _service.getDefaultFees(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                var fees = snapshot.data!.docs;
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fees.length,
                  itemBuilder: (context, index) {
                    var data = fees[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text("${data['order']}")),
                        title: Text(data['month']),
                        trailing: Text("₹ ${data['amount']}"),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}