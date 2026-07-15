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
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui';

List<Map<String, dynamic>> healthRecords = [];
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

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
final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

Future initNotification() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await notifications.initialize(settings);
  final androidPlugin = notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
  tz.initializeTimeZones();
}

Future scheduleNotification(int id, String title, String body, TimeOfDay time) async {
  final now = DateTime.now();
  final schedule = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  await notifications.zonedSchedule(
    id, title, body,
    tz.TZDateTime.from(schedule.isBefore(now) ? schedule.add(const Duration(days: 1)) : schedule, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'medcare_channel_2', 'MedCare Alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('samsung_galaxy_s22'),
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MedCare Plus',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
              return snapshot.hasData ? Home(snapshot.data?.displayName ?? "User") : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

// ================= LOGIN SCREEN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;

  void loginAction() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      _showMsg("Please fill all fields", Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home(userCredential.user?.displayName ?? "User")));
    } catch (e) {
      _showMsg("Login Fail! Check details.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF0FDFA), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Blobs
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withValues(alpha: 0.03),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(scale: value, child: child),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.health_and_safety_rounded, size: 80, color: Colors.teal),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "MEDCARE+",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal,
                          letterSpacing: 4,
                        ),
                      ),
                      const Text(
                        "Your Personal Health Companion",
                        style: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1),
                      ),
                      const SizedBox(height: 60),

                      // Glassmorphism Input Fields
                      _buildTextField(emailCtrl, "Email Address", Icons.alternate_email_rounded, false, isDark),
                      const SizedBox(height: 20),
                      _buildTextField(passCtrl, "Password", Icons.lock_open_rounded, true, isDark),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Animated Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : loginAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.teal.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Signup())),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, bool obscure, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

// ================= SIGNUP SCREEN =================
class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;

  void signupAction() async {
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      _showMsg("Please fill all fields", Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      await userCredential.user?.updateDisplayName(nameCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home(nameCtrl.text.trim())));
    } catch (e) {
      _showMsg(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF0FDFA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Start your journey to better health",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 50),
                  _buildTextField(nameCtrl, "Full Name", Icons.person_outline_rounded, false, isDark),
                  const SizedBox(height: 20),
                  _buildTextField(emailCtrl, "Email Address", Icons.alternate_email_rounded, false, isDark),
                  const SizedBox(height: 20),
                  _buildTextField(passCtrl, "Password", Icons.lock_open_rounded, true, isDark),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : signupAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.teal.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "REGISTER",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, bool obscure, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

// ================= DASHBOARD BODY =================
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏆 Premium Health Score Card
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.teal, Color(0xFF0D9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Stack(
              children: [
                Positioned(right: -20, bottom: -20, child: Icon(Icons.favorite, size: 150, color: Colors.white.withValues(alpha: 0.1))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Daily Health Score", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 5),
                    const Text("85/100", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber, size: 20),
                        const SizedBox(width: 5),
                        Text("You are doing great today!", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Our Services", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blueGrey[900])),
              TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.teal))),
            ],
          ),
          const SizedBox(height: 10),

          // 🧊 Advanced Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
            children: [
              _glassTile(context, "AI Consult", const ChatScreen(), Icons.auto_awesome, Colors.orange, "Ask MedBot", isDark),
              _glassTile(context, "Doctors", const DoctorScreen(), Icons.medical_services, Colors.indigo, "Top Experts", isDark),
              _glassTile(context, "Water", const Water(), Icons.water_drop, Colors.blue, "Hydration", isDark),
              _glassTile(context, "Vitals", const Health(), Icons.favorite, Colors.red, "Heart & BMI", isDark),
              _glassTile(context, "Disease", const Disease(), Icons.medication_liquid, Colors.purple, "Meds & Guide", isDark),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _glassTile(BuildContext context, String title, Widget screen, IconData icon, Color color, String sub, bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
            border: Border.all(color: isDark ? Colors.white10 : Colors.teal.withValues(alpha: 0.05), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PROFILE SCREEN =================
class ProfileScreen extends StatelessWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Stack(
              children: [
                CircleAvatar(radius: 65, backgroundColor: Colors.teal.withValues(alpha: 0.2), child: const Icon(Icons.person, size: 80, color: Colors.teal)),
                Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 18))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(userName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Text("Silver Member • Since 2024", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          _profileItem(context, Icons.history, "Medical History", "Check past appointments", const MedicalHistory(), isDark),
          _profileItem(context, Icons.notifications_active_outlined, "Notifications", "Manage your alerts", null, isDark),
          _profileItem(context, Icons.security, "Privacy & Safety", "Account data settings", null, isDark),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), foregroundColor: Colors.redAccent, elevation: 0, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _profileItem(BuildContext context, IconData icon, String title, String sub, Widget? page, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () { if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page)); },
    );
  }
}

// ================= MEDICAL HISTORY =================
class MedicalHistory extends StatelessWidget {
  const MedicalHistory({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("History"), backgroundColor: Colors.transparent, foregroundColor: Colors.teal),
      body: healthRecords.isEmpty
          ? const Center(child: Text("No records found yet!"))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: healthRecords.length,
              itemBuilder: (context, index) {
                final item = healthRecords[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.teal.withValues(alpha: 0.1))),
                  child: Row(
                    children: [
                      Icon(item['icon'], color: item['color']),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)), Text(item['detail'], style: const TextStyle(fontSize: 12, color: Colors.grey))])),
                      Text(item['time'], style: const TextStyle(fontSize: 11, color: Colors.teal)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ================= HOME SCREEN =================
class Home extends StatefulWidget {
  final String name;
  const Home(this.name, {super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late final List<Widget> _pages = [const DashboardBody(), const ChatScreen(), const DoctorScreen(), ProfileScreen(userName: widget.name)];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.transparent, centerTitle: false,
        title: Text("Hello, ${widget.name} 👋", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.teal)),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) => IconButton(icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode, color: Colors.teal), onPressed: () => themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, border: Border(top: BorderSide(color: Colors.teal.withValues(alpha: 0.1)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBtn(Icons.dashboard_rounded, 0),
            _navBtn(Icons.auto_awesome_rounded, 1),
            _navBtn(Icons.medical_services_rounded, 2),
            _navBtn(Icons.person_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, int index) {
    bool sel = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: sel ? Colors.teal : Colors.transparent, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: sel ? Colors.white : Colors.teal.withValues(alpha: 0.5), size: 26),
      ),
    );
  }
}
