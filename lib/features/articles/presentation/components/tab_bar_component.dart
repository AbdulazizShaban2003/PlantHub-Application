import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../config/theme/app_colors.dart';

class TabBarComponent extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const TabBarComponent({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = SizeConfig().responsiveFont(13);
    final horizontalPadding = SizeConfig().width(0.01);

    return SizedBox(
      height: SizeConfig().height(0.05),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return _buildTabItem(tabs[index], isSelected, index, horizontalPadding, fontSize);
        },
      ),
    );
  }

  Widget _buildTabItem(String tab, bool isSelected, int index, double horizontalPadding, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => onTabSelected(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? ColorsManager.greenPrimaryColor : ColorsManager.whiteColor,
            borderRadius: BorderRadius.circular(30),
          ),
          padding:  EdgeInsets.symmetric(horizontal: SizeConfig().width(0.1), vertical: SizeConfig().height(0.01)),
          child: Text(
            tab,
            style: TextStyle(
              color: isSelected ? ColorsManager.whiteColor : ColorsManager.blackColor,
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}