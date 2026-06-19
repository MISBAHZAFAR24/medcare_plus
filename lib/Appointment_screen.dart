import 'package:flutter/material.dart';
import 'dart:math';
class AppointmentScreen extends StatefulWidget {
  final Map<String, String> doc;
  const AppointmentScreen({super.key, required this.doc});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  // Controllers to get user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String selectedTime = "10:00 AM";

  String generateAppointmentID() {
    var random = Random();
    return "APP-${10000 + random.nextInt(90000)}";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = widget.doc["spec"]!.contains("Ayurvedic") ? Colors.green : Colors.teal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👨‍⚕️ DOCTOR INFO MINI-CARD
            _buildDoctorHeader(themeColor),

            const SizedBox(height: 25),
            const Text("Patient Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 👤 NAME INPUT
            _buildTextField(_nameController, "Patient Full Name", Icons.person, themeColor),
            const SizedBox(height: 15),

            // 📞 CONTACT INPUT
            _buildTextField(_phoneController, "Contact Number", Icons.phone, themeColor, isNumber: true),

            const SizedBox(height: 25),
            const Text("Select Date & Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 📅 DATE PICKER TILE
            _buildDatePicker(themeColor),

            const SizedBox(height: 15),

            // 🕒 TIME PICKER TILE
            _buildTimePicker(themeColor),

            const SizedBox(height: 40),

            // 💳 FINAL BOOKING BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all details! ⚠️")),
                    );
                    return;
                  }
                  _showFinalReceipt(context, generateAppointmentID(), themeColor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("CONFIRM & PAY FEES", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE UI WIDGETS ---

  Widget _buildDoctorHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(widget.doc["emoji"]!, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.doc["name"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Fees: ${widget.doc['fees']}", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, Color color, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
      ),
    );
  }

  Widget _buildDatePicker(Color color) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) setState(() => selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(fontSize: 16)),
            Icon(Icons.event, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(Color color) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) setState(() => selectedTime = time.format(context));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedTime, style: const TextStyle(fontSize: 16)),
            Icon(Icons.access_time, color: color),
          ],
        ),
      ),
    );
  }

  // 🔥 FINAL RECEIPT DIALOG
  void _showFinalReceipt(BuildContext context, String appID, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("Appointment Receipt 🧾")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(appID, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color))),
            const Divider(height: 30),
            _receiptRow("Patient:", _nameController.text),
            _receiptRow("Contact:", _phoneController.text),
            _receiptRow("Doctor:", widget.doc["name"]!),
            _receiptRow("Date:", "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
            _receiptRow("Time:", selectedTime),
            _receiptRow("Fees Paid:", widget.doc["fees"]!, isBold: true),
            const SizedBox(height: 20),
            const Center(child: Text("Show this ID at the hospital reception.", style: TextStyle(fontSize: 11, color: Colors.grey))),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: const Text("DOWNLOAD & DONE", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}