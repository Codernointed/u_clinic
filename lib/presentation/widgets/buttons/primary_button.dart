import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

/// A premium styled primary button with animation effects.
///
/// This button is designed to be used as the main call-to-action button
/// throughout the app. It includes a scale animation on press for a premium feel.
class PrimaryButton extends StatefulWidget {
  /// The text to display on the button.
  final String text;

  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;

  /// The callback that is called when the button is double tapped.
  final VoidCallback? onDoubleTap;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button should take the full width of its parent.
  final bool isFullWidth;

  /// The height of the button.
  final double height;

  final double width;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The text color of the button.
  final Color? textColor;

  /// The icon to display before the text.
  final IconData? prefixIcon;

  /// The icon to display after the text.
  final IconData? suffixIcon;

  /// border radius of the button.
  final double? borderRadius;

  /// font size of the button text.
  final double? fontSize;

  /// Creates a [PrimaryButton].
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onDoubleTap,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = AppDimensions.buttonHeight,
    this.width = AppDimensions.buttonSmallWidth,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
    this.fontSize,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animationDurationXS),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.backgroundColor ?? AppColors.primary;
    final Color txtColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        if (!widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : widget.width,
          decoration: BoxDecoration(
            color: widget.isLoading ? bgColor.withValues(alpha: 0.8) : bgColor,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppDimensions.radiusCircular,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: bgColor.withOpacity(0.3),
            //     blurRadius: 8,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
              ),
              child: _buildButtonContent(txtColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          Icon(widget.prefixIcon, color: textColor, size: 20),
          const SizedBox(width: AppDimensions.spacingS),
        ],
        Text(
          widget.text,
          style: AppTypography.buttonText.copyWith(
            color: textColor,
            fontSize: widget.fontSize,
          ),
        ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: AppDimensions.spacingS),
          Icon(widget.suffixIcon, color: textColor, size: 20),
        ],
      ],
    );
  }
}
