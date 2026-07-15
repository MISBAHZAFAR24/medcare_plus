import 'package:flutter/material.dart';
import 'dart:ui';
import 'gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    String userMsg = controller.text.trim();
    if (userMsg.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMsg});
      isLoading = true;
    });

    controller.clear();
    _scrollToBottom();

    try {
      String reply = await GeminiService.askAI(userMsg);
      setState(() {
        messages.add({"role": "ai", "text": reply});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "ai", "text": "Sorry, I'm having trouble connecting. Please try again later. 🛑"});
        isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutExpo,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("MedCare AI ✨", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.teal.withValues(alpha: 0.05)),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFF0FDFA), Colors.white, const Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == messages.length) {
                    return _buildLoadingBubble(isDark);
                  }
                  final msg = messages[i];
                  return _buildChatBubble(msg, isDark, i);
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildInputArea(isDark),
    );
  }

  Widget _buildChatBubble(Map<String, String> msg, bool isDark, int index) {
    bool isUser = msg["role"] == "user";
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(colors: [Colors.teal, Color(0xFF14B8A6)])
                : null,
            color: isUser ? null : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
              bottomLeft: Radius.circular(isUser ? 24 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 24),
            ),
            boxShadow: [
              BoxShadow(
                color: isUser ? Colors.teal.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: isUser ? null : Border.all(color: Colors.teal.withValues(alpha: 0.1), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text("MedCare Assistant", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
              Text(
                msg["text"]!,
                style: TextStyle(
                  color: isUser ? Colors.white : (isDark ? const Color(0xFFEEEEEE) : Colors.black87),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Ask anything about health...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.teal, Color(0xFF14B8A6)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
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

