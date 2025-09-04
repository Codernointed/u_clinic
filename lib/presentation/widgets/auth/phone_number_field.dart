// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:intl_phone_field/phone_number.dart';
// import 'package:intl_phone_field/countries.dart';
// import 'package:u_clinic/core/theme/app_colors.dart';
// import 'package:u_clinic/core/theme/app_dimensions.dart';
// import 'package:u_clinic/core/theme/app_typography.dart';

// class PhoneNumberField extends StatefulWidget {
//   final TextEditingController? controller;
//   final Function(String)? onChanged;
//   final String? Function(PhoneNumber?)? validator;

//   const PhoneNumberField({
//     super.key,
//     this.controller,
//     this.onChanged,
//     this.validator,
//   });

//   @override
//   State<PhoneNumberField> createState() => _PhoneNumberFieldState();
// }

// class _PhoneNumberFieldState extends State<PhoneNumberField>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Color?> _fillColorAnimation;
//   late FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _focusNode.addListener(_handleFocusChange);

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: AppDimensions.animationDurationS),
//     );

//     _fillColorAnimation =
//         ColorTween(begin: AppColors.surfaceLight, end: Colors.white).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeInOut,
//           ),
//         );
//   }

//   void _handleFocusChange() {
//     if (_focusNode.hasFocus) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     _focusNode.removeListener(_handleFocusChange);
//     _focusNode.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return IntlPhoneField(
//           autovalidateMode: AutovalidateMode.disabled,
//           validator: widget.validator,
//           focusNode: _focusNode,
//           controller: widget.controller,
//           decoration: InputDecoration(
//             hintText: 'Phone Number',
//             hintStyle: AppTypography.bodyMedium.copyWith(
//               color: AppColors.textTertiary,
//             ),
//             counterText: '',
//             filled: true,
//             fillColor: _fillColorAnimation.value,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//               borderSide: const BorderSide(
//                 color: AppColors.primary,
//                 width: 1.5,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//               borderSide: const BorderSide(color: AppColors.divider),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//               borderSide: const BorderSide(
//                 color: AppColors.primary,
//                 width: 1.5,
//               ),
//             ),
//           ),
//           initialCountryCode: 'GH',
//           // countries: countries.where((country) {
//           //   const africanCountryCodes = [
//           //     'DZ', 'AO', 'BJ', 'BW', 'BF', 'BI', 'CV', 'CM', 'CF', 'TD', 'KM', 'CD',
//           //     'CG', 'CI', 'DJ', 'EG', 'GQ', 'ER', 'SZ', 'ET', 'GA', 'GM', 'GH', 'GN',
//           //     'GW', 'KE', 'LS', 'LR', 'LY', 'MG', 'MW', 'ML', 'MR', 'MU', 'YT', 'MA',
//           //     'MZ', 'NA', 'NE', 'NG', 'RE', 'RW', 'SH', 'ST', 'SN', 'SC', 'SL', 'SO',
//           //     'ZA', 'SS', 'SD', 'TZ', 'TG', 'TN', 'UG', 'EH', 'ZM', 'ZW'
//           //   ];
//           //   return africanCountryCodes.contains(country.code);
//           // }).toList(),
//           onChanged: (phone) {
//             if (widget.onChanged != null) {
//               widget.onChanged!(phone.completeNumber);
//             }
//           },
//         );
//       },
//     );
//   }
// }
