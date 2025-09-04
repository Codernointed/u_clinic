import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

/// A premium styled text field with animation effects.
///
/// This text field is designed to be used throughout the app for input fields.
/// It includes focus animations and styling consistent with the app's design system.
class CustomTextField extends StatefulWidget {
  /// The label text displayed above the text field.
  final String? label;

  /// The hint text displayed inside the text field when empty.
  final String? hintText;

  /// The controller for the text field.
  final TextEditingController controller;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// The keyboard type to use for the text field.
  final TextInputType keyboardType;

  /// The validator function for form validation.
  final String? Function(String?)? validator;

  /// The icon to display at the start of the text field.
  final Widget? prefixIcon;

  /// The icon to display at the end of the text field.
  final Widget? suffixIcon;

  /// Whether the text field is enabled.
  final bool enabled;

  /// The action to perform when the text field is submitted.
  final TextInputAction? textInputAction;

  /// The callback that is called when the text field is submitted.
  final Function(String)? onSubmitted;

  /// The callback that is called when the text field's content changes.
  final Function(String)? onChanged;

  /// Optional input formatters or masks.
  final List<TextInputFormatter>? inputFormatters;

  /// Creates a [CustomTextField].
  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool isFocused = false;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _fillColorAnimation;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animationDurationS),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fillColorAnimation =
        ColorTween(begin: AppColors.surfaceLight, end: Colors.white).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _handleFocusChange() {
    setState(() {
      isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.label),
          const SizedBox(height: AppDimensions.spacingS),
        ],
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: _fillColorAnimation.value,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: isFocused ? AppColors.primary : Colors.transparent,
                  width: _borderAnimation.value,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                style: AppTypography.inputText,
                focusNode: _focusNode,
                enabled: widget.enabled,
                textInputAction: widget.textInputAction,
                onFieldSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
                inputFormatters: widget.inputFormatters,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.inputText.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingM,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
