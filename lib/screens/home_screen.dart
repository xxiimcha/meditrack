import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/pill_card.dart';
import '../widgets/vitamin_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String prediction = "Fetching...";

  // Function to get predictions from Flask API
  Future<void> getPrediction() async {
    final url = Uri.parse('http://192.168.254.158:5000/predict'); // Replace with your Flask server IP
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'Age': 67, // Example input
      'Gender': 1, // Adjust based on your encoding
      'Condition': 3,
      'Medication': 2,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          prediction = data['adherence_prediction'];
        });
      } else {
        setState(() {
          prediction = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        prediction = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPrediction(); // Fetch prediction on screen load
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prediction Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prediction Result:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prediction,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pills for Today Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pills for today",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("See all"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PillCard(
                title: "Paracetamol",
                dosage: "20mg",
                time: "10:00 AM",
                takes: "3 left",
              ),
              const SizedBox(height: 20),

              // Additional Vitamins Section
              const Text(
                "Additional Vitamins",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              VitaminCard(
                title: "Omega 3",
                time: "9:30 PM | After eating",
              ),
              const SizedBox(height: 10),
              VitaminCard(
                title: "Multivitamins",
                time: "11:00 AM | Before eating",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
