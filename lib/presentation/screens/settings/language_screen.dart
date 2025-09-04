import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/widgets/appbar/custom_app_bar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'French',
    'Portuguese',
    'Spanish',
    'Swahili',
    'Amharic',
    'Yoruba',
    'Igbo',
    'Hausa',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CAppBar(title: 'Language', onBack: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingHorizontal,
              20,
              AppDimensions.screenPaddingHorizontal,
              12,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'App language',
                style: AppTypography.heading2.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF121417),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              itemCount: _languages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final language = _languages[index];
                return LanguageOptionTile(
                  language: language,
                  isSelected: _selectedLanguage == language,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              AppDimensions.screenPaddingHorizontal,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement save functionality
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A6EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: AppTypography.bodyLarge.copyWith(
                    color: const Color(0xFF121417),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LanguageOptionTile extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 53,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color(0xFF121417)
                : const Color(0xFFDBE0E6),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFF121417),
                fontWeight: FontWeight.w500,
              ),
            ),
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
