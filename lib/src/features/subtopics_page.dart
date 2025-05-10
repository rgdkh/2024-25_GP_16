import 'package:flutter/material.dart';
import 'ChatbotPage.dart';


class SubTopicsPage extends StatelessWidget {
  final String title;
  final List<String> subtopics;

  const SubTopicsPage({Key? key, required this.title, required this.subtopics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8), // ✅ Background color updated
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: ListView.builder(
          itemCount: subtopics.length,
          itemBuilder: (context, index) {
            final subtopic = subtopics[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatbotPage(
                      topicTitle: subtopic,
                      quickPrompts: _generatePrompts(subtopic),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2A3A26),
                    child: const Icon(Icons.terrain, color: Colors.white),
                  ),
                  title: Text(
                    subtopic,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A3A26),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF2A3A26)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> _generatePrompts(String subtopic) {
    return [
      "Tell me about $subtopic.",
      "Tips regarding $subtopic.",
      "Common mistakes in $subtopic.",
      "How to master $subtopic?",
      "Best practices for $subtopic."
    ];
  }
}
