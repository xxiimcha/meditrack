import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> predictions = [];
  bool isLoading = true;
  String userFullName = "Loading...";
  Map<String, dynamic>? patientData;

  @override
  void initState() {
    super.initState();
    loadUserData();
    checkPatientsAndLoad();
  }

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            userFullName = "${data['first_name']} ${data['last_name']}";
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        userFullName = "User";
      });
    }
  }

  Future<void> checkPatientsAndLoad() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('No Patient Found'),
            content: const Text('You have no registered patients yet. Please fill out the form.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/patient_form');
                },
                child: const Text('Proceed to Form'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          patientData = snapshot.docs.first.data();
        });
        await getPredictions();
      }
    } catch (e) {
      print('Error checking patients: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> getPredictions() async {
    final url = Uri.parse('http://192.168.254.158:5000/predict_all');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode([
      {'Age': 67, 'Gender': 1, 'Condition': 3, 'Medication': 2, 'Medication_Name': "Paracetamol"},
      {'Age': 60, 'Gender': 0, 'Condition': 2, 'Medication': 1, 'Medication_Name': "Aspirin"},
      {'Age': 45, 'Gender': 1, 'Condition': 1, 'Medication': 3, 'Medication_Name': "Metformin"},
    ]);

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          predictions = data;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.purple[100],
            radius: 25,
            child: const Icon(Icons.person, color: Colors.black),
          ),
        ),
        title: Text(
          "Hello, $userFullName",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : predictions.isEmpty
              ? patientData != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xF9F5F0), // Light beige/cream
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon (you can use a different icon or image here)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.medication, size: 32, color: Color(0xFF2F5D50)),
                            ),
                            const SizedBox(width: 16),

                            // Text content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientData!['medication'] ?? 'Medication',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2F5D50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "9:30 pm | After eating", // You can make this dynamic later
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF78917C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    )
                  : const Center(child: Text("No predictions available."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Medication Predictions",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: predictions.length,
                          itemBuilder: (context, index) {
                            final medication = predictions[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: ListTile(
                                title: Text(
                                  medication['Medication_Name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Adherence: ${medication['Adherence']}"),
                                leading:
                                    const Icon(Icons.medical_services, color: Colors.green),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
