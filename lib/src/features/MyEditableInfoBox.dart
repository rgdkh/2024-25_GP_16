import 'package:flutter/material.dart';

class MyEditableInfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const MyEditableInfoBox({
    super.key,
    required this.icon,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 30, color: const Color(0xFF2A3A26)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3A26),
                  ),
                ),
                Text(text),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2A3A26)),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}