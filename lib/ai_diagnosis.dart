import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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

// Survey Page
class SurveyPage extends StatefulWidget {
  const SurveyPage({Key? key}) : super(key: key);

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final List<Map<String, String>> surveyQuestions = [
    {'qID': 'Q1', 'question_text': 'Does your child look at you when you call his/her name?'},
    {'qID': 'Q2', 'question_text': 'How easy is it for you to get eye contact with your child?'},
    {'qID': 'Q3', 'question_text': 'Does your child point to indicate that s/he wants something?'},
    {'qID': 'Q4', 'question_text': 'Does your child point to share interest with you?'},
    {'qID': 'Q5', 'question_text': 'Does your child pretend? (e.g. care for dolls, talk on a toy phone)'},
    {'qID': 'Q6', 'question_text': 'Does your child follow where you’re looking?'},
    {'qID': 'Q7', 'question_text': 'If someone is visibly upset, does your child show signs of comforting them?'},
    {'qID': 'Q8', 'question_text': 'Would you describe your child’s first words as?'},
    {'qID': 'Q9', 'question_text': 'Does your child use simple gestures? (e.g. wave goodbye)'},
    {'qID': 'Q10', 'question_text': 'Does your child stare at nothing with no apparent purpose?'},
  ];

  int currentQuestionIndex = 0;
  Map<String, int> answers = {};

  Future<void> saveAnswersToFirestore(Map<String, int> answers) async {
    try {
      final CollectionReference answersCollection =
      FirebaseFirestore.instance.collection('answers');

      await answersCollection.add({
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? "unknown_user",
        'timestamp': Timestamp.now(),
        'answers': answers,
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
          child: Column(
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
          ),
        ),
      ),
    );
  }
}

// Upload Photos Page
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

  Future<void> uploadImagesToFirebase() async {
    try {
      List<String> imageUrls = [];
      for (var image in selectedImages) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(image);
        String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance.collection('uploads').add({
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? "unknown_user",
        'timestamp': Timestamp.now(),
        'images': imageUrls,
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
              onPressed: uploadImagesToFirebase,
              child: const Text('Upload Images'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: AiDiagnosisPage(),
    debugShowCheckedModeBanner: false,
  ));
}
