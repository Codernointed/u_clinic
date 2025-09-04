import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ', style: AppTypography.heading3),
        centerTitle: false, 
      ),
      body: const Center(child: Text('FAQ screen will be implemented here.')),
    );
  }
}
