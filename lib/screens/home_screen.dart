import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> predictions = []; // Store medication predictions

  // Function to get predictions for all medications
  Future<void> getPredictions() async {
    final url = Uri.parse('http://192.168.254.158:5000/predict_all'); // Flask server IP
    final headers = {'Content-Type': 'application/json'};

    // Example list of medications to send to the server
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
          predictions = data; // Store the predictions
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
    getPredictions(); // Fetch predictions on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Replace with actual profile image
            radius: 25,
          ),
        ),
        title: const Text(
          "Hello, Jane Doe",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: predictions.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const Text(
                    "Medication Predictions",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),

                  // Dynamic List of Predictions
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Adherence: ${medication['Adherence']}"),
                            leading: Icon(Icons.medical_services, color: Colors.green),
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
