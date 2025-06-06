import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/datasource/bookmark_service.dart';

class BookmarkButton extends StatefulWidget {
  final String itemId;
  const BookmarkButton({super.key, required this.itemId});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool _isProcessing = false;
  bool _isBookmarked = false;
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final service = Provider.of<BookmarkService>(context, listen: false);
      final isBookmarked = await service.isItemBookmarked(widget.itemId);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
      debugPrint('Error checking bookmark status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Tooltip(
        message: 'Failed to load bookmark status',
        child: Icon(Icons.error, color: Colors.red, size: 20),
      );
    }

    return IconButton(
      icon: _isProcessing
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Icon(
        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: _isBookmarked ? Colors.amber : Colors.white,
        size: 20,
      ),
      onPressed: _isProcessing
          ? null
          : () async {
        setState(() => _isProcessing = true);
        try {
          final service = Provider.of<BookmarkService>(context, listen: false);
          if (_isBookmarked) {
            await service.removeBookmarkByItemId(widget.itemId);
          } else {
            await service.addBookmark(widget.itemId);
          }
          if (mounted) {
            setState(() => _isBookmarked = !_isBookmarked);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isBookmarked
                    ? 'Failed to remove bookmark'
                    : 'Failed to add bookmark'),
                backgroundColor: Colors.red,
              ),
            );
          }
          debugPrint('Error toggling bookmark: $e');
        } finally {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      },
    );
  }
}