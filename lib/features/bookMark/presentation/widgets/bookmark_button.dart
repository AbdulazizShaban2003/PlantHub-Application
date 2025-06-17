import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../data/datasource/bookmark_service.dart';

class BookmarkButton extends StatelessWidget {
  final String itemId;
  final double? size;

  const BookmarkButton({
    super.key,
    required this.itemId,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<BookmarkService>(context, listen: false);
    final iconSize = size ?? SizeConfig().responsiveFont(24);

    return StreamBuilder<bool>(
      stream: service.getBookmarkStatusStream(itemId),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return IconButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.zero, 
          icon: isLoading
              ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: SizeConfig().width(0.005),
              color: ColorsManager.greenPrimaryColor,
            ),
          )
              : Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? ColorsManager.greenPrimaryColor : Theme.of(context).scaffoldBackgroundColor,
            size: iconSize,
          ),
          onPressed: isLoading ? null : () => _toggleBookmark(context, service, isBookmarked),
          splashRadius: iconSize * 0.6,
        );
      },
    );
  }

  Future<void> _toggleBookmark(
      BuildContext context,
      BookmarkService service,
      bool isCurrentlyBookmarked
      ) async {
    try {
      if (isCurrentlyBookmarked) {
        await service.removeBookmark(itemId);
        if (context.mounted) {
          FlushbarHelper.createSuccess(
            message: AppStrings.removedFromBookmarks,
            duration: Duration(seconds: 2),
          ).show(context);
        }
      } else {
        await service.addBookmark(itemId);
        if (context.mounted) {
          FlushbarHelper.createSuccess(
            message: AppStrings.addedToBookmarks,
            duration: Duration(seconds: 2),
          ).show(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.createError(
          message: isCurrentlyBookmarked
              ? AppStrings.removeBookmarkFailed
              : AppStrings.addBookmarkFailed,
          duration: Duration(seconds: 2),
        ).show(context);
      }
    }
  }
}