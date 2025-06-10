import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../manager/chat_provider.dart';
import '../controller/clear_dialog_controller.dart';

class ChatStatsWidget extends StatelessWidget {
  const ChatStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final stats = provider.userStats;
        if (stats == null) return const SizedBox.shrink();
        return Container(
          margin: EdgeInsets.only(bottom: SizeConfig().height(0.012)),
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig().width(0.04),
            vertical: SizeConfig().height(0.01),
          ),
          decoration: BoxDecoration(
            color: ColorsManager.whiteColor,
            borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.blackColor.withOpacity(0.05),
                blurRadius: SizeConfig().width(0.01),
                offset: Offset(0, SizeConfig().height(0.0012)),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.message}: ${stats['messageCount'] ?? 0}',
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(12),
                  color: ColorsManager.greyColor,
                ),
              ),
              GestureDetector(
                onTap: () => showClearDialog(context, provider),
                child: Icon(
                  Icons.delete_outline,
                  size: SizeConfig().responsiveFont(16),
                  color: ColorsManager.redColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}