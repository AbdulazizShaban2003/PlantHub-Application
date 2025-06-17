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
    final horizontalPadding = SizeConfig().width(0.008);

    return Container(
      height: SizeConfig().height(0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return _buildTabItem(
            tabs[index],
            isSelected,
            index,
            horizontalPadding,
            fontSize,
          );
        },
      ),
    );
  }

  Widget _buildTabItem(
      String tab,
      bool isSelected,
      int index,
      double horizontalPadding,
      double fontSize,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTabSelected(index),
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  ColorsManager.greenPrimaryColor,
                  ColorsManager.greenPrimaryColor.withOpacity(0.8),
                ],
              )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: ColorsManager.greenPrimaryColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().width(0.08),
              vertical: SizeConfig().height(0.012),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? ColorsManager.whiteColor
                    : ColorsManager.blackColor.withOpacity(0.7),
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              child: Text(tab),
            ),
          ),
        ),
      ),
    );
  }
}
