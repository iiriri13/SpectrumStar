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
      "question": "How you will say hello?",
      "options": [
        {"image": "assets/hello.jpg", "isCorrect": true},
        {"image": "assets/ignore.jpg", "isCorrect": false},
      ],
    },
    {
      "question": "How will you ask for help? ",
      "options": [
        {"image": "assets/ask.jpg", "isCorrect": true},
        {"image": "assets/askshy.jpg", "isCorrect": false},
      ],
    },
    {
      "question": "What would you do if you saw a toy with your friend? ",
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
      score++; 
      playSound('correct.mp3', nextScenario);
    } else {
      playSound('wrong.wav', nextScenario);
    }
  }

  void nextScenario() {
    if (currentScenarioIndex < scenarios.length - 1) {
      setState(() {
        currentScenarioIndex++; 
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
        title: const Text("Game Over!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your score: $score من ${scenarios.length}",
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
            child: const Text("Play again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context);
            },
            child: const Text("Exit the game"),
          ),
        ],
      ),
    );
  }

  String _calculatePerformance(int score, int total) {
    double percentage = (score / total) * 100;
    if (percentage >= 80) {
      return "Awsome!";
    } else if (percentage >= 50) {
      return "Very Good!";
    } else {
      return "Try again!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = scenarios[currentScenarioIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Social Skills Game"),
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
                  "Score: $score",
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
