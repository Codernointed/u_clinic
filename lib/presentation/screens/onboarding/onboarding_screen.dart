import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/widgets/buttons/primary_button.dart';

/// The onboarding screen that introduces the app's features to new users.
///
/// This screen displays a series of pages with illustrations and descriptions
/// of the app's key features, with smooth animations and transitions.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Single onboarding page content
  final String _title = 'Welcome to U-Clinic';
  //something relating to u clinic
 final String _description = 
  'Effortlessly schedule campus clinic visits, consult securely with medical staff, '
  'and access your health records—all in one intuitive app. '
  'Stay on top of your well-being with timely notifications and personalized health tips '
  'tailored for the UMaT community.';

  final String _buttonText = 'Let\'s go';

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacementNamed('/healthcare-sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background image assets\images\splash.jpeg
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary.withOpacity(0.08), Colors.white],
              ),
            ),
            child: Image.asset(
              'assets/images/splash.jpeg',
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay for text readability
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(128), // 50% opacity
                  Colors.black.withAlpha(230), // 90% opacity
                ],
                stops: const [0.1, 0.5, 1.0],
              ),
            ),
          ),

          // // Skip button
          // Positioned(
          //   top: screenHeight * 0.05,
          //   right: screenWidth * 0.05,
          //   child: TextButton(
          //     onPressed: _skipToSignIn,
          //     child: Text(
          //       'Skip',
          //       style: AppTypography.bodyLarge.copyWith(
          //         color: AppColors.textSecondary,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),

          // Content
          Positioned(
            bottom: screenHeight * 0.15,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  _title,
                  style: AppTypography.heading1.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    // Extra bold
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Description
                Text(
                  _description,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                    fontWeight: FontWeight.w600, // Semi-bold
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                PrimaryButton(
                  text: _buttonText,
                  height: AppDimensions.buttonSmallHeight,
                  isFullWidth: false,
                  onPressed: _navigateToSignIn,
                  suffixIcon: Icons.arrow_forward_rounded,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Button
          // Positioned(
          //   bottom: screenHeight * 0.05,
          //   left: screenWidth * 0.1,
          //   right: screenWidth * 0.1,
          //   child: PrimaryButton(
          //     text: _buttonText,
          //     onPressed: _navigateToSignIn,
          //     suffixIcon: Icons.arrow_forward_rounded,
          //     backgroundColor: Colors.white,
          //     textColor: AppColors.primary,
          //   ),
          // ),
        ],
      ),
    );
  }

  // No need for page building methods as we have a single page
}

// No need for OnboardingPage class as we have a single page
