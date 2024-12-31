import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SocialSkillsGame extends StatefulWidget {
  const SocialSkillsGame({Key? key}) : super(key: key);

  @override
  _SocialSkillsGameState createState() => _SocialSkillsGameState();
}

class _SocialSkillsGameState extends State<SocialSkillsGame> {
  int currentScenarioIndex = 0; 
  int score = 0; 
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlayingSound = false; 
  bool gameEnded = false; 

  final List<Map<String, dynamic>> scenarios = [
    {
      "question": "كيف تقول أهلاً؟",
      "options": [
        {"image": "assets/hello.jpg", "isCorrect": true},
        {"image": "assets/ignore.jpg", "isCorrect": false},
      ],
    },
    {
      "question": "ماذا تفعل إذا احتجت شيئًا؟",
      "options": [
        {"image": "assets/ask.jpg", "isCorrect": true},
        {"image": "assets/askshy.jpg", "isCorrect": false},
      ],
    },
    {
      "question": "ماذا تفعل إذا رأيت لعبة؟",
      "options": [
        {"image": "assets/ask_share.png", "isCorrect": true},
        {"image": "assets/take_force.png", "isCorrect": false},
      ],
    },
  ];

  void playSound(String soundPath, VoidCallback onComplete) async {
    if (isPlayingSound) return;

    setState(() {
      isPlayingSound = true;
    });

    try {
      await _audioPlayer.setSource(AssetSource(soundPath));
      await _audioPlayer.resume();

      _audioPlayer.onPlayerComplete.listen((_) {
        onComplete();
        setState(() {
          isPlayingSound = false;
        });
      });
    } catch (e) {
      print("Error playing sound: $e");
      setState(() {
        isPlayingSound = false;
      });
      onComplete();
    }
  }

  void checkAnswer(bool isCorrect) {
    if (isCorrect) {
      score++; // زيادة النقاط
      playSound('correct.mp3', nextScenario);
    } else {
      playSound('wrong.wav', nextScenario);
    }
  }

  void nextScenario() {
    if (currentScenarioIndex < scenarios.length - 1) {
      setState(() {
        currentScenarioIndex++; // التحديث للسؤال التالي
      });
    } else if (!gameEnded) {
      gameEnded = true;
      showEndDialog();
    }
  }

  void showEndDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("انتهت اللعبة!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "نتيجتك: $score من ${scenarios.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _calculatePerformance(score, scenarios.length),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentScenarioIndex = 0;
                score = 0;
                gameEnded = false;
              });
            },
            child: const Text("إعادة اللعب"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context);
            },
            child: const Text("الخروج"),
          ),
        ],
      ),
    );
  }

  String _calculatePerformance(int score, int total) {
    double percentage = (score / total) * 100;
    if (percentage >= 80) {
      return "رائع جدًا!";
    } else if (percentage >= 50) {
      return "جيد!";
    } else {
      return "حاول مرة أخرى!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = scenarios[currentScenarioIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("لعبة المهارات الاجتماعية"),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  scenario['question'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: scenario['options'].map<Widget>((option) {
                    return GestureDetector(
                      onTap: () => checkAnswer(option['isCorrect']),
                      child: Image.asset(
                        option['image'],
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  "النتيجة: $score",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
