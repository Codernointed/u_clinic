import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/widgets/appbar/custom_app_bar.dart';

enum ThemeOption { light, dark, system }

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemeOption _selectedTheme = ThemeOption.light;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CAppBar(title: 'Theme', onBack: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Choose your preferred theme',
              style: AppTypography.heading3.copyWith(fontSize: 22),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ThemeOptionCard(
              title: 'Light Mode',
              groupValue: _selectedTheme,
              value: ThemeOption.light,
              onChanged: (value) => setState(() => _selectedTheme = value!),
              lightColor: const Color(0xFFFFFFFF),
              darkColor: const Color(0xFFF0F2F5),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ThemeOptionCard(
              title: 'Dark Mode',
              groupValue: _selectedTheme,
              value: ThemeOption.dark,
              onChanged: (value) => setState(() => _selectedTheme = value!),
              lightColor: const Color(0xFF2D2D2D),
              darkColor: const Color(0xFF1A1A1A),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ThemeOptionCard(
              title: 'System Default',
              groupValue: _selectedTheme,
              value: ThemeOption.system,
              onChanged: (value) => setState(() => _selectedTheme = value!),
              isSystem: true,
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeOptionCard extends StatelessWidget {
  final String title;
  final ThemeOption value;
  final ThemeOption groupValue;
  final ValueChanged<ThemeOption?> onChanged;
  final Color? lightColor;
  final Color? darkColor;
  final bool isSystem;

  const ThemeOptionCard({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.lightColor,
    this.darkColor,
    this.isSystem = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F9),
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.spacingS),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.spacingS - 1),
                child: isSystem
                    ? Row(
                        children: [
                          Expanded(
                            child: Container(color: const Color(0xFFFFFFFF)),
                          ),
                          Expanded(
                            child: Container(color: const Color(0xFF2D2D2D)),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(color: lightColor),
                          ),
                          Expanded(flex: 3, child: Container(color: darkColor)),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(child: Text(title, style: AppTypography.bodyLarge)),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF121417)
                        : const Color(0xFFDBE0E6),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF121417),
                          ),
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
