import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: AppTypography.heading3),
        centerTitle: false,
      ),
      body: const Center(child: Text('Privacy Policy will be displayed here.')),
    );
  }
}
