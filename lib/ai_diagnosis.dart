import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: AiDiagnosisPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class AiDiagnosisPage extends StatelessWidget {
  const AiDiagnosisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diagnosis'),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SurveyPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2A4D4),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Survey'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadPhotosPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2A4D4),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Upload Photos'),
            ),
          ],
        ),
      ),
    );
  }
}

class SurveyPage extends StatefulWidget {
  const SurveyPage({Key? key}) : super(key: key);

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final List<Map<String, String>> surveyQuestions = [
    {'qID': 'Q1', 'question_text': 'Does your child look at you when you call his/her name?'},
    {'qID': 'Q2', 'question_text': 'Is it easy for you to establish eye contact with your child?'},
    {'qID': 'Q3', 'question_text': 'Dose your child point to indicate that s/he wants something (e.g.a) toy that is out of reach?'},
    {'qID': 'Q4', 'question_text': 'Dose yor child pretend? (e.g. care for dolls, talk on a toy phone)?'},
    {'qID': 'Q5', 'question_text': 'Dose your child follow where you’re looking?'},
    {'qID': 'Q6', 'question_text': 'If you or someone else in the family is visibly upset, does your child show signs of trying to comfort you? (e.g., stroking hair or hugging)?'},
    {'qID': 'Q7', 'question_text': 'Can you describe your child’s first words as clear and understandable?'},
    {'qID': 'Q8', 'question_text': 'Does your child use simple gestures? (e.g., waving goodbye)'},
    {'qID': 'Q9', 'question_text': 'Does your child stare into space with no clear purpose?'},
  ];

  int currentQuestionIndex = 0;
  Map<String, int> answers = {};
  final TextEditingController childNameController = TextEditingController();
  String? selectedAge;
  bool infoSubmitted = false;

  Future<void> saveAnswersToFirestore(Map<String, int> answers) async {
    try {
      final CollectionReference answersCollection = FirebaseFirestore.instance.collection('answers');

      // ترتيب الإجابات حسب ترتيب الأسئلة
      Map<String, int> orderedAnswers = {};
      for (var question in surveyQuestions) {
        orderedAnswers[question['qID']!] = answers[question['qID']!] ?? 0;
      }

      await answersCollection.add({
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? "unknown_user",
        'child_name': childNameController.text.trim(),
        'child_age': selectedAge ?? "unknown_age",
        'timestamp': Timestamp.now(),
        'answers': orderedAnswers,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Responses saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving responses: $e")),
      );
    }
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex == surveyQuestions.length - 1) {
      saveAnswersToFirestore(answers);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Survey Completed'),
            content: const Text('Your responses have been saved successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey'),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: infoSubmitted
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                surveyQuestions[currentQuestionIndex]['question_text']!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  answers[surveyQuestions[currentQuestionIndex]['qID']!] = 1;
                  moveToNextQuestion();
                },
                child: const Text('Yes'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  answers[surveyQuestions[currentQuestionIndex]['qID']!] = 0;
                  moveToNextQuestion();
                },
                child: const Text('No'),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: childNameController,
                decoration: const InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Child Age',
                  border: OutlineInputBorder(),
                ),
                value: selectedAge,
                items: List.generate(17, (index) {
                  int age = index + 1;
                  return DropdownMenuItem(
                    value: age.toString(),
                    child: Text(age.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (childNameController.text.trim().isEmpty || selectedAge == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill in all fields")),
                    );
                    return;
                  }
                  setState(() {
                    infoSubmitted = true;
                  });
                },
                child: const Text('Start Survey'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadPhotosPage extends StatefulWidget {
  const UploadPhotosPage({Key? key}) : super(key: key);

  @override
  _UploadPhotosPageState createState() => _UploadPhotosPageState();
}

class _UploadPhotosPageState extends State<UploadPhotosPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> uploadImagesToFirestore() async {
    try {
      List<String> imageBase64List = [];
      for (var image in selectedImages) {
        List<int> imageBytes = await image.readAsBytes();
        String imageBase64 = base64Encode(imageBytes);
        imageBase64List.add(imageBase64);
      }

      await FirebaseFirestore.instance.collection('uploads').add({
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? "unknown_user",
        'timestamp': Timestamp.now(),
        'images': imageBase64List,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Images uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading images: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Image.file(
                      selectedImages[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: uploadImagesToFirestore,
              child: const Text('Upload Images'),
            ),
          ],
        ),
      ),
    );
  }
}
