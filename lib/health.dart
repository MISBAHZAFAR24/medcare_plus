import 'package:flutter/material.dart';
import 'dart:ui';
import 'main.dart';

class Health extends StatefulWidget {
  const Health({super.key});

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  // Controllers for inputs
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final bpInputCtrl = TextEditingController();
  final heartInputCtrl = TextEditingController();
  final oxygenInputCtrl = TextEditingController();

  // BMI Variables
  double? bmiResult;
  String bmiStatus = "";
  Color statusColor = Colors.black;

  // Graphs Data Lists (Starting data)
  List<int> bpValues = [110, 120, 115, 125, 120];
  List<int> heartValues = [70, 72, 75, 68, 74];
  List<int> oxygenValues = [98, 97, 99, 96, 98];

  // 1. BMI Calculation Logic
  void calculateBMI() {
    double? weight = double.tryParse(weightCtrl.text);
    double? heightInCm = double.tryParse(heightCtrl.text);

    if (weight != null && heightInCm != null && heightInCm > 0) {
      double bmi = weight / ((heightInCm / 100) * (heightInCm / 100));
      setState(() {
        bmiResult = bmi;
        if (bmi < 18.5) {
          bmiStatus = "Underweight";
          statusColor = Colors.orange;
        } else if (bmi < 24.9) {
          bmiStatus = "Normal";
          statusColor = Colors.green;
        } else {
          bmiStatus = "Overweight/Obese";
          statusColor = Colors.red;
        }
      });
      addHealthRecord("BMI Calculated", "Result: ${bmi.toStringAsFixed(1)} ($bmiStatus)", Icons.calculate, statusColor);
    }
  }

  // 2. Add Data to Graphs Logic
  void addHealthData() {
    int? newBP = int.tryParse(bpInputCtrl.text);
    int? newHeart = int.tryParse(heartInputCtrl.text);
    int? newOxygen = int.tryParse(oxygenInputCtrl.text);

    setState(() {
      if (newBP != null) {
        bpValues.add(newBP);
        if (bpValues.length > 7) bpValues.removeAt(0);
        addHealthRecord("BP Updated", "New reading: $newBP", Icons.speed, Colors.redAccent);
      }
      if (newHeart != null) {
        heartValues.add(newHeart);
        if (heartValues.length > 7) heartValues.removeAt(0);
        addHealthRecord("Heart Rate", "New reading: $newHeart bpm", Icons.favorite, Colors.blueAccent);
      }
      if (newOxygen != null && newOxygen <= 100) {
        oxygenValues.add(newOxygen);
        if (oxygenValues.length > 7) oxygenValues.removeAt(0);
        addHealthRecord("Oxygen Level", "New reading: $newOxygen%", Icons.air, Colors.teal);
      }
    });

    // Clear inputs after adding
    bpInputCtrl.clear();
    heartInputCtrl.clear();
    oxygenInputCtrl.clear();

    FocusScope.of(context).unfocus(); // Keyboard band karne ke liye
  }

  // Helper Widget for Bars
  Widget buildBar(int value, Color color, bool isDark) {
    double heightFactor = value.toDouble();
    if (heightFactor > 150) heightFactor = 150; // Max height limit

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value.toString(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 4),
        Container(
          width: 25,
          height: heightFactor,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget for Graph Cards
  Widget graphCard(String title, List<int> values, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              Icon(Icons.trending_up, color: color.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: values.map((e) => buildBar(e, color, isDark)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputStyle(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Health Monitor Pro",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.teal.withValues(alpha: 0.1)),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF0FDFA), const Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 120, 0, 100),
          child: Column(
            children: [
              // --- BMI Section ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.teal),
                        SizedBox(width: 10),
                        Text("BMI Calculator",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: weightCtrl,
                                style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black),
                                decoration: inputStyle("Weight (kg)", isDark),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: heightCtrl,
                                style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black),
                                decoration: inputStyle("Height (cm)", isDark),
                                keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: calculateBMI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Calculate BMI",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (bmiResult != null)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Result: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                            Text("${bmiResult!.toStringAsFixed(1)} ($bmiStatus)",
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // --- Data Entry Section ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Text("Update Daily Stats",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                        controller: bpInputCtrl,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: inputStyle("BP (e.g. 120)", isDark),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    TextField(
                        controller: heartInputCtrl,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: inputStyle("Heart Rate (e.g. 72)", isDark),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    TextField(
                        controller: oxygenInputCtrl,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: inputStyle("Oxygen % (e.g. 98)", isDark),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addHealthData,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: const Text("UPDATE GRAPHS",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  children: [
                    Text("Analytics 📈", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // --- Graphs ---
              graphCard("Blood Pressure History", bpValues, Colors.redAccent, isDark),
              graphCard("Heart Rate History", heartValues, Colors.blueAccent, isDark),
              graphCard("Oxygen Level (%) History", oxygenValues, Colors.teal, isDark),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
