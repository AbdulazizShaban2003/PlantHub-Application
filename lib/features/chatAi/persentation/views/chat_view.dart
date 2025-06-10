import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/size_config.dart' show SizeConfig;
import '../../../../core/widgets/appBar_view.dart';
import '../../manager/chat_provider.dart';
import '../widgets/chat_states_widget.dart';
import '../widgets/massage_input_widget.dart';
import '../widgets/message_list_widget.dart';

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
              SizedBox(height: SizeConfig().height(0.02)),
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




