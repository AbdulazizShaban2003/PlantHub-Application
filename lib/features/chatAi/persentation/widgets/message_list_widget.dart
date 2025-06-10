import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/size_config.dart';
import '../../manager/chat_provider.dart';
import 'CustomMessagesWidget.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)), 
      itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.isLoading && index == 0) {
          return StreamBuilder<String>(
            stream: provider.botResponseController?.stream,
            builder: (context, snapshot) {
              final text = snapshot.data ?? '';
              return Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig().height(0.005)),
                child: Messages(
                  isUser: false,
                  message: text,
                  date: DateFormat('HH:mm').format(DateTime.now()),
                  isTyping: text.isEmpty,
                ),
              );
            },
          );
        }

        final messageIndex = provider.isLoading ? index - 1 : index;
        final reversedIndex = provider.messages.length - 1 - messageIndex;
        if (reversedIndex < 0 || reversedIndex >= provider.messages.length) {
          return const SizedBox.shrink();
        }

        final message = provider.messages[reversedIndex];

        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: SizeConfig().height(0.005)),
          child: Messages(
            isUser: message.isUser,
            message: message.message,
            image: message.imageFile,
            date: DateFormat('HH:mm').format(message.date),
            isTyping: false,
          ),
        );
      },
    );
  }
}