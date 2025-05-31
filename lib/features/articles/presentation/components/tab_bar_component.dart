import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class TabBarComponent extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const TabBarComponent({super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      child: Row(
        children:
        tabs.map((tab) {
          final index = tabs.indexOf(tab);
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(tab),
              selected: isSelected,
              onSelected: (_) => onTabSelected(index),
              selectedColor: ColorsManager.greenPrimaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color:
                  isSelected
                      ? ColorsManager.greenPrimaryColor
                      : Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
