import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/screens/inspirations_screen.dart';
import 'package:u_clinic/presentation/screens/library_screen.dart';
import 'package:u_clinic/presentation/screens/news_screen.dart';
import 'package:u_clinic/presentation/screens/settings_screen.dart';
import 'package:u_clinic/presentation/widgets/emergency_section.dart';
import 'package:u_clinic/presentation/widgets/find_a_doctor.dart';
import 'package:u_clinic/presentation/widgets/health_condition_card.dart';
import 'package:u_clinic/presentation/widgets/health_tips_card.dart';
import 'package:u_clinic/presentation/widgets/health_tools_card.dart';
import 'package:u_clinic/presentation/widgets/home/home_app_bar.dart';
import 'package:u_clinic/presentation/widgets/info_card.dart';
import 'package:u_clinic/presentation/widgets/exposing_myths_card.dart';
import 'package:u_clinic/presentation/models/grid_item.dart';
import 'package:u_clinic/presentation/screens/see_all_screen.dart';
import 'package:u_clinic/presentation/widgets/map_a_gym.dart';
import 'package:u_clinic/presentation/widgets/section_header.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import 'package:u_clinic/presentation/helpers/fade_page_route.dart';
import 'package:u_clinic/presentation/widgets/talk_to_an_expert_card.dart';

// Mock data models
class NewsAlert {
  final String title;
  final String time;
  final String imagePath;
  NewsAlert({required this.title, required this.time, required this.imagePath});
}

class HealthCondition {
  final String name;
  final String imagePath;
  HealthCondition({required this.name, required this.imagePath});
}

class Inspiration {
  final String title;
  final String subtitle;
  final String imagePath;
  Inspiration({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class Event {
  final String title;
  final String subtitle;
  final String imagePath;
  Event({required this.title, required this.subtitle, required this.imagePath});
}

class HealthTip {
  final String title;
  final String imagePath;
  HealthTip({required this.title, required this.imagePath});
}

class HealthTool {
  final String title;
  final String imagePath;
  HealthTool({required this.title, required this.imagePath});
}

class Myth {
  final String title;
  final String imagePath;
  Myth({required this.title, required this.imagePath});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;
  late final List<BottomNavigationBarItem> _navBarItems;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Pre-cache icons for the navigation bar
    _navBarItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined, size: 24),
        activeIcon: Icon(Icons.home, size: 24),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.library_books_outlined, size: 17),
        activeIcon: Icon(Icons.library_books, size: 17),
        label: 'Library',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.article_outlined, size: 15),
        activeIcon: Icon(Icons.article, size: 15),
        label: 'News',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined, size: 24),
        activeIcon: Icon(Icons.settings, size: 24),
        label: 'Settings',
      ),
    ];

    _widgetOptions = <Widget>[
      NewHomePageContent(
        key: const ValueKey('home'),
        onNavigate: _onItemTapped,
      ),
      const LibraryScreen(key: ValueKey('library')),
      // const NewsScreen(key: ValueKey('news')),
      const SettingsScreen(key: ValueKey('settings')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12,
        items: _navBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class NewHomePageContent extends StatefulWidget {
  final Function(int) onNavigate;

  const NewHomePageContent({super.key, required this.onNavigate});

  @override
  State<NewHomePageContent> createState() => _NewHomePageContentState();
}

class _NewHomePageContentState extends State<NewHomePageContent> {
  final PageController _newsCarouselController = PageController();
  int _currentNewsPage = 0;

  final List<NewsAlert> _newsAlerts = [
    NewsAlert(
      title: 'Global Summit on Non-Communicable Diseases',
      time: '8 mins ago',
      imagePath: 'assets/images/inspiration1.png',
    ),
    NewsAlert(
      title: 'New Breakthrough in Cancer Treatment',
      time: '30 mins ago',
      imagePath: 'assets/images/inspiration2.png',
    ),
    NewsAlert(
      title: 'Mental Health Awareness Week Begins',
      time: '1 hour ago',
      imagePath: 'assets/images/diabetes.png',
    ),
  ];

  final List<HealthCondition> _healthConditions = [
    HealthCondition(name: 'Headaches', imagePath: 'assets/images/headache.png'),
    HealthCondition(name: 'Diabetes', imagePath: 'assets/images/diabetes.png'),
    HealthCondition(name: 'Exercise', imagePath: 'assets/images/exercise.png'),
    HealthCondition(name: 'Sleep', imagePath: 'assets/images/sleep.png'),
    HealthCondition(
      name: 'Nutrition',
      imagePath: 'assets/images/nutrition.png',
    ),
  ];

  final List<Inspiration> _inspirations = [
    Inspiration(
      title: 'You are stronger than you think',
      subtitle: 'A story of resilience and recovery from a chronic illness.',
      imagePath: 'assets/images/inspiration1.png',
    ),
    Inspiration(
      title: 'The power of a positive mindset',
      subtitle: 'How optimism can improve your health outcomes.',
      imagePath: 'assets/images/inspiration2.png',
    ),
  ];

  final List<Event> _events = [
    Event(
      title: 'You are stronger than you think',
      subtitle: 'A story of resilience and recovery from a chronic illness.',
      imagePath: 'assets/images/inspiration1.png',
    ),
    Event(
      title: 'The power of a positive mindset',
      subtitle: 'How optimism can improve your health outcomes.',
      imagePath: 'assets/images/inspiration2.png',
    ),
  ];

  final List<HealthTip> _healthTips = [
    HealthTip(title: 'Stay Hydrated', imagePath: 'assets/images/car.png'),
    HealthTip(
      title: 'Eat a Balanced Diet',
      imagePath: 'assets/images/health_tip2.png',
    ),
    HealthTip(
      title: 'Get Regular Exercise',
      imagePath: 'assets/images/health_tip3.png',
    ),
  ];

  final List<HealthTool> _healthTools = [
    HealthTool(title: 'Symptom Checker', imagePath: 'assets/images/car.png'),
    HealthTool(
      title: 'Find in a Doctor',
      imagePath: 'assets/images/health_tip2.png',
    ),
    HealthTool(
      title: 'Talk to an Expert',
      imagePath: 'assets/images/health_tip3.png',
    ),
  ];

  final List<Myth> _myths = [
    Myth(
      title: 'Cracking your knuckles gives you arthritis',
      imagePath: 'assets/images/myth1.png',
    ),
    Myth(
      title: 'You should drink 8 glasses of water a day',
      imagePath: 'assets/images/myth2.png',
    ),
    Myth(
      title: 'A hangover is caused by dehydration',
      imagePath: 'assets/images/myth3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            _buildNewsCarouselSection(),
            const SizedBox(height: AppDimensions.spacingXS),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildExposingMythsSection(),
                  // const SizedBox(height: AppDimensions.spacingXS),
                  // _buildInspirationsSection(),
                  // const SizedBox(height: AppDimensions.spacingXS),
                  // _buildHealthConditionsSection(),
                  const SizedBox(height: AppDimensions.spacingS),
                  _buildHealthToolsSection(),
                  const SizedBox(height: AppDimensions.spacingS),
                ],
              ),
            ),
            const EmergencySection(),
            const SizedBox(height: AppDimensions.spacingM),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: AppDimensions.screenPaddingHorizontal,
            //   ),
            //   child: _buildMedWeekSection(),
            // ),
            const SizedBox(height: AppDimensions.spacingS),
            // TalkToAnExpertCard(onTap: () {}),
            const SizedBox(height: AppDimensions.spacingXS),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacingS),
                  _buildHealthTipsSection(),
                  const SizedBox(height: AppDimensions.spacingS),
                  FindADoctor(onTap: () {}),
                  // const SizedBox(height: AppDimensions.spacingS),
                  // _buildEventLineUpSection(),
                  // const SizedBox(height: AppDimensions.spacingS),
                  // MapAGym(onTap: () {}),
                  // const SizedBox(height: AppDimensions.spacingS),
                  // _buildAgenciesandOrganizationsSection(),
                  // const SizedBox(height: AppDimensions.spacingS),
                  // _buildPoliciesAndInsurancesSection(),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCarouselSection() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _newsCarouselController,
            itemCount: _newsAlerts.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(index);
            },
            onPageChanged: (index) {
              setState(() {
                _currentNewsPage = index;
              });
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: _buildDotIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(_newsAlerts[index].imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 25,
          left: 10,
          right: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white.withAlpha(191),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghana Launches "PharmaDrones"...',
                      style: AppTypography.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      'Ghana Has Launched An Drone System That Seeks To Facilitate The Delivery Of Prescriptions...',
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_newsAlerts.length, (index) {
        return Container(
          width: _currentNewsPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentNewsPage == index
                ? Colors.white
                : Colors.white.withAlpha(128),
          ),
        );
      }),
    );
  }

  Widget _buildHealthConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Health Conditions'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: SeeAllScreen(
                      title: 'Health Conditions',
                      items: _healthConditions
                          .map(
                            (e) =>
                                GridItem(title: e.name, imagePath: e.imagePath),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        // const SizedBox(height: AppDimensions.spacingXXS ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _healthConditions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppDimensions.spacingS),
            itemBuilder: (context, index) {
              final condition = _healthConditions[index];
              return HealthConditionCard(
                title: condition.name,
                imagePath: condition.imagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInspirationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Inspirations'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(child: const InspirationsScreen()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _inspirations.length,
            itemBuilder: (context, index) {
              final inspiration = _inspirations[index];
              return InfoCard(
                title: inspiration.title,
                subtitle: inspiration.subtitle,
                imagePath: inspiration.imagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventLineUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Event Lineup'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: SeeAllScreen(
                      title: 'Event Lineup',
                      items: _events
                          .map(
                            (e) => GridItem(
                              title: e.title,
                              imagePath: e.imagePath,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: PageController(viewportFraction: 0.9),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return InfoCard(
                title: event.title,
                subtitle: event.subtitle,
                imagePath: event.imagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgenciesandOrganizationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Agencies and Organizations'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: SeeAllScreen(
                      title: 'Agencies and Organizations',
                      items: _events
                          .map(
                            (e) => GridItem(
                              title: e.title,
                              imagePath: e.imagePath,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: PageController(viewportFraction: 0.9),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return InfoCard(
                title: event.title,
                subtitle: event.subtitle,
                imagePath: event.imagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPoliciesAndInsurancesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Policies and Insurances'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: SeeAllScreen(
                      title: 'Policies and Insurances',
                      items: _events
                          .map(
                            (e) => GridItem(
                              title: e.title,
                              imagePath: e.imagePath,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: PageController(viewportFraction: 0.9),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return InfoCard(
                title: event.title,
                subtitle: event.subtitle,
                imagePath: event.imagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Health Tips'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: SeeAllScreen(
                      title: 'Health Tips',
                      items: _healthTips
                          .map(
                            (e) => GridItem(
                              title: e.title,
                              imagePath: e.imagePath,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _healthTips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tip = _healthTips[index];
              return HealthTipsCard(title: tip.title, imagePath: tip.imagePath);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHealthToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionHeader(title: 'Health Tools'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: SeeAllScreen(
                      title: 'Health Tools',
                      items: _healthTools
                          .map(
                            (e) => GridItem(
                              title: e.title,
                              imagePath: e.imagePath,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('See All', style: TextStyle(color: AppColors.primary)),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _healthTools.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final healthTool = _healthTools[index];
              return GestureDetector(
                onTap: () {
                  if (healthTool.title == 'Symptom Checker') {
                    Navigator.pushNamed(context, AppRouter.symptomChecker);
                  }
                  // Add navigation for other tools here
                },
                child: HealthToolsCard(
                  title: healthTool.title,
                  imagePath: healthTool.imagePath,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExposingMythsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text('Exposing Myths', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
              const SectionHeader(title: 'Exposing Myths'),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    FadePageRoute(
                      child: SeeAllScreen(
                        title: 'Exposing Myths',
                        items: _myths
                            .map(
                              (myth) => GridItem(
                                title: myth.title,
                                imagePath: myth.imagePath,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text('See All', style: TextStyle(color: AppColors.primary)),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _myths.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final myth = _myths[index];
              return ExposingMythsCard(
                title: myth.title,
                imagePath: myth.imagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedWeekSection() {
    // Using a LayoutBuilder to get the constraints and make the width responsive
    // while keeping the aspect ratio from the design (366 / 249).
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = width * (249 / 366);

        // Calculate scale factors to make positioning responsive
        double scaleX = width / 366;
        double scaleY = height / 249;

        return Container(
          width: width,
          height: height,
          color: Colors.white, // As per 'background: #FFFFFF'
          child: Stack(
            children: [
              Positioned(
                left: 65 * scaleX,
                top: 24 * scaleY,
                child: const Text(
                  "Highlights on MedWeek ‘24",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                left: 22 * scaleX,
                top: 69 * scaleY,
                width: 320 * scaleX,
                height: 158 * scaleY,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.asset(
                    'assets/images/full-shot-friends-having-fun-together 1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Centering the play icon on top of the image
              Positioned(
                left: (22 + 320 / 2) * scaleX - (50 / 2),
                top: (69 + 158 / 2) * scaleY - (50 / 2),
                width: 50,
                height: 50,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54, // Simulating the icon background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ToolCard extends StatelessWidget {
  final String title;
  final String iconPath;

  const ToolCard({super.key, required this.title, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.medical_services,
              size: 32,
            ), // Using a medical icon instead of SVG
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.bodySmall),
      ],
    );
  }
}
