import 'package:flutter/material.dart';
import 'games.dart'; 

void main() {
  runApp(const EmotionsGame());
}

class EmotionsGame extends StatelessWidget {
  const EmotionsGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmotionsHomePage(),
    );
  }
}

class EmotionsHomePage extends StatefulWidget {
  const EmotionsHomePage({super.key});

  @override
  _EmotionsHomePageState createState() => _EmotionsHomePageState();
}

class _EmotionsHomePageState extends State<EmotionsHomePage> {
  int currentStep = 0;
  List<Map<String, dynamic>> steps = [
    {
      "image": "assets/happy.jpg",
      "description": "This is a happy face. It means feeling joy and being cheerful."
    },
    {
      "image": "assets/sad.jpg",
      "description": "This is a sad face. It means feeling upset or unhappy."
    },
    {
      "image": "assets/angry.jpg",
      "description": "This is an angry face. It means feeling mad or frustrated."
    },
    {
      "image": "assets/surprised.jpg",
      "description": "This is a surprised face. It means feeling amazed or shocked."
    },
    {
      "image": "assets/scared.jpg",
      "description": "This is a scared face. It means feeling afraid of something."
    },
    {
      "image": "assets/screaming_angry.jpg",
      "description": "This is a screaming angry face. It shows being very mad."
    },
    {
      "image": "assets/screaming_scared.jpg",
      "description": "This is a screaming scared face. It shows being very afraid."
    },
    {
      "image": "assets/shy.jpg",
      "description": "This is a shy face. It means feeling a little embarrassed."
    },
    {
      "image": "assets/excited.jpg",
      "description": "This is an excited face. It means feeling very happy and eager."
    },
    {
      "image": "assets/bored.jpg",
      "description": "This is a bored face. It means feeling tired of doing nothing fun."
    }
  ];

  List<Map<String, String>> quiz = [
    {"image": "assets/happy.jpg", "answer": "Happy"},
    {"image": "assets/sad.jpg", "answer": "Sad"},
    {"image": "assets/angry.jpg", "answer": "Angry"},
    {"image": "assets/surprised.jpg", "answer": "Surprised"},
    {"image": "assets/scared.jpg", "answer": "Scared"},
    {"image": "assets/screaming_angry.jpg", "answer": "Screaming Angry"},
    {"image": "assets/screaming_scared.jpg", "answer": "Screaming Scared"},
    {"image": "assets/shy.jpg", "answer": "Shy"},
    {"image": "assets/excited.jpg", "answer": "Excited"},
    {"image": "assets/bored.jpg", "answer": "Bored"}
  ];

  bool inQuizMode = false;
  int quizIndex = 0;
  int score = 0;
  List<String> shuffledAnswers = [];

  @override
  void initState() {
    super.initState();
    shuffleAnswers();
  }

  void shuffleAnswers() {
    List<String> allAnswers = quiz.map((q) => q['answer']!).toList();
    shuffledAnswers = [quiz[quizIndex]['answer']!];
    allAnswers.remove(quiz[quizIndex]['answer']);
    shuffledAnswers.addAll((allAnswers..shuffle()).take(3));
    shuffledAnswers.shuffle();
  }

  String getResultMessage() {
    if (score <= 4) {
      return "Not bad! Try again and you will improve!";
    } else if (score <= 7) {
      return "Well done! Keep going, you're doing great!";
    } else {
      return "Excellent work! You are amazing!";
    }
  }

  void nextStep() {
    setState(() {
      if (!inQuizMode) {
        if (currentStep < steps.length - 1) {
          currentStep++;
        } else {
          inQuizMode = true;
        }
      } else {
        quizIndex++;
        if (quizIndex < quiz.length) {
          shuffleAnswers();
        }
      }
    });
  }

  void checkAnswer(String answer) {
    bool isCorrect = quiz[quizIndex]['answer'] == answer;
    setState(() {
      if (isCorrect) {
        score++;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? "Correct!" : "Wrong!"),
          content: Text(
            isCorrect
                ? "Well done!"
                : "The correct answer is: ${quiz[quizIndex]['answer']}.",
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                nextStep();
              },
              child: const Text("Next"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emotion Game"),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !inQuizMode
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              steps[currentStep]['image']!,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "Image not available",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              steps[currentStep]['description'],
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextStep,
              child: const Text("Next"),
            )
          ],
        )
            : quizIndex < quiz.length
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              quiz[quizIndex]['image']!,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "Image not available",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                );
              },
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: shuffledAnswers.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => checkAnswer(shuffledAnswers[index]),
                  child: Text(shuffledAnswers[index]),
                );
              },
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Game Over! Your score: $score / ${quiz.length}\n${getResultMessage()}",
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = 0;
                  inQuizMode = false;
                  quizIndex = 0;
                  score = 0;
                  shuffleAnswers();
                });
              },
              child: const Text("Restart"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GamesPage()),
                );
              },
              child: const Text("Back to Games"),
            )
          ],
        ),
      ),
    );
  }
}
