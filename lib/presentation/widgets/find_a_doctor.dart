import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/widgets/buttons/more_button.dart';

class FindADoctor extends StatelessWidget {
  final VoidCallback? onTap;

  const FindADoctor({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 249,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find a Doctor or a Hospital',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.5, // 24px line-height
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM - 3),
                  const Text(
                    'Are you in an emergency or just need to find a doctor or hospital for your health needs?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.33, // 16px line-height
                      color: Colors.black,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingM - 3),
                  MoreButton(onTap: onTap ?? () {}, text: 'Tap Here'),
                  const SizedBox(height: 20), // Adjust spacing if needed
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.asset(
              'assets/images/full-shot-friends-having-fun-together 1.png', // Placeholder image
              width: 150,
              height: 205,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 150,
                height: 205,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
