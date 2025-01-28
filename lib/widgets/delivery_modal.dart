import 'package:flutter/material.dart';

class DeliveryModal extends StatelessWidget {
  const DeliveryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Наши локации",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationItem(
              city: "Актобе",
              address: "проспект Абилкайыр хана, 52",
              workTimeGraphic: "09:00 - 18:00",
            ),
            const SizedBox(height: 16),
            _buildLocationItem(
              city: "Астана",
              address: "ул. Сыганак, 60/5",
              workTimeGraphic: "10:00 - 19:00",
            ),
            const SizedBox(height: 16),
            _buildLocationItem(
              city: "Алматы",
              address: "ул. Сатпаева, 90",
              workTimeGraphic: "08:30 - 17:30",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Закрыть"),
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
          "График работы: $workTimeGraphic",
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
