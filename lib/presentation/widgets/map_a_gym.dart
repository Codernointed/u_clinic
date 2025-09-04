import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/widgets/buttons/more_button.dart';

class MapAGym extends StatelessWidget {
  final VoidCallback? onTap;

  const MapAGym({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 249,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.asset(
              'assets/images/gym.jpg',
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
          const SizedBox(width: 20),
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Map out of a Gym',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.5, // 24px line-height
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM - 3),
                  const Text(
                    'Trying to get fit? Use this feature to locate a gym nearby.',
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
                  MoreButton(onTap: onTap ?? () {}, text: 'Lets go!'),
                  const SizedBox(height: 20), // Adjust spacing if needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
