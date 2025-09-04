// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:u_clinic/core/routes/fade_page_route.dart';

// import 'package:u_clinic/core/theme/app_colors.dart';
// import 'package:u_clinic/core/theme/app_dimensions.dart';
// import 'package:u_clinic/core/theme/app_typography.dart';
// import 'package:u_clinic/presentation/models/grid_item.dart';
// import 'package:u_clinic/presentation/screens/home_page.dart';
// import 'package:u_clinic/presentation/screens/see_all_screen.dart';
// import 'package:u_clinic/presentation/widgets/info_card.dart';
// import 'package:u_clinic/presentation/widgets/search_bar.dart';
// import 'package:u_clinic/presentation/widgets/section_header.dart';

// class NewsScreen extends StatefulWidget {
//   const NewsScreen({super.key});

//   @override
//   State<NewsScreen> createState() => _NewsScreenState();
// }

// class _NewsScreenState extends State<NewsScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   int _selectedCategoryIndex = 0;

//   final List<String> _breakingNewsImages = [
//     'assets/images/inspiration1.png',
//     'assets/images/inspiration2.png',
//     'assets/images/hypertension.png',
//     'assets/images/diabetes.png',
//   ];

//   final List<String> _categories = [
//     'For you',
//     'Technology',
//     'Health',
//     'Lifestyle',
//     'Science',
//     'Entertainment',
//   ];
//   final List<Event> _events = [
//     Event(
//       title: 'You are stronger than you think',
//       subtitle: 'A story of resilience and recovery from a chronic illness.',
//       imagePath: 'assets/images/inspiration1.png',
//     ),
//     Event(
//       title: 'The power of a positive mindset',
//       subtitle: 'How optimism can improve your health outcomes.',
//       imagePath: 'assets/images/inspiration2.png',
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController.addListener(() {
//       setState(() {
//         _currentPage = _pageController.page!.round();
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(56.0),
//         child: AppBar(
//           //the title should be on the left
//           title: const Text('News', style: AppTypography.heading3),
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           centerTitle: false,
//           // backgroundColor: Colors.transparent,
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppDimensions.screenPaddingHorizontal,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Hero(tag: 'search-bar', child: AppSearchBar()),
//             const SizedBox(height: AppDimensions.spacingL),
//             const Text('Breaking News', style: AppTypography.heading3),
//             const SizedBox(height: AppDimensions.spacingM),
//             _buildBreakingNewsCarousel(),
//             const SizedBox(height: AppDimensions.spacingL),
//             slidingCard("Public Health"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Mental Awareness"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Maternal Health"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Men's Health"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Women's Health"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Children's Health"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Senior's Health"),
//             const SizedBox(height: AppDimensions.spacingM),
//             slidingCard("Health"),
//             // const Text("Editor's Pick", style: AppTypography.heading3),
//             // const SizedBox(height: AppDimensions.spacingM),
//             // _buildCategoryFilters(),
//             // const SizedBox(height: AppDimensions.spacingL),
//             // _buildNewsArticleList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget slidingCard(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             SectionHeader(title: title),
//             const Spacer(),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   FadePageRoute(
//                     child: SeeAllScreen(
//                       title: title,
//                       items: _events
//                           .map(
//                             (e) => GridItem(
//                               title: e.title,
//                               imagePath: e.imagePath,
//                             ),
//                           )
//                           .toList(),
//                     ),
//                   ),
//                 );
//               },
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text('See All', style: TextStyle(color: AppColors.primary)),
//                   SizedBox(width: 5),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     size: 10,
//                     color: AppColors.primary,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppDimensions.spacingXS),
//         SizedBox(
//           height: 220,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             controller: PageController(viewportFraction: 0.9),
//             itemCount: _events.length,
//             itemBuilder: (context, index) {
//               final event = _events[index];
//               return InfoCard(
//                 title: event.title,
//                 subtitle: event.subtitle,
//                 imagePath: event.imagePath,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBreakingNewsCarousel() {
//     return SizedBox(
//       height: 200,
//       child: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: _breakingNewsImages.length,
//             itemBuilder: (context, index) {
//               return _buildCarouselItem(index);
//             },
//           ),
//           Positioned(
//             bottom: 10,
//             left: 0,
//             right: 0,
//             child: _buildDotIndicator(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCarouselItem(int index) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
//             image: DecorationImage(
//               image: AssetImage(_breakingNewsImages[index]),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: AppDimensions.spacingM,
//           left: AppDimensions.spacingM,
//           right: AppDimensions.spacingM,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//               child: Container(
//                 padding: const EdgeInsets.all(AppDimensions.spacingM),
//                 color: AppColors.background.withAlpha(191),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Ghana Launches "PharmaDrones"...',
//                       style: AppTypography.bodyLarge,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: AppDimensions.spacingXS),
//                     Text(
//                       'Ghana Has Launched An Drone System That Seeks To Facilitate The Delivery Of Prescriptions...',
//                       style: AppTypography.bodyMedium,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDotIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(_breakingNewsImages.length, (index) {
//         return Container(
//           width: _currentPage == index
//               ? AppDimensions.spacingL
//               : AppDimensions.spacingS,
//           height: AppDimensions.spacingS,
//           margin: const EdgeInsets.symmetric(
//             horizontal: AppDimensions.spacingXS,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(AppDimensions.spacingXS),
//             color: _currentPage == index
//                 ? AppColors.background
//                 : AppColors.background.withAlpha(128),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildCategoryFilters() {
//     return SizedBox(
//       height: AppDimensions.buttonSmallHeight,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _categories.length,
//         itemBuilder: (context, index) {
//           final bool isSelected = _selectedCategoryIndex == index;
//           return Padding(
//             padding: const EdgeInsets.only(right: AppDimensions.spacingS),
//             child: ChoiceChip(
//               label: Text(_categories[index]),
//               selected: isSelected,
//               onSelected: (bool selected) {
//                 setState(() {
//                   if (selected) {
//                     _selectedCategoryIndex = index;
//                   }
//                 });
//               },
//               backgroundColor: AppColors.surfaceLight,
//               selectedColor: AppColors.primary,
//               labelStyle: AppTypography.caption.copyWith(
//                 color: isSelected
//                     ? AppColors.background
//                     : AppColors.textPrimary,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(
//                   AppDimensions.cardBorderRadius,
//                 ),
//                 side: BorderSide.none,
//               ),
//               showCheckmark: false,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppDimensions.spacingM,
//                 vertical: AppDimensions.spacingXS,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildNewsArticleList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 5, // Placeholder count
//       itemBuilder: (context, index) {
//         return _buildArticleCard();
//       },
//     );
//   }

//   Widget _buildArticleCard() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
//       padding: const EdgeInsets.all(AppDimensions.spacingM),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
//         boxShadow: const [
//           BoxShadow(
//             color: AppColors.shadow,
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
//             child: Image.asset(
//               'assets/images/exercise.png', // Placeholder image
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(width: AppDimensions.spacingM),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Maternal Health', style: AppTypography.label),
//                 SizedBox(height: 4),
//                 Text('Title', style: AppTypography.heading4),
//                 SizedBox(height: 4),
//                 Text(
//                   'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit, Sed Do Eiusmod Tempor',
//                   style: AppTypography.bodySmall,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
