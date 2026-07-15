import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';
class Disease extends StatefulWidget {
  const Disease({super.key});

  @override
  State<Disease> createState() => _DiseaseState();
}

class _DiseaseState extends State<Disease> {
  final searchCtrl = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  Map<String, dynamic>? result;
  TimeOfDay? selectedTime;

  // 🏥 50 Diseases ka Data (Class ke andar hona chahiye)
  final Map<String, Map<String, dynamic>> diseaseData = {
    "Diabetes": {"icon": "🩸", "medicine": ["💊 Metformin", "💉 Insulin"], "diet": ["🥗 Oats", "🍎 Apple", "🥦 Broccoli"], "duration": "📅 Lifetime ♾️"},
    "Fever": {"icon": "🌡️", "medicine": ["💊 Paracetamol", "💧 Fluids"], "diet": ["🍲 Hot Soup", "🥣 Khichdi", "🥛 Milk"], "duration": "⏳ 3-5 Days"},
    "High BP": {"icon": "💓", "medicine": ["💊 Amlodipine", "🩺 BP Care"], "diet": ["🍌 Banana", "🥦 Veggies", "🥗 Low Salt"], "duration": "📅 Daily ☀️"},
    "Low BP": {"icon": "📉", "medicine": ["🧂 Salt Water", "☕ Coffee"], "diet": ["🥨 Salty Snacks", "🥤 Juice"], "duration": "⏳ 2 Days"},
    "Cold": {"icon": "🤧", "medicine": ["💊 Cetirizine", "🧪 Vicks"], "diet": ["☕ Ginger Tea", "🍯 Honey", "🍲 Soup"], "duration": "⏳ 5 Days"},
    "Cough": {"icon": "🗣️", "medicine": ["🧪 Syrup", "💊 Lozenges"], "diet": ["🍯 Honey", "🫚 Turmeric Milk", "☕ Warm Water"], "duration": "⏳ 7 Days"},
    "Heart Disease": {"icon": "🫀", "medicine": ["💊 Aspirin", "🧪 Statins"], "diet": ["🫘 Walnuts", "🐟 Fish", "🍓 Berries"], "duration": "📅 Lifetime ♾️"},
    "Asthma": {"icon": "🫁", "medicine": ["🌬️ Inhaler", "💊 Rotacaps"], "diet": ["☕ Warm Water", "🍎 Fruits"], "duration": "📅 Ongoing 🌬️"},
    "Migraine": {"icon": "🧠", "medicine": ["💊 Naproxen", "🧪 Sumatriptan"], "diet": ["🥬 Spinach", "🫘 Magnesium Food"], "duration": "⏳ During Attack"},
    "Thyroid": {"icon": "🦋", "medicine": ["💊 Thyroxine"], "diet": ["🥛 Milk", "🥚 Eggs", "🥦 Seaweed"], "duration": "📅 Daily Morning ☀️"},
    "Obesity": {"icon": "⚖️", "medicine": ["💊 Orlistat"], "diet": ["🥗 Salad", "🍋 Lemon Water", "🥣 Oats"], "duration": "📅 6 Months+ 🏃‍♂️"},
    "Anemia": {"icon": "🍷", "medicine": ["💊 Iron Tablets", "🧪 Vit-B12"], "diet": ["🍎 Pomegranate", "🥬 Spinach", "🥩 Meat"], "duration": "⏳ 3 Months 🩸"},
    "Arthritis": {"icon": "🦴", "medicine": ["💊 Diclofenac", "🧴 Gel"], "diet": ["🐟 Omega-3", "🫚 Ginger", "🍒 Cherries"], "duration": "📅 Long-term 🦴"},
    "Back Pain": {"icon": "🧍", "medicine": ["💊 Painkillers", "🧴 Spray"], "diet": ["🥛 Milk", "🧀 Calcium Food"], "duration": "⏳ 1 Week 🧘‍♂️"},
    "Kidney Stone": {"icon": "💎", "medicine": ["🧪 Cystone", "💊 Alkalizers"], "diet": ["💧 4L Water", "🍋 Lemon Juice"], "duration": "⏳ 1 Month 💧"},
    "Liver Disease": {"icon": "🍺", "medicine": ["💊 Liver-Tonic", "🧪 Liv-52"], "diet": ["🥭 Papaya", "🍵 Green Tea"], "duration": "📅 Monthly 🧪"},
    "Skin Infection": {"icon": "🧴", "medicine": ["🧴 Antifungal", "💊 Itraconazole"], "diet": ["🌵 Aloe Vera", "🥥 Coconut Oil"], "duration": "⏳ 2 Weeks ✨"},
    "Acidity": {"icon": "🔥", "medicine": ["💊 Omeprazole", "🧪 Digene"], "diet": ["🥛 Cold Milk", "🥥 Coconut Water"], "duration": "⏳ 3 Days 🧊"},
    "Ulcer": {"icon": "🩹", "medicine": ["💊 Pantoprazole"], "diet": ["🥣 Soft Food", "🍌 Banana"], "duration": "⏳ 2 Weeks 🥣"},
    "Diarrhea": {"icon": "🚽", "medicine": ["🥤 ORS", "💊 Loperamide"], "diet": ["🍌 Banana", "🍚 Rice", "🥣 Curd"], "duration": "⏳ 2 Days 🥤"},
    "Constipation": {"icon": "🧱", "medicine": ["💊 Laxatives", "🧪 Isabgol"], "diet": ["🥭 Papaya", "🌾 Fiber Food"], "duration": "⏳ 5 Days 🥭"},
    "Depression": {"icon": "😔", "medicine": ["💊 SSRIs", "🧪 Therapy"], "diet": ["🍫 Dark Chocolate", "🍌 Banana"], "duration": "📅 Long-term 🌱"},
    "Anxiety": {"icon": "😟", "medicine": ["💊 Alprazolam"], "diet": ["🍵 Herbal Tea", "🫐 Berries"], "duration": "⏳ As Needed 🧘‍♀️"},
    "Insomnia": {"icon": "😴", "medicine": ["💊 Melatonin"], "diet": ["🥛 Warm Milk", "🍒 Cherry Juice"], "duration": "📅 Nightly 🌙"},
    "Flu": {"icon": "🤒", "medicine": ["💊 Oseltamivir"], "diet": ["🍲 Soup", "🥤 Fluids"], "duration": "⏳ 1 Week 🛌"},
    "COVID": {"icon": "🦠", "medicine": ["💊 Vit-C", "💊 Zinc"], "diet": ["🍋 Citrus Fruits", "🍲 Kadha"], "duration": "⏳ 2 Weeks 😷"},
    "Malaria": {"icon": "🦟", "medicine": ["💊 Chloroquine"], "diet": ["🥣 Light Food", "🍎 Fruits"], "duration": "⏳ 1 Week 🦟"},
    "Dengue": {"icon": "🩸", "medicine": ["💊 Paracetamol"], "diet": ["🌿 Papaya Leaf", "🥥 Coconut Water"], "duration": "⏳ 10 Days 🦟"},
    "Typhoid": {"icon": "💧", "medicine": ["💊 Antibiotics"], "diet": ["🥣 Mushy Food", "🍌 Banana"], "duration": "⏳ 2 Weeks 💧"},
    "Jaundice": {"icon": "🟡", "medicine": ["💊 Supportive"], "diet": ["🎋 Sugarcane", "🥣 Porridge"], "duration": "⏳ 3 Weeks 🟡"},
    "Eye Infection": {"icon": "👁️", "medicine": ["👁️ Drops", "💊 Antibiotics"], "diet": ["🥕 Carrots", "🥚 Eggs"], "duration": "⏳ 5 Days 👁️"},
    "Ear Pain": {"icon": "👂", "medicine": ["👂 Drops"], "diet": ["🥣 Warm Food"], "duration": "⏳ 5 Days 👂"},
    "Tooth Pain": {"icon": "🦷", "medicine": ["💊 Ibuprofen", "🧴 Gel"], "diet": ["🪔 Clove Oil", "🍦 Soft Ice-cream"], "duration": "⏳ 3 Days 🦷"},
    "Hair Fall": {"icon": "💇", "medicine": ["💊 Biotin", "🧪 Minoxidil"], "diet": ["🥚 Protein", "🥜 Nuts"], "duration": "📅 3 Months 💇‍♀️"},
    "PCOS": {"icon": "🚺", "medicine": ["💊 Metformin"], "diet": ["🥗 Low Carb", "🍵 Spearmint Tea"], "duration": "📅 6 Months+ 🚺"},
    "Pregnancy": {"icon": "🤰", "medicine": ["💊 Folic Acid", "💊 Iron"], "diet": ["🥜 Dry Fruits", "🥛 Milk"], "duration": "📅 9 Months 🍼"},
    "Vomiting": {"icon": "🤮", "medicine": ["💊 Ondansetron"], "diet": ["🥤 ORS", "🍋 Lemonade"], "duration": "⏳ 2 Days 🥤"},
    "Dehydration": {"icon": "🌵", "medicine": ["🥤 Electrolytes"], "diet": ["🥥 Water", "🍉 Watermelon"], "duration": "⏳ 1 Day 💧"},
    "Sunburn": {"icon": "☀️", "medicine": ["🧴 Aloe Gel"], "diet": ["🍉 Watermelon", "🥒 Cucumber"], "duration": "⏳ 5 Days 🧴"},
    "Cholesterol": {"icon": "🍔", "medicine": ["💊 Statins"], "diet": ["🥣 Oats", "🫘 Beans", "🐟 Fish"], "duration": "📅 Daily 🥗"},
    "Cancer": {"icon": "🎗️", "medicine": ["💉 Chemo", "💊 Targeted"], "diet": ["🥩 High Protein", "🥗 Veggies"], "duration": "📅 Ongoing 🎗️"},
    "Tuberculosis": {"icon": "😷", "medicine": ["💊 ATT Course"], "diet": ["🥚 Eggs", "🥛 High Protein"], "duration": "📅 6-9 Months 😷"},
    "Hepatitis": {"icon": "🧬", "medicine": ["💊 Antiviral"], "diet": ["🎋 Sugarcane Juice", "🥣 Rice"], "duration": "📅 Monthly 🧪"},
    "Parkinson": {"icon": "🧠", "medicine": ["💊 Levodopa"], "diet": ["🌾 Fiber", "🫐 Berries"], "duration": "📅 Daily 🧠"},
    "Alzheimer": {"icon": "💭", "medicine": ["💊 Donepezil"], "diet": ["🫘 Walnuts", "🫐 Berries"], "duration": "📅 Daily 💭"},
    "Stroke": {"icon": "🧠", "medicine": ["💊 Aspirin", "🧪 Statins"], "diet": ["🥗 Med Diet", "🐟 Fish"], "duration": "📅 Daily 🧠"},
    "Fracture": {"icon": "🦵", "medicine": ["💊 Calcium", "💊 Vit-D"], "diet": ["🥛 Milk", "🥚 Eggs", "🧀 Cheese"], "duration": "⏳ 2 Months 🦵"},
    "Burn": {"icon": "🔥", "medicine": ["🧴 Silver Cream"], "diet": ["🍗 Protein", "🥚 Eggs"], "duration": "⏳ 2 Weeks 🔥"},
    "UTI": {"icon": "🚽", "medicine": ["💊 Antibiotic"], "diet": ["🥤 Cranberry Juice", "💧 Water"], "duration": "⏳ 1 Week 🚽"},
    "Acne": {"icon": "🧼", "medicine": ["🧴 Retinoids", "💊 Zinc"], "diet": ["🍏 Low Sugar", "🍵 Green Tea"], "duration": "⏳ 3 Months ✨"},
  };

  void searchDisease() {
    String input = searchCtrl.text.trim().toLowerCase();
    String? foundKey;
    try {
      foundKey = diseaseData.keys.firstWhere((key) => key.toLowerCase() == input);
    } catch (e) {
      foundKey = null;
    }

    if (foundKey != null) {
      setState(() {
        result = diseaseData[foundKey];
      });
      addHealthRecord("Disease Search", "Searched for $foundKey", Icons.search, Colors.purple);
    } else {
      setState(() => result = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Disease not found ❌")),
      );
    }
  }

  Future<void> pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => selectedTime = t);
  }

  void startAlarm() {
    if (selectedTime == null || result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pehle time select karo, bhai! ⏰"), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Medicine Reminder Set for ${selectedTime!.format(context)} 💊"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = TimeOfDay.now();
      if (now.hour == selectedTime!.hour && now.minute == selectedTime!.minute) {
        _audioPlayer.play(AssetSource('audio/samsung_galaxy_s22.mp3'));
        timer.cancel();
        _showMedicineAlarmOverlay();
      }
    });
  }

  void _showMedicineAlarmOverlay() {
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
              Text(result?['icon'] ?? "💊", style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              const Text(
                "Dawa ka Waqt! 💊",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Bhai, aapko apni '${result?['medicine']?.join(', ')}' leni hai. Health first!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("OKAY, TAKEN! ✅", style: TextStyle(color: Colors.white)),
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
    setState(() => selectedTime = null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alarm Stopped ❌")));
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Disease & Medicine", style: TextStyle(fontWeight: FontWeight.bold)),
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
                ? [const Color(0xFF071927), const Color(0xFF0F172A)]
                : [const Color(0xFFF0FDFA), const Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            children: [
              // 🔍 SEARCH BAR
              TextField(
                controller: searchCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Search Disease (e.g. Fever, Cold)",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
                onSubmitted: (_) => searchDisease(),
              ),
              const SizedBox(height: 25),

              if (result != null) ...[
                // 📄 RESULT CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(result!['icon'], style: const TextStyle(fontSize: 40)),
                          const SizedBox(width: 15),
                          const Text("Medical Advice", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 30),
                      _infoRow(Icons.medication, "Medicine", result!['medicine'].join(', '), isDark),
                      _infoRow(Icons.restaurant, "Diet", result!['diet'].join(', '), isDark),
                      _infoRow(Icons.calendar_today, "Duration", result!['duration'], isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ⏰ REMINDER SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text("Set Medicine Reminder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedTime == null ? "Select Time" : selectedTime!.format(context),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                              const Icon(Icons.access_time, color: Colors.teal),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: startAlarm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("START ALARM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("STOP"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 50),
                Icon(Icons.search_off, size: 80, color: Colors.teal.withValues(alpha: 0.2)),
                const SizedBox(height: 10),
                const Text("Bhai, kuch search toh karo! 🔍", style: TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}