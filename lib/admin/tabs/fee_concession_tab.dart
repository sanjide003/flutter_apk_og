import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class FeeConcessionTab extends StatelessWidget {
  const FeeConcessionTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI for Grouping Logic
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_work, size: 50, color: Colors.purple),
            const SizedBox(height: 20),
            const Text("Student Grouping & Concessions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Open Group Creation Dialog
                // Logic: Select multiple students -> Create Group ID -> Save to DB
              },
              icon: const Icon(Icons.add),
              label: const Text("Create New Group"),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Feature: Select siblings or students to group payments. When one pays, others update automatically.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}