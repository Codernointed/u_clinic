import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';

class AuthTabSwitcher extends StatefulWidget {
  final PageController pageController;

  const AuthTabSwitcher({super.key, required this.pageController});

  @override
  AuthTabSwitcherState createState() => AuthTabSwitcherState();
}

class AuthTabSwitcherState extends State<AuthTabSwitcher> {
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = widget.pageController.page!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 253,
      height: 36,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [_buildTab('Mobile Phone', 0), _buildTab('Email Address', 1)],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isSelected = _currentPage.round() == index;
    final bool isFirst = index == 0;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: isFirst
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
