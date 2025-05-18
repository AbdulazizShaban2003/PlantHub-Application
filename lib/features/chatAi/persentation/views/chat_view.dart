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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig().height(0.03)),
              const CustomAppBarView(),
              const Expanded(child: MessagesList()),
              const MessageInput(),
            ],
          ),
        ),
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
      itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.isLoading && index == provider.messages.length) {
          return StreamBuilder<String>(
            stream: provider.botResponseController?.stream,
            builder: (context, snapshot) {
              final text = snapshot.data ?? '';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Messages(
                  isUser: false,
                  message: text,
                  date: DateFormat('HH:mm').format(DateTime.now()),
                ),
              );
            },
          );
        }
        final message = provider.messages[index];
        return Messages(
          isUser: message.isUser,
          message: message.message,
          image: message.image,
          date: DateFormat('HH:mm').format(message.date),
          isTyping: message.isTyping ?? false,
        );
      },
    );
  }
}

class MessageInput extends StatelessWidget {
  const MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    return Row(
      children: [
        PopupMenuButton<ImageSource>(
          icon: const Icon(Icons.add_a_photo),
          onSelected: (source) => provider.pickImage(source),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: ImageSource.camera,
              child: Text('Camera'),
            ),
            const PopupMenuItem(
              value: ImageSource.gallery,
              child: Text('Gallery'),
            ),
          ],
        ),
        Expanded(
          child: TextFormField(
            onFieldSubmitted: (v) => provider.sendMessage(),
            style: const TextStyle(fontSize: 10),
            controller: provider.userMessage,
            decoration: const InputDecoration(hintText: "اسألني..."),
          ),
        ),
        IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              ColorsManager.greenPrimaryColor,
            ),
          ),
          icon: const Image(
            image: AssetImage('assets/images/send-2.png'),
            width: 20,
            height: 20,
          ),
          onPressed: () => provider.sendMessage(),
        ),
        IconButton(
          icon: Icon(
            provider.isListening ? Icons.mic : Icons.mic_off,
            color: provider.isListening ? Colors.red : Colors.black,
          ),
          onPressed: () async {
            if (provider.isListening) {
              await provider.stopListening();
            } else {
              await provider.startListening();
            }
          },
        ),
      ],
    );
  }
}