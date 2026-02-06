import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/student_service.dart';

class StudentDashboardTab extends StatelessWidget {
  final String studentId;
  final String? yearId;

  const StudentDashboardTab({super.key, required this.studentId, required this.yearId});

  @override
  Widget build(BuildContext context) {
    final StudentService _service = StudentService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- FEE SUMMARY CARDS ---
          StreamBuilder<QuerySnapshot>(
            stream: _service.getFeeRecords(studentId, yearId ?? ""),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              // കാൽക്കുലേഷൻ (ലളിതമായ രീതിയിൽ)
              double paid = 0;
              for (var doc in snapshot.data!.docs) {
                paid += (doc['amount'] ?? 0);
              }
              
              // ടോട്ടൽ ഫീസ് അഡ്മിൻ ഫീസ് സ്ട്രക്ചറിൽ നിന്ന് എടുക്കണം. 
              // തൽക്കാലം ഒരു ഡമ്മി ടോട്ടൽ അല്ലെങ്കിൽ കാൽക്കുലേഷൻ ലോജിക് വെക്കാം.
              double totalFee = 15000; // Example Total for the year
              double due = totalFee - paid;

              return Row(
                children: [
                  Expanded(child: _buildSummaryCard("Paid Fee", "₹ ${paid.toStringAsFixed(0)}", Colors.green, Icons.check_circle)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard("Due Fee", "₹ ${due.toStringAsFixed(0)}", Colors.red, Icons.pending)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 25),
          const Text("Recent Transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          // --- RECENT TRANSACTIONS ---
          StreamBuilder<QuerySnapshot>(
            stream: _service.getFeeRecords(studentId, yearId ?? ""),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text("No payments made in this academic year.", style: TextStyle(color: Colors.grey))),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.receipt_long, color: Colors.blue),
                      ),
                      title: Text("Receipt #${data['receiptNo'] ?? 'NA'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_formatDate(data['date'])),
                      trailing: Text("₹ ${data['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(amount, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    DateTime d = timestamp.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}