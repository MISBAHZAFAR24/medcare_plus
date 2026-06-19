import 'package:flutter/material.dart';
import 'main.dart';
import 'Appointment_screen.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📝 COMPLETE LIST OF 50 DOCTORS WITH EMOJIS & DATA
    final List<Map<String, String>> docs = [
      {"name": "Dr. Aamir Khan", "spec": "Cardiologist", "fees": "₹800", "emoji": "🫀"},
      {"name": "Dr. Neha Sharma", "spec": "Dermatologist", "fees": "₹600", "emoji": "🧴"},
      {"name": "Dr. Rahul Verma", "spec": "Neurologist", "fees": "₹900", "emoji": "🧠"},
      {"name": "Dr. Priya Singh", "spec": "Gynecologist", "fees": "₹700", "emoji": "🤰"},
      {"name": "Dr. Arjun Mehta", "spec": "Orthopedic", "fees": "₹750", "emoji": "🦴"},
      {"name": "Dr. Sana Ali", "spec": "Pediatrician", "fees": "₹500", "emoji": "👶"},
      {"name": "Dr. Rohit Gupta", "spec": "General Physician", "fees": "₹400", "emoji": "👨‍⚕️"},
      {"name": "Dr. Meera Kapoor", "spec": "Psychiatrist", "fees": "₹850", "emoji": "💭"},
      {"name": "Dr. Karan Malhotra", "spec": "ENT Specialist", "fees": "₹650", "emoji": "👂"},
      {"name": "Dr. Anjali Desai", "spec": "Dentist", "fees": "₹300", "emoji": "🦷"},

      {"name": "Dr. Vivek Sharma", "spec": "Cardiologist", "fees": "₹850", "emoji": "🫀"},
      {"name": "Dr. Pooja Verma", "spec": "Dermatologist", "fees": "₹550", "emoji": "🧴"},
      {"name": "Dr. Aman Khan", "spec": "Neurologist", "fees": "₹920", "emoji": "🧠"},
      {"name": "Dr. Kavita Singh", "spec": "Gynecologist", "fees": "₹720", "emoji": "🤰"},
      {"name": "Dr. Rakesh Mehta", "spec": "Orthopedic", "fees": "₹780", "emoji": "🦴"},
      {"name": "Dr. Iqra Sheikh", "spec": "Pediatrician", "fees": "₹520", "emoji": "👶"},
      {"name": "Dr. Manish Yadav", "spec": "General Physician", "fees": "₹450", "emoji": "👨‍⚕️"},
      {"name": "Dr. Nidhi Jain", "spec": "Psychiatrist", "fees": "₹880", "emoji": "💭"},
      {"name": "Dr. Saurabh Gupta", "spec": "ENT Specialist", "fees": "₹670", "emoji": "👂"},
      {"name": "Dr. Ritu Shah", "spec": "Dentist", "fees": "₹350", "emoji": "🦷"},

      {"name": "Dr. Ajay Kumar", "spec": "Cardiologist", "fees": "₹820", "emoji": "🫀"},
      {"name": "Dr. Sneha Roy", "spec": "Dermatologist", "fees": "₹580", "emoji": "🧴"},
      {"name": "Dr. Arif Khan", "spec": "Neurologist", "fees": "₹940", "emoji": "🧠"},
      {"name": "Dr. Deepa Singh", "spec": "Gynecologist", "fees": "₹710", "emoji": "🤰"},
      {"name": "Dr. Rajat Mehta", "spec": "Orthopedic", "fees": "₹760", "emoji": "🦴"},
      {"name": "Dr. Sana Parveen", "spec": "Pediatrician", "fees": "₹530", "emoji": "👶"},
      {"name": "Dr. Anil Gupta", "spec": "General Physician", "fees": "₹420", "emoji": "👨‍⚕️"},
      {"name": "Dr. Mehul Shah", "spec": "Psychiatrist", "fees": "₹860", "emoji": "💭"},
      {"name": "Dr. Tarun Verma", "spec": "ENT Specialist", "fees": "₹690", "emoji": "👂"},
      {"name": "Dr. Komal Patel", "spec": "Dentist", "fees": "₹320", "emoji": "🦷"},

      {"name": "Dr. Sandeep Kumar", "spec": "Cardiologist", "fees": "₹810", "emoji": "🫀"},
      {"name": "Dr. Shalini Gupta", "spec": "Dermatologist", "fees": "₹570", "emoji": "🧴"},
      {"name": "Dr. Faisal Khan", "spec": "Neurologist", "fees": "₹910", "emoji": "🧠"},
      {"name": "Dr. Priti Singh", "spec": "Gynecologist", "fees": "₹730", "emoji": "🤰"},
      {"name": "Dr. Mohit Mehta", "spec": "Orthopedic", "fees": "₹790", "emoji": "🦴"},
      {"name": "Dr. Ayesha Ali", "spec": "Pediatrician", "fees": "₹510", "emoji": "👶"},
      {"name": "Dr. Ravi Sharma", "spec": "General Physician", "fees": "₹430", "emoji": "👨‍⚕️"},
      {"name": "Dr. Neelam Jain", "spec": "Psychiatrist", "fees": "₹870", "emoji": "💭"},
      {"name": "Dr. Ashish Gupta", "spec": "ENT Specialist", "fees": "₹660", "emoji": "👂"},
      {"name": "Dr. Pooja Shah", "spec": "Dentist", "fees": "₹340", "emoji": "🦷"},

      // 🌿 AYURVEDIC SPECIALISTS
      {"name": "Dr. Ravi Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹300", "emoji": "🌿"},
      {"name": "Dr. Suman Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹350", "emoji": "🍃"},
      {"name": "Dr. Harish Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹320", "emoji": "🌱"},
      {"name": "Dr. Kavya Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹330", "emoji": "🪴"},
      {"name": "Dr. Deepak Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹310", "emoji": "🍀"},
      {"name": "Dr. Nisha Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹340", "emoji": "🌿"},
      {"name": "Dr. Ankit Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹360", "emoji": "🍃"},
      {"name": "Dr. Meena Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹300", "emoji": "🌱"},
      {"name": "Dr. Raj Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹370", "emoji": "🍀"},
      {"name": "Dr. Seema Ayurveda", "spec": "Ayurvedic Specialist", "fees": "₹330", "emoji": "🪴"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Available Doctors 👨‍⚕️", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        itemCount: docs.length,
        itemBuilder: (context, i) {
          final d = docs[i];

          // Custom color based on Specialization
          Color themeColor = d["spec"]!.contains("Ayurvedic") ? Colors.green : Colors.teal;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () {
                  addHealthRecord(
                      "Doctor Consultation",
                      "Visited ${d['name']} (${d['spec']})", // Ab naam dikhega!
                      Icons.medical_services_rounded,
                      themeColor
                  );
                  // Navigator logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentScreen(doc: d), // Doctor ka data bhej rahe hain
                    ),
                  );
                },
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Text(d["emoji"]!, style: const TextStyle(fontSize: 32)),
                ),
                title: Text(
                  d["name"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(d["spec"]!, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Consultancy: ${d["fees"]}",
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: themeColor.withValues(alpha: 0.5)),
              ),
            ),
          );
        },
      ),
    );
  }
}
