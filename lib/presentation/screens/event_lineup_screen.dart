import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/widgets/appbar/custom_app_bar.dart';
import 'package:u_clinic/presentation/widgets/cards/event_card.dart';

class EventLineupScreen extends StatelessWidget {
  const EventLineupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppBar(
        title: 'Event Lineup',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          children: [
            EventCard(
              date: '25 Oct',
              title: 'Annual General Meeting',
              time: '10:00 AM - 12:00 PM',
              location: 'Virtual',
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.spacingM),
            EventCard(
              date: '28 Oct',
              title: 'Health Tech Summit',
              time: '09:00 AM - 05:00 PM',
              location: 'Conference Hall A',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
