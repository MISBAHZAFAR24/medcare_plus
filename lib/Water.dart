import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
class Water extends StatefulWidget {
  const Water({super.key});

  @override
  State<Water> createState() => _WaterState();
}

class _WaterState extends State<Water> {
  int glass = 0;
  int goal = 8;
  TimeOfDay? time;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  Future<void> setReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        time = picked;
      });
    }
  }

  void startReminder() {
    if (time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select time first")),
      );
      return;
    }
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Water Reminder Set for ${time!.format(context)}")),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = TimeOfDay.now();
      if (now.hour == time!.hour && now.minute == time!.minute) {dir
        _audioPlayer.play(AssetSource('audio/samsung_galaxy_s22.mp3'));
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("💧 Pani peene ka waqt ho gaya!")),
        );
      }
    });
  }

  void stopAlarm() {
    _audioPlayer.stop();
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reminder Stopped ❌")),
    );
  }

  void reset() {
    setState(() {
      glass = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = glass / goal;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Water Tracker"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- Glass Design Section ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Glass Shape
                    Container(
                      height: 200,
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 4),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    // Water inside the glass
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: (progress > 1 ? 1 : progress) * 190, // Max height limit
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$glass / $goal Glasses",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 20),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(Icons.add, () => setState(() => glass++)),
                  const SizedBox(width: 30),
                  _actionButton(Icons.remove, () {
                    if (glass > 0) setState(() => glass--);
                  }),
                ],
              ),
              const SizedBox(height: 30),

              // Settings & Reminders
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Daily Goal:", style: TextStyle(fontSize: 16)),
                          DropdownButton<int>(
                            value: goal,
                            items: [6, 8, 10, 12].map((e) => DropdownMenuItem(value: e, child: Text("$e glasses"))).toList(),
                            onChanged: (val) { if (val != null) setState(() { goal = val; }); },
                          ),
                        ],
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.alarm, color: Colors.blue),
                        title: Text(time == null ? "Set Reminder" : "Time: ${time!.format(context)}"),
                        trailing: ElevatedButton(onPressed: setReminder, child: const Text("Pick")),
                      ),
                      if (time != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: startReminder,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                child: const Text("Start Reminder"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: stopAlarm,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                child: const Text("Stop"),
                              ),
                            ),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh, color: Colors.grey),
                label: const Text("Reset Progress", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
