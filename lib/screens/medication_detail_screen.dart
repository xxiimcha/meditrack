import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const MedicationDetailScreen({super.key, required this.data});

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  late int quantityLeft;
  late int totalQuantity;
  late String docId;

  @override
  void initState() {
    super.initState();
    quantityLeft = widget.data['quantity_left'] ?? 0;
    totalQuantity = widget.data['total_quantity'] ?? 0;
    docId = widget.data['id'] ?? ''; // You must pass 'id' in the data map from the list
  }

  Future<void> _consumeCapsule() async {
    if (quantityLeft <= 0 || docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No capsules left or invalid record.')),
      );
      return;
    }

    try {
      setState(() {
        quantityLeft--;
      });

      await FirebaseFirestore.instance
          .collection('medication_schedules')
          .doc(docId)
          .update({'quantity_left': quantityLeft});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capsule marked as taken.')),
      );
    } catch (e) {
      setState(() => quantityLeft++); // revert on failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final name = data['medication_name'] ?? 'Unknown';
    final dosage = data['dosage'] ?? '200 mg';
    final nextDose = data['next_dose'] ?? '3:00 pm';
    final frequency = data['frequency'] ?? '';
    final doseTimes = data['instruction'] ?? '';
    final totalWeeks = data['total_weeks'] ?? 8;
    final weeksLeft = data['weeks_left'] ?? 6;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/pill.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            _pillDetailRow("Pill Name", name),
            _pillDetailRow("Pill Dosage", dosage),
            _pillDetailRow("Next Dose", nextDose),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoSection("Dose", "$frequency | $doseTimes"),
                  const SizedBox(height: 12),
                  _infoSection("Takes", "Total $totalWeeks weeks | $weeksLeft weeks left"),
                  const SizedBox(height: 12),
                  _infoSection("Quantity",
                      "Total $totalQuantity capsules | $quantityLeft capsules left"),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _consumeCapsule,
                      child: const Text("Submit", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _infoSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F5D50)),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}
