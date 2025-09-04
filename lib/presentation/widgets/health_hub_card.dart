import 'package:flutter/material.dart';

class HealthHubCard extends StatelessWidget {
  final String title;
  final String category;
  final String imagePath;

  const HealthHubCard({
    super.key,
    required this.title,
    required this.category,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset(imagePath, height: 100, width: 200, fit: BoxFit.cover),
          Text(title),
          Text(category),
        ],
      ),
    );
  }
}
