import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_chatscreen.dart';
import 'doctor_screen.dart';
import 'health.dart';
import 'Water.dart';
import 'Disease.dart';

List<Map<String, dynamic>> healthRecords = [];


void addHealthRecord(String title, String detail, IconData icon, Color color) {
  healthRecords.insert(0, {
    'title': title,
    'detail': detail,
    'icon': icon,
    'color': color,
    'time': "${DateTime.now().hour}:${DateTime.now().minute}",
    'date': "Today",
  });
}

// ================= NOTIFICATION =================
final FlutterLocalNotificationsPlugin notifications =
FlutterLocalNotificationsPlugin();

Future initNotification() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);

  await notifications.initialize(settings);

  final androidPlugin = notifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.requestNotificationsPermission();

  tz.initializeTimeZones();

}

Future scheduleNotification(
    int id, String title, String body, TimeOfDay time) async {

  final now = DateTime.now();

  final schedule =
  DateTime(now.year, now.month, now.day, time.hour, time.minute);

  await notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(
      schedule.isBefore(now)
          ? schedule.add(const Duration(days: 1))
          : schedule,
      tz.local,
    ),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'medcare_channel_2',
        'MedCare Alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('samsung_galaxy_s22'),
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

    // ✅ REQUIRED FIX
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,

    matchDateTimeComponents: DateTimeComponents.time,
  );
}

// ================= MAIN =================
void main() async {
  // 1. Engine aur Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Notification setup
  await initNotification();

  // 3. App ko start karna
  runApp(const MyApp());
}

// ================= GLOBAL =================
String? name;
String? email;
String? pass;

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedCare Plus',

      // ✅ PREMIUM THEME
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light Gray background

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),


      home:  LoginScreen(),
    );
  }
}

// =================  UI CARD =================
Widget customCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),

      // ✅ PREMIUM SHADOW EFFECT
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          spreadRadius: 2,
          offset: Offset(0, 4), // Shadow thodi niche dikhegi (Realistic look)
        )
      ],
    ),
    child: child,
  );
}
// ================= LOGIN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // 🔹 Firebase Login Logic
  void loginAction() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      // Success: Next Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home("welcome to medcare+")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Fail: Check Email/Pass"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Icons
          Positioned(top: 80, left: 30, child: Icon(Icons.add, size: 120, color: Colors.teal.withValues(alpha: 0.1))),
          Positioned(bottom: 80, right: 20, child: Icon(Icons.local_hospital, size: 150, color: Colors.teal.withValues(alpha: 0.1))),

          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(25),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("MEDCARE+", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 25),
                    TextField(controller: emailCtrl, decoration: inputStyle("Email")),
                    const SizedBox(height: 15),
                    TextField(controller: passCtrl, obscureText: true, decoration: inputStyle("Password")),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loginAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Signup())),
                      child: const Text("Create New Account", style: TextStyle(color: Colors.teal)),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
// ================= SIGNUP =================
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // 1️⃣ Naya Name Controller add kiya
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // 🔹 Firebase Signup Logic
  void signupAction() async {
    // Basic validation check
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bhai, saari details bhado! ✍️"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created! 🎉"), backgroundColor: Colors.teal),
      );

      // 2️⃣ Signup ke baad Home par naam ke saath bhej rahe hain
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(nameCtrl.text.trim())),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.teal),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_alt_1, size: 50, color: Colors.teal),
                const SizedBox(height: 15),
                const Text("SIGN UP", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 30),

                // 3️⃣ NAAM WALA TEXTFIELD
                TextField(controller: nameCtrl, decoration: inputStyle("Full Name")),
                const SizedBox(height: 15),

                TextField(controller: emailCtrl, decoration: inputStyle("Email Address")),
                const SizedBox(height: 15),

                TextField(controller: passCtrl, obscureText: true, decoration: inputStyle("Create Password")),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signupAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ================= 🏠 DASHBOARD BODY =================
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 Progress Card
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Color(0xFF1DE9B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Health Score ⚡",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 15),
                const LinearProgressIndicator(
                  value: 0.75,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  minHeight: 8,
                ),
                const SizedBox(height: 15),
                const Text("Bhai, aap 75% fit hain! 🔥",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("Main Menu 📋",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 15),

          // 🧊 Working Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 1.1,
            children: [
              // 1. Water Tracker
              _menuTile(context, "Water", const Water(), Icons.water_drop, Colors.blue, "Stay Hydrated 💧", () {
                addHealthRecord("Water Intake", "Drank 1 Glass (250ml)", Icons.water_drop, Colors.blue);
              }),

              // 2. Doctor Search
              _menuTile(context, "Doctors", const DoctorScreen(), Icons.medical_services_rounded, Colors.purple, "Find Specialists 👨‍⚕️", () {
                addHealthRecord("Doctor Search", "Searched for nearby Specialists", Icons.medical_services_rounded, Colors.purple);
              }),

              // 3. Diseases Check
              _menuTile(context, "Diseases", const Disease(), Icons.coronavirus, Colors.green, "Be Safe 🦠", () {
                addHealthRecord("Health Research", "Checked Symptoms for Flu/Fever", Icons.coronavirus, Colors.green);
              }),
              // 4. chatbot check
              _menuTile(context, "AI Chat", const ChatScreen(), Icons.smart_toy_rounded, Colors.orange, "Health Assistant 🤖", () {
                addHealthRecord("Chat Started", "Opened AI Health Assistant", Icons.smart_toy_rounded, Colors.orange);
              }),

              // 5. Vitals Check
              _menuTile(context, "Vitals", const Health(), Icons.favorite, Colors.red, "Check Stats ❤️", () {
                addHealthRecord("Vitals Checkup", "Heart Rate & SpO2 Checked", Icons.favorite, Colors.red);
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Added 'VoidCallback action' parameter to handle history recording
  Widget _menuTile(BuildContext context, String title, Widget screen, IconData icon, Color color, String sub, VoidCallback action) {
    return InkWell(
      onTap: () {
        action(); // Pehle history record karega
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen)); // Phir screen par jayega
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// ================= 👤 PROFILE SCREEN =================
class ProfileScreen extends StatelessWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // --- Profile Header ---
          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const Text("Medcare+ Premium Member ✨", style: TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 30),

          // --- Action Tiles ---

          // 1. Medical History (Ab ye working hai!)
          _profileTile(
            context,
            Icons.history_rounded,
            "Medical History",
            "Check your past records & reports",
            const MedicalHistory(), // Humne jo naya page banaya tha
          ),

          // 2. Settings
          _profileTile(
            context,
            Icons.settings_rounded,
            "Settings",
            "App notifications & account security",
            const Center(child: Text("Settings Page Coming Soon ⚙️")),
          ),

          // 3. Help & Support (AI Chat par le jayega)
          _profileTile(
            context,
            Icons.help_center_rounded,
            "Support",
            "Talk to our AI Health Assistant",
            const ChatScreen(),
          ),

          const SizedBox(height: 30),

          // --- Log out Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ElevatedButton.icon(
              onPressed: () {
                // Logout logic: Navigator.pop(context) ya Login par bhej do
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Helper Widget for Tiles (With Navigation) ---
  Widget _profileTile(BuildContext context, IconData icon, String title, String sub, Widget targetPage) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.teal, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: () {
        // Bhai, yahan se navigation handle ho rahi hai
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
    );
  }
}
// =================medical history =================
class MedicalHistory extends StatelessWidget {
  const MedicalHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Medical Records 📜", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: healthRecords.isEmpty
          ? const Center(child: Text("Bhai, abhi koi record nahi mila! 📂"))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: healthRecords.length,
        itemBuilder: (context, index) {
          final item = healthRecords[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
                  child: Icon(item['icon'], color: item['color']),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(item['detail'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(item['time'], style: const TextStyle(fontSize: 10, color: Colors.teal)),
              ],
            ),
          );
        },
      ),
    );
  }
}
// ================= 📱 HOME STATE =================
class Home extends StatefulWidget {
  final String name;
  const Home(this.name, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  // Screens List (Sequence matching navigation bar)
  // Note: Yahan 'late' keyword zaroori hai widget.name use karne ke liye
  late final List<Widget> _pages = [
    const DashboardBody(),                 // Index 0
    const ChatScreen(),                    // Index 1
    const DoctorScreen(),                  // Index 2
    ProfileScreen(userName: widget.name),  // Index 3 (Passed dynamic name)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Hey, ${widget.name} ✨",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.teal),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.teal)
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.grid_view_rounded, 0),
            navItem(Icons.chat_bubble_rounded, 1),
            navItem(Icons.medical_services_rounded, 2),
            navItem(Icons.person_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent.withValues(alpha: 0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
            icon,
            color: isSelected ? Colors.tealAccent : Colors.white60,
            size: 28
        ),
      ),
    );
  }
}
