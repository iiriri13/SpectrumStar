import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SurveyPhotoPage extends StatefulWidget {
  const SurveyPhotoPage({Key? key}) : super(key: key);

  @override
  _SurveyPhotoPageState createState() => _SurveyPhotoPageState();
}

class _SurveyPhotoPageState extends State<SurveyPhotoPage> {
  final List<Map<String, String>> surveyQuestions = [
    {'qID': 'Q1', 'question_text': 'Does your child look at you when you call his/her name?'},
    {'qID': 'Q2', 'question_text': 'Is it easy for you to establish eye contact with your child?'},
    {'qID': 'Q3', 'question_text': 'Does your child point to indicate that s/he wants something (e.g., a toy that is out of reach)?'},
    {'qID': 'Q4', 'question_text': 'Does your child pretend? (e.g., care for dolls, talk on a toy phone)?'},
    {'qID': 'Q5', 'question_text': 'Does your child follow where you’re looking?'},
    {'qID': 'Q6', 'question_text': 'If someone in the family is visibly upset, does your child try to comfort them?'},
    {'qID': 'Q7', 'question_text': 'Can you describe your child’s first words as clear and understandable?'},
    {'qID': 'Q8', 'question_text': 'Does your child use simple gestures? (e.g., waving goodbye)'},
    {'qID': 'Q9', 'question_text': 'Does your child stare into space with no clear purpose?'},
  ];

  int currentQuestionIndex = 0;
  Map<String, int> answers = {};
  final TextEditingController childNameController = TextEditingController();
  String? selectedAge;
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool isInfoSubmitted = false;
  bool isSurveyCompleted = false;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> saveDataToFirestore() async {
    try {
      List<String> imageBase64List = [];
      for (var image in selectedImages) {
        List<int> imageBytes = await image.readAsBytes();
        String imageBase64 = base64Encode(imageBytes);
        imageBase64List.add(imageBase64);
      }

      final CollectionReference answersCollection = FirebaseFirestore.instance.collection('answers');

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
        'images': imageBase64List,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < surveyQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        isSurveyCompleted = true;
      });
    }
  }

  void showImageInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Upload Instructions'),
        content: const Text(
            'Please make sure the photos are clear and well-lit. Avoid any obstructions in the background.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              pickImage();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey & Upload Photos'),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isInfoSubmitted) ...[
                const Text(
                  'Child Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (childNameController.text.trim().isEmpty || selectedAge == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill in all fields")),
                      );
                      return;
                    }
                    setState(() {
                      isInfoSubmitted = true;
                    });
                  },
                  child: const Text('Next'),
                ),
              ] else if (!isSurveyCompleted) ...[
                const Text(
                  'Survey Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  surveyQuestions[currentQuestionIndex]['question_text']!,
                  style: const TextStyle(fontSize: 18),
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
              ] else ...[
                const Text(
                  'Upload Photos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: showImageInstructions,
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: saveDataToFirestore,
                  child: const Text('Submit'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
