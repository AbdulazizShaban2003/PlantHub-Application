import 'dart:io';
import 'package:flutter/material.dart';

class ImageMessageDialog extends StatefulWidget {
  final File imageFile;
  final Function(String message) onSend;
  final VoidCallback onCancel;

  const ImageMessageDialog({
    super.key,
    required this.imageFile,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<ImageMessageDialog> createState() => _ImageMessageDialogState();
}

class _ImageMessageDialogState extends State<ImageMessageDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final messageText = _messageController.text.trim();
      widget.onSend(messageText);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error sending image message: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    widget.onCancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Image preview - smaller size
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 150, // Smaller preview
                  maxWidth: 150,
                ),
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text input field
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about the image or add a message...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff3AAE72)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
              minLines: 1,
              enabled: !_isSending,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 8),

            // Quick action buttons
            Wrap(
              spacing: 8,
              children: [
                _QuickActionChip(
                  label: 'What is this?',
                  onTap: () => _messageController.text = 'What is this?',
                ),
                _QuickActionChip(
                  label: 'Describe this image',
                  onTap: () => _messageController.text = 'Describe this image in detail',
                ),
                _QuickActionChip(
                  label: 'Analyze this',
                  onTap: () => _messageController.text = 'Analyze this image',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _isSending ? null : _handleCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSending ? null : _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3AAE72),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Send',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
