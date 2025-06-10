import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../manager/chat_provider.dart';

class ActionSentMessage extends StatelessWidget {
  const ActionSentMessage({
    super.key, required this.provider,
  });
  final ChatProvider provider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        if (!provider.isLoading) {
          provider.startListening();
        }
      },
      onLongPressEnd: (_) {
        if (provider.isListening) {
          provider.manualStopListening();
        }
      },
      onTap: () {
        if (!provider.isLoading && !provider.isListening) {
          provider.sendMessage();
        }
      },
      child: Container(
        padding: EdgeInsets.all(SizeConfig().width(0.03)),
        decoration: BoxDecoration(
          color: provider.isLoading
              ? ColorsManager.greyColor.shade400
              : (provider.isListening
              ? ColorsManager.redColor
              : ColorsManager.greenPrimaryColor),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (provider.isLoading
                  ? ColorsManager.greyColor.shade400
                  : (provider.isListening
                  ? ColorsManager.redColor
                  : ColorsManager.greenPrimaryColor))
                  .withOpacity(0.3),
              blurRadius: SizeConfig().width(
                  provider.isListening ? 0.03 : 0.02),
              offset: Offset(0, SizeConfig().height(0.0025)),
            ),
          ],
        ),
        child: provider.isLoading
            ? SizedBox(
          width: SizeConfig().width(0.05),
          height: SizeConfig().width(0.05),
          child: CircularProgressIndicator(
            strokeWidth: SizeConfig().width(0.005),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        )
            : AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            provider.isListening ? Icons.mic : Icons.send,
            color:ColorsManager.whiteColor,
            size: SizeConfig().responsiveFont(
                provider.isListening ? 20 : 20),
            key: ValueKey(provider.isListening),
          ),
        ),
      ),
    );
  }
}
