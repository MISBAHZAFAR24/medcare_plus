import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? "";

  static Future<String> askAI(String message) async {
    if (apiKey.isEmpty) return "API Key not found. Please check your .env file.";

    try {
      // Using stable 1.5-flash for better speed and reliability
      final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "System Instruction: You are MedCare AI, a professional and empathetic medical assistant. "
                          "Provide helpful, concise, and accurate health information. "
                          "Always include a disclaimer that you are an AI and the user should consult a real doctor for serious issues. "
                          "Format your answers with bullet points where necessary for better readability.\n\n"
                          "User Question: $message"
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply = data["candidates"][0]["content"]["parts"][0]["text"];
        return reply.trim();
      } else {
        print("GEMINI ERROR: ${response.body}");
        return "Bhai, server busy hai. Thodi der baad try karein! 🛑";
      }
    } catch (e) {
      return "Exception occurred: $e";
    }
  }
}
