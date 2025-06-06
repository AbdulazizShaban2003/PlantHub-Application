import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import '../../data/models/plant_model.dart';
import '../components/plant_image_component.dart';
import '../components/tab_bar_component.dart';
import 'custom_care_tab_widget.dart';
import 'custom_condition_tap_widget.dart';
import 'custom_overview_widget.dart';
import 'diseases_tab_widget.dart';

class PlantDetailsContent extends StatefulWidget {
  final Plant plant;

  const PlantDetailsContent({
    super.key,
    required this.plant,
  });

  @override
  State<PlantDetailsContent> createState() => _PlantDetailsContentState();
}

class _PlantDetailsContentState extends State<PlantDetailsContent> {
  int _selectedTabIndex = 0;
  final _tabs = [AppKeyStringTr.overview,AppKeyStringTr.diseases, AppKeyStringTr.conditions, AppKeyStringTr.care];
  final _pageController = PageController();
  @override
  void initState() {

    super.initState();

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlantImage(imageUrl: widget.plant.image),
        TabBarComponent(
          tabs: _tabs,
          selectedIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() => _selectedTabIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),

        Expanded(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedTabIndex = index),
            children: [
              OverviewTab(plant: widget.plant),
              DiseasesTab(diseases: widget.plant.diseases),
              ConditionsTab(conditions: widget.plant.climaticConditions),
              CareTab(care: widget.plant.care),
            ],
          ),
        ),
      ],
    );
  }
}