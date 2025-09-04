import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';

class EmergencySection extends StatelessWidget {
  final VoidCallback? onContactTap;

  const EmergencySection({super.key, this.onContactTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      color: AppColors.cardRed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you in an emergency?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Do you need help?',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onContactTap,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: const Text(
                'Contact Emergency Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
