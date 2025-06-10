import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart' show SizeConfig;
import '../../../../core/widgets/appBar_view.dart';
import '../../controller/chat_provider.dart';
import '../widgets/CustomMessagesWidget.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig().height(0.03)),
              const CustomAppBarView(),
              const ChatStatsWidget(),
              const Expanded(child: MessagesList()),
              const MessageInput(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatStatsWidget extends StatelessWidget {
  const ChatStatsWidget({super.key});

@override
Widget build(BuildContext context) {
  return Consumer<ChatProvider>(
    builder: (context, provider, child) {
      final stats = provider.userStats;
      if (stats == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Messages: ${stats['messageCount'] ?? 0}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            GestureDetector(
              onTap: () => _showClearDialog(context, provider),
              child: const Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showClearDialog(BuildContext context, ChatProvider provider) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear All Messages'),
      content: const Text('Are you sure you want to delete all messages? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            provider.clearAllMessages();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete All'),
        ),
      ],
    ),
  );
}
}

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator for bot response
        if (provider.isLoading && index == 0) {
          return StreamBuilder<String>(
            stream: provider.botResponseController?.stream,
            builder: (context, snapshot) {
              final text = snapshot.data ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
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

        // Show actual messages
        final messageIndex = provider.isLoading ? index - 1 : index;
        final reversedIndex = provider.messages.length - 1 - messageIndex;

        if (reversedIndex < 0 || reversedIndex >= provider.messages.length) {
          return const SizedBox.shrink();
        }

        final message = provider.messages[reversedIndex];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image picker button - direct send
              PopupMenuButton<ImageSource>(
                enabled: !provider.isLoading && !provider.isListening,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo,
                    color: (provider.isLoading || provider.isListening)
                        ? Colors.grey.shade400
                        : Colors.grey,
                    size: 20,
                  ),
                ),
                onSelected: (source) => provider.pickImage(source),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ImageSource.camera,
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: ImageSource.gallery,
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Text input field
              Expanded(
                child: TextFormField(
                  onFieldSubmitted: (v) {
                    if (!provider.isLoading && !provider.isListening && v.trim().isNotEmpty) {
                      provider.sendMessage();
                    }
                  },
                  style: const TextStyle(fontSize: 14),
                  controller: provider.userMessage,
                  enabled: !provider.isLoading,
                  decoration: InputDecoration(
                    hintText: provider.isLoading
                        ? "Please wait..."
                        : (provider.isListening
                        ? "Listening... Release to send"
                        : "Type your message or hold mic..."),
                    hintStyle: TextStyle(
                      color: provider.isLoading
                          ? Colors.grey.shade400
                          : (provider.isListening
                          ? Colors.red.shade600
                          : Colors.grey),
                      fontSize: provider.isListening ? 12 : 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),

              // Send/Voice button
              GestureDetector(
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: provider.isLoading
                        ? Colors.grey.shade400
                        : (provider.isListening
                        ? Colors.red
                        : ColorsManager.greenPrimaryColor),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (provider.isLoading
                            ? Colors.grey.shade400
                            : (provider.isListening
                            ? Colors.red
                            : ColorsManager.greenPrimaryColor))
                            .withOpacity(0.3),
                        blurRadius: provider.isListening ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      provider.isListening
                          ? Icons.mic
                          : Icons.send,
                      color: Colors.white,
                      size: provider.isListening ? 22 : 20,
                      key: ValueKey(provider.isListening),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
