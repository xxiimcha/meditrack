import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ for getting current user

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> predictions = [];
  bool isLoading = true;
  String userName = "Loading..."; // 👈 Default until fetched

  Future<void> checkPatientsAndLoad() async {
    setState(() => isLoading = true);

    try {
      await fetchUserName(); // ✅ Get user name before checking patients

      final snapshot = await FirebaseFirestore.instance.collection('patients').get();

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
        await getPredictions();
      }
    } catch (e) {
      print('Error checking patients: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = "${doc['first_name']} ${doc['last_name']}";
          });
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
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
  void initState() {
    super.initState();
    checkPatientsAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            radius: 25,
          ),
        ),
        title: Text(
          "Hello, $userName",
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
              ? const Center(child: Text("No predictions available."))
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
                          color: Colors.black,
                        ),
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
                                leading: const Icon(Icons.medical_services, color: Colors.green),
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
