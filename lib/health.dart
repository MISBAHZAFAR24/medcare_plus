import 'package:flutter/material.dart';
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
        if (bmi < 18.5) { bmiStatus = "Underweight"; statusColor = Colors.orange; }
        else if (bmi < 24.9) { bmiStatus = "Normal"; statusColor = Colors.green; }
        else { bmiStatus = "Overweight/Obese"; statusColor = Colors.red; }
      });
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
      }
      if (newHeart != null) {
        heartValues.add(newHeart);
        if (heartValues.length > 7) heartValues.removeAt(0);
      }
      if (newOxygen != null && newOxygen <= 100) {
        oxygenValues.add(newOxygen);
        if (oxygenValues.length > 7) oxygenValues.removeAt(0);
      }
    });

    // Clear inputs after adding
    bpInputCtrl.clear();
    heartInputCtrl.clear();
    oxygenInputCtrl.clear();

    FocusScope.of(context).unfocus(); // Keyboard band karne ke liye
  }

  // Helper Widget for Bars
  Widget buildBar(int value, Color color) {
    double heightFactor = value.toDouble();
    if (heightFactor > 150) heightFactor = 150; // Max height limit

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        Container(
          width: 25,
          height: heightFactor,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
      ],
    );
  }

  // Helper Widget for Graph Cards
  Widget graphCard(String title, List<int> values, Color color) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: values.map((e) => buildBar(e, color)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Monitor Pro")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BMI Section ---
            Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text("BMI Calculator", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: "Height (cm)"), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: calculateBMI, child: const Text("Calculate BMI")),
                    if (bmiResult != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text("BMI: ${bmiResult!.toStringAsFixed(1)} ($bmiStatus)", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                  ],
                ),
              ),
            ),

            // --- Data Entry Section ---
            Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text("Update Stats", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: bpInputCtrl, decoration: const InputDecoration(labelText: "BP (e.g. 120)"), keyboardType: TextInputType.number),
                    TextField(controller: heartInputCtrl, decoration: const InputDecoration(labelText: "Heart Rate (e.g. 72)"), keyboardType: TextInputType.number),
                    TextField(controller: oxygenInputCtrl, decoration: const InputDecoration(labelText: "Oxygen % (e.g. 98)"), keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: addHealthData,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                      child: const Text("Update All Graphs"),
                    ),
                  ],
                ),
              ),
            ),

            // --- Graphs ---
            graphCard("Blood Pressure History", bpValues, Colors.redAccent),
            graphCard("Heart Rate History", heartValues, Colors.blueAccent),
            graphCard("Oxygen Level (%) History", oxygenValues, Colors.teal),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
