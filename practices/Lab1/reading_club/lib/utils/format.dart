import '../models/book.dart';

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatDateTime(DateTime date) =>
    '${formatDate(date)}, ${formatTime(date)}';

String formatCountdown(Countdown countdown) => switch (countdown) {
  Upcoming(:final duration) =>
    duration.inDays > 0
        ? 'In ${duration.inDays} days'
        : duration.inHours > 0
        ? 'In ${duration.inHours} hours'
        : 'In ${duration.inMinutes} minutes',
  Started() => 'Meeting in progress',
  Ended() => 'Meeting ended',
};
