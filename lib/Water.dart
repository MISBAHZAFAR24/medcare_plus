import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

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

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      glass = prefs.getInt('water_glass') ?? 0;
      goal = prefs.getInt('water_goal') ?? 8;
      int? hour = prefs.getInt('water_reminder_hour');
      int? minute = prefs.getInt('water_reminder_minute');
      if (hour != null && minute != null) {
        time = TimeOfDay(hour: hour, minute: minute);
      }
    });
  }

  Future<void> _saveWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_glass', glass);
    await prefs.setInt('water_goal', goal);
    if (time != null) {
      await prefs.setInt('water_reminder_hour', time!.hour);
      await prefs.setInt('water_reminder_minute', time!.minute);
    }
  }

  Future<void> setReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        time = picked;
      });
      _saveWaterData();
    }
  }

  void startReminder() {
    if (time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bhai, pehle time toh select karo! ⏰"), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Water Reminder Set for ${time!.format(context)} 💧"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = TimeOfDay.now();
      if (now.hour == time!.hour && now.minute == time!.minute) {
        _audioPlayer.play(AssetSource('audio/samsung_galaxy_s22.mp3'));
        timer.cancel();
        _showAlarmOverlay();
      }
    });
  }

  void _showAlarmOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Pani Peelo! 💧",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Health is wealth, bhai. 1 glass pani peene ka waqt ho gaya!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("OKAY, DRANK! ✅", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void stopAlarm() {
    _audioPlayer.stop();
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reminder Stopped ❌"), behavior: SnackBarBehavior.floating),
    );
  }

  void reset() {
    setState(() {
      glass = 0;
    });
    _saveWaterData();
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Hydration Pro", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.blueAccent.withValues(alpha: 0.1)),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [const Color(0xFF071927), const Color(0xFF0F172A)]
                : [const Color(0xFFE0F2FE), const Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            children: [
              // 🌊 GLASS VISUALIZER
              _buildPremiumGlass(progress, isDark),
              
              const SizedBox(height: 30),
              Text(
                "$glass / $goal Glasses",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const Text("Today's Goal", style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 40),

              // ➕ CONTROLS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _glassButton(Icons.remove, () {
                    if (glass > 0) {
                      setState(() => glass--);
                      _saveWaterData();
                    }
                  }, isDark),
                  const SizedBox(width: 40),
                  _glassButton(Icons.add, () {
                    setState(() => glass++);
                    _saveWaterData();
                    addHealthRecord("Water Intake", "Drank 1 glass of water", Icons.water_drop, Colors.blueAccent);
                  }, isDark, isPrimary: true),
                ],
              ),

              const SizedBox(height: 50),

              // ⚙️ SETTINGS CARD
              _buildSettingsCard(isDark),
              
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh, color: Colors.grey),
                label: const Text("Reset Daily Progress", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumGlass(double progress, bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Glass Outline
          Container(
            height: 250,
            width: 140,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3), width: 4),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          // Water Fill
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutBack,
            height: (progress.clamp(0.0, 1.0)) * 240,
            width: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
              boxShadow: [
                BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap, bool isDark, {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.blueAccent : (isDark ? Colors.white10 : Colors.white),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), 
              blurRadius: 10, 
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : Colors.blueAccent, size: 30),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
        ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daily Goal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                value: goal,
                underline: const SizedBox(),
                items: [6, 8, 10, 12].map((e) => DropdownMenuItem(value: e, child: Text("$e Glasses"))).toList(),
                onChanged: (val) { 
                  if (val != null) {
                    setState(() => goal = val);
                    _saveWaterData();
                  }
                },
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reminder Alarm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(time == null ? "Not Set" : "Time: ${time!.format(context)}", 
                      style: TextStyle(fontSize: 14, color: time == null ? Colors.grey : Colors.blueAccent)),
                ],
              ),
              IconButton(
                onPressed: setReminder, 
                icon: const Icon(Icons.edit_calendar, color: Colors.blueAccent)
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: startReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("START REMINDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("STOP"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
