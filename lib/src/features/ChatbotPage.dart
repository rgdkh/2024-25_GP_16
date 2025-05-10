import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_bubble.dart';
class ChatbotPage extends StatefulWidget {
  final String topicTitle; // 🆕 Added
  final List<String> quickPrompts; // 🆕 Added

  const ChatbotPage({Key? key, required this.topicTitle, required this.quickPrompts}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  static const String apiKey = "AIzaSyBrPRLZJQleQJWTJM-fc6HVt6-3fZP6EXc"; // your api key
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

  void _sendMessage(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({'text': text, 'isUser': true});
        _isTyping = true;
      });

      _controller.clear();

      String responseText = await _getGeminiResponse(text);

      if (!mounted) return;

      setState(() {
        _messages.add({'text': responseText, 'isUser': false});
        _isTyping = false;
      });
    }
  }

  Future<String> _getGeminiResponse(String userMessage) async {
    try {
      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userMessage}
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? "I couldn't understand that.";
      } else {
        print("API Error: ${response.body}");
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      print("Network Error: $e");
      return "Error: ${e.toString()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topicTitle, // 🆕 use the topic title dynamically
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFEAE7D8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  return ChatBubble(
                    text: message['text'],
                    isUser: message['isUser'],
                  );
                },
              ),
            ),
            _buildQuickPrompts(), // ✅ Quick prompts based on the selected topic
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.center,
        children: widget.quickPrompts.map((prompt) {
          return ElevatedButton(
            onPressed: () => _sendMessage(prompt),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3A26),
              elevation: 4,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              prompt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Ask Gemini...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_controller.text),
            color: const Color(0xFF2A3A26),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[400],
          child: const Icon(Icons.android, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        const Text(
          'Gemini is typing...',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
