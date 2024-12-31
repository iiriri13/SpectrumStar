import 'package:flutter/material.dart';

class ViewReports extends StatelessWidget {
  const ViewReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFFF0F0F0),
              margin: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                title: Text(
                  "Report #${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Details of report #${index + 1}"),
                trailing: const Icon(Icons.description, color: Colors.purple),
              ),
            );
          },
        ),
      ),
    );
  }
}
