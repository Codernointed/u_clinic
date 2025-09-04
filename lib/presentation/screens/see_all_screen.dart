import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/models/grid_item.dart';
import 'package:u_clinic/presentation/widgets/grid_card.dart';
import 'package:u_clinic/presentation/widgets/search_bar.dart';

class SeeAllScreen extends StatefulWidget {
  final String title;
  final List<GridItem> items;

  const SeeAllScreen({super.key, required this.title, required this.items});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  late List<GridItem> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return item.title.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.title.endsWith('s')
        ? widget.title.substring(0, widget.title.length - 1)
        : widget.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle, style: AppTypography.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        elevation: 0,
        // backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Hero(
              tag: 'search-bar',
              child: Material(
                type: MaterialType.transparency,
                child: AppSearchBar(
                  controller: _searchController,
                  onChanged: _filterItems,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 108 / 168,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return GridCard(title: item.title, imagePath: item.imagePath);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
