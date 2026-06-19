import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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
    if (selectedTime == null || result == null) return;

    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Alarm Set for ${selectedTime!.format(context)}")),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = TimeOfDay.now();
      if (now.hour == selectedTime!.hour && now.minute == selectedTime!.minute) {
        _audioPlayer.play(AssetSource('audio/samsung_galaxy_s22.mp3'));
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("💊 Medicine Time!")),
        );
      }
    });
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
    return Scaffold(
      appBar: AppBar(title: const Text("Health Tracker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search Disease",
                suffixIcon: IconButton(onPressed: searchDisease, icon: const Icon(Icons.search)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (result != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("💊 Medicine: ${result!['medicine'].join(', ')}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text("🍎 Diet: ${result!['diet'].join(', ')}"),
                      Text("⏳ Duration: ${result!['duration']}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: pickTime, child: const Text("1. Pick Time")),
              if (selectedTime != null) ...[
                Text("Selected: ${selectedTime!.format(context)}"),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: startAlarm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("2. Start Alarm")),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: stopAlarm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text("Stop Alarm")),
              ]
            ]
          ],
        ),
      ),
    );
  }
}
