import 'package:flutter/material.dart';

class DeliveryModal extends StatelessWidget {
  const DeliveryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Біздің орындарымыз",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationItem(
              city: "Ақтөбе",
              address: "Әбілқайыр хан даңғылы, 52",
              workTimeGraphic: "09:00 - 18:00",
            ),
            const SizedBox(height: 16),
            _buildLocationItem(
              city: "Астана",
              address: "Сығанақ көшесі, 60/5",
              workTimeGraphic: "10:00 - 19:00",
            ),
            const SizedBox(height: 16),
            _buildLocationItem(
              city: "Алматы",
              address: "Сатпаев көшесі, 90",
              workTimeGraphic: "08:30 - 17:30",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Жабу", style: TextStyle(color: Color(0xff0A78D6)),),
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required String city,
    required String address,
    required String workTimeGraphic,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          city,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          address,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          "Жұмыс графигі: $workTimeGraphic",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
