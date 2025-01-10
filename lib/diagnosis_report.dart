import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiagnosisReportPage extends StatelessWidget {
  const DiagnosisReportPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchLatestReport() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot reports = await FirebaseFirestore.instance
        .collection('reports')
        .where('user_id', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (reports.docs.isNotEmpty) {
      return reports.docs.first.data() as Map<String, dynamic>;
    } else {
      throw Exception("No reports found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Report'),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchLatestReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading report."));
          }
          if (snapshot.hasData) {
            final reportData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Date: ${reportData['timestamp'].toDate()}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Diagnosis Result: ${reportData['diagnosis_result']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Details:",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    reportData['details'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("No report available."));
        },
      ),
    );
  }
}
