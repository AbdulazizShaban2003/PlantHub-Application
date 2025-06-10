import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' show Consumer;
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../manager/chat_provider.dart';
import '../components/action_sent_message.dart';
import '../components/image_source_message.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(SizeConfig().width(0.03)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeConfig().width(0.06)),
            color: ColorsManager.whiteColor,

            boxShadow: [
              BoxShadow(
                color: ColorsManager.blackColor.withOpacity(0.1),
                blurRadius: SizeConfig().width(0.025),
                offset: Offset(0, SizeConfig().height(0.0025)),
              ),
            ],
          ),
          child: Row(
            children: [
              ImageSourceMessage(provider: provider,),
              SizedBox(width: SizeConfig().width(0.02)),

              Expanded(
                child: TextFormField(
                  onFieldSubmitted: (v) {
                    if (!provider.isLoading && !provider.isListening && v.trim().isNotEmpty) {
                      provider.sendMessage();
                    }
                  },
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(14),color: ColorsManager.blackColor.withOpacity(0.8),fontWeight: FontWeight.w200),
                  controller: provider.userMessage,
                  enabled: !provider.isLoading,
                  decoration: InputDecoration(
                    hintText: provider.isLoading
                        ? AppStrings.pleaseWait
                        : (provider.isListening
                        ? AppStrings.listening
                        : AppStrings.askMe),
                    hintStyle: TextStyle(
                      color: provider.isLoading
                          ? ColorsManager.greyColor.shade400
                          : (provider.isListening
                          ? ColorsManager.redColor.shade600
                          : ColorsManager.greyColor),
                      fontSize: SizeConfig().responsiveFont(
                          provider.isListening ? 12 : 12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig().width(0.03),
                      vertical: SizeConfig().height(0.01),
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              SizedBox(width: SizeConfig().width(0.02)),

              ActionSentMessage(provider:provider),
            ],
          ),
        );
      },
    );
  }
}


