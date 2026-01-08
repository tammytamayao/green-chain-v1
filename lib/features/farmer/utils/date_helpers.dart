String monthName(int month) {
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
  return months[month - 1];
}

String weekdayName(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}

String arrivalTextPlus3Days() {
  final arrival = DateTime.now().add(const Duration(days: 3));
  const time = '6:00 PM';
  return '${monthName(arrival.month)} ${arrival.day}, ${arrival.year} '
      'on ${weekdayName(arrival.weekday)} at $time';
}
