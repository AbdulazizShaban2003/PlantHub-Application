import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bookmark_service.dart';

class BookmarkButton extends StatefulWidget {
  final String itemId;

  const BookmarkButton({super.key, required this.itemId});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final bookmarkService = Provider.of<BookmarkService>(context);

    return StreamBuilder<bool>(
      stream: bookmarkService.isItemBookmarked(widget.itemId),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;

        return IconButton(
          icon: _isProcessing
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? Colors.amber : Colors.white,
            size: 20,
          ),
          onPressed: _isProcessing
              ? null
              : () async {
            setState(() => _isProcessing = true);
            try {
              if (isBookmarked) {
                await bookmarkService.removeBookmarkByItemId(widget.itemId);
              } else {
                await bookmarkService.addBookmark(widget.itemId);
              }
            } finally {
              if (mounted) {
                setState(() => _isProcessing = false);
              }
            }
          },
        );
      },
    );
  }
}