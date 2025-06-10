import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../manager/chat_provider.dart';

void showClearDialog(BuildContext context, ChatProvider provider) {
  showDialog(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: AlertDialog(
        title:  Text('Clear All Messages 📌' ,style: Theme.of(context).textTheme.bodyMedium),
        content:  Text('Are you sure you want to delete all messages? This action cannot be undone.',style: Theme.of(context).textTheme.titleSmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          SizedBox(height: SizeConfig().height(0.02),),
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
    ),
  );
}
