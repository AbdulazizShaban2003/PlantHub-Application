import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasource/bookmark_service.dart';

class BookmarkButton extends StatelessWidget {
  final String itemId;
  final double? size;

  const BookmarkButton({
    super.key,
    required this.itemId,
    this.size = 24,

  });

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<BookmarkService>(context, listen: false);
    return StreamBuilder<bool>(
      stream: service.getBookmarkStatusStream(itemId),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return IconButton(
          icon: isLoading
              ? SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amber,
            ),
          )
              : Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? Colors.amber : Theme.of(context).primaryColor,
            size: size,
          ),
          onPressed: isLoading ? null : () => _toggleBookmark(context, service, isBookmarked),
          splashRadius: size,
        );
      },
    );
  }

  Future<void> _toggleBookmark(BuildContext context, BookmarkService service, bool isCurrentlyBookmarked) async {
    try {
      if (isCurrentlyBookmarked) {
        await service.removeBookmark(itemId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إزالة من المفضلة'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await service.addBookmark(itemId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت الإضافة إلى المفضلة'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyBookmarked
                ? 'فشل في إزالة من المفضلة'
                : 'فشل في الإضافة إلى المفضلة'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      debugPrint('Error toggling bookmark: $e');
    }
  }
}
