import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import '../../data/models/plant_model.dart';
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

class _PlantDetailsContentState extends State<PlantDetailsContent>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final _tabs = [
    AppKeyStringTr.overview,
    AppKeyStringTr.diseases,
    AppKeyStringTr.conditions,
    AppKeyStringTr.care
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TabBarComponent(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() => _selectedTabIndex = index);
              _tabController.animateTo(index);
            },
          ),
        ),
        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(plant: widget.plant),
              DiseasesTab(diseases: widget.plant.diseases ?? []),
              ConditionsTab(conditions: widget.plant.climaticConditions ?? _getDefaultConditions()),
              CareTab(care: widget.plant.care ?? _getDefaultCare()),
            ],
          ),
        ),
      ],
    );
  }

  _getDefaultConditions() {

    return null;
  }

  _getDefaultCare() {

    return null;
  }
}
