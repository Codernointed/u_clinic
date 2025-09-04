import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class CAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CAppBar({super.key, required this.title, this.onBack, this.actions});

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: onBack != null ? -15 : 20,
      title: Text(title, style: AppTypography.heading3),
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBack,
              color: AppColors.background,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
