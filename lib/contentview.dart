import 'package:flutter/material.dart';
import 'profile.dart';
import 'centers.dart'; 
import 'games.dart';
import 'ai_diagnosis.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Welcome',
          style: TextStyle(color: Colors.black, fontSize: 24),  
        ),
        iconTheme: const IconThemeData(color: Colors.black, size: 30), 
        leading: IconButton(
          icon: const Icon(Icons.account_circle, size: 35), 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
             Image.asset('assets/logo.jpg', width: 300, height: 300),
            const SizedBox(height: 60), 

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CentersPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB2A4D4),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), 
                          textStyle: const TextStyle(fontSize: 20), 
                        ),
                        child: const Text('Centers'),
                      ),
                      const SizedBox(width: 30), 

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GamesPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB2A4D4),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), 
                          textStyle: const TextStyle(fontSize: 20), 
                        ),
                        child: const Text('Games'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50), 

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AiDiagnosisPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB2A4D4),
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 25), 
                      textStyle: const TextStyle(fontSize: 20), 
                    ),
                    child: const Text('AI Diagnosis'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
