import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  void _showAddScheduleDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController frequencyController = TextEditingController();
    final TextEditingController intervalController = TextEditingController();
    final TextEditingController instructionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.only(top: 20),
          title: const Center(
            child: Text(
              'Add Medication Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F5D50),
              ),
            ),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const SizedBox(height: 10),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    prefixIcon: const Icon(Icons.medication_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: frequencyController,
                  decoration: InputDecoration(
                    labelText: 'Frequency (e.g. 3 times a day)',
                    prefixIcon: const Icon(Icons.repeat),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: intervalController,
                  decoration: InputDecoration(
                    labelText: 'Interval (e.g. every 8 hours)',
                    prefixIcon: const Icon(Icons.schedule),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: instructionController,
                  decoration: InputDecoration(
                    labelText: 'Instruction (e.g. After eating)',
                    prefixIcon: const Icon(Icons.notes),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not logged in.")),
                  );
                  return;
                }

                try {
                  final patientSnapshot = await FirebaseFirestore.instance
                      .collection('patients')
                      .where('user_id', isEqualTo: user.uid)
                      .limit(1)
                      .get();

                  if (patientSnapshot.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No patient profile found.")),
                    );
                    return;
                  }

                  final patientId = patientSnapshot.docs.first.id;

                  await FirebaseFirestore.instance.collection('medication_schedules').add({
                    'patient_id': patientId,
                    'user_id': user.uid,
                    'medication_name': nameController.text.trim(),
                    'frequency': frequencyController.text.trim(),
                    'interval': intervalController.text.trim(), // ✅ New field
                    'instruction': instructionController.text.trim(),
                    'created_at': Timestamp.now(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Schedule saved successfully.")),
                  );
                } catch (e) {
                  print('Error saving schedule: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5D50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/schedule');
        } else if (index == 2) {
          _showAddScheduleDialog(context);
        }
        // Handle navigation for index 3 and 4 as needed
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
