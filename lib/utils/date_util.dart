var monthsNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "July",
  "Aug",
  "Sept",
  "Oct",
  "Nov",
  "Dec"
];

String getFormattedDate(int dueDate) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dueDate);
  return "${monthsNames[date.month - 1]}  ${date.day}";
}

String getFormattedTime(int dueDate) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dueDate);
  if (date.minute < 10) {
    return "${date.hour}: 0${date.minute}";
  }
  return "${date.hour}: ${date.minute}";
}
