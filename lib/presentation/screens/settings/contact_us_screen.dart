import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: AppTypography.heading3),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('Contact Us screen will be implemented here.'),
      ),
    );
  }
}
