class DateFormatter {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past date
      final pastDifference = now.difference(dateTime);
      if (pastDifference.inDays == 0) {
        return 'Today at ${formatTime(dateTime)}';
      } else if (pastDifference.inDays == 1) {
        return 'Yesterday at ${formatTime(dateTime)}';
      } else {
        return '${pastDifference.inDays} days ago at ${formatTime(dateTime)}';
      }
    } else {
      // Future date
      if (difference.inDays == 0) {
        return 'Today at ${formatTime(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Tomorrow at ${formatTime(dateTime)}';
      } else {
        return 'In ${difference.inDays} days at ${formatTime(dateTime)}';
      }
    }
  }

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}