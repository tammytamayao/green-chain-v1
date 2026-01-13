String niceNow() {
  final now = DateTime.now();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final h = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
  final ampm = now.hour >= 12 ? 'PM' : 'AM';
  final mm = now.minute.toString().padLeft(2, '0');
  return '${months[now.month - 1]} ${now.day}, ${now.year} | $h:$mm $ampm';
}
