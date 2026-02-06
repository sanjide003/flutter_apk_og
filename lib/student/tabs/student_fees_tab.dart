import 'package:flutter/material.dart';
import '../services/student_service.dart';

class StudentFeesTab extends StatelessWidget {
  final String studentId;
  final String? yearId;

  const StudentFeesTab({super.key, required this.studentId, required this.yearId});

  @override
  Widget build(BuildContext context) {
    // 12 Months Hardcoded List for UI (Real logic needs mapping)
    final List<String> months = [
      "June", "July", "August", "September", "October", "November", 
      "December", "January", "February", "March", "April", "May"
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: months.length,
      itemBuilder: (context, index) {
        // ഡമ്മി ലോജിക്: ഇരട്ട മാസങ്ങൾ Paid, ഒറ്റ മാസങ്ങൾ Pending എന്ന് കാണിക്കാൻ
        // യഥാർത്ഥ ആപ്പിൽ ഇത് DB-യിൽ നിന്ന് മാച്ച് ചെയ്യണം.
        bool isPaid = index % 2 == 0; 

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text("${months[index]} Fee", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(isPaid ? "Paid via Receipt #10${index+1}" : "Due Date: 10th ${months[index]}"),
            trailing: isPaid 
                ? const Chip(
                    label: Text("PAID", style: TextStyle(color: Colors.white, fontSize: 10)),
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                  )
                : const Chip(
                    label: Text("PENDING", style: TextStyle(color: Colors.white, fontSize: 10)),
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.zero,
                  ),
            leading: Icon(
              isPaid ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isPaid ? Colors.green : Colors.orange,
            ),
          ),
        );
      },
    );
  }
}