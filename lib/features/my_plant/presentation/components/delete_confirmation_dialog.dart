import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String plantName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.plantName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Plant'),
      content: Text('Are you sure you want to delete $plantName?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}