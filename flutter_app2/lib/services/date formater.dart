class DateFormater {
  static List monthList = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  static List daysOfTheWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  static day(DateTime date) {
    int dayy = date.day;
    return dayy;
  }

  static dayOfTheWeek(DateTime date) {
    int dayOfTheWeekk = date.weekday;
    return daysOfTheWeek[dayOfTheWeekk - 1];
  }

  static month(DateTime date) {
    int monthh = date.month;
    return monthList[monthh - 1];
  }

  static year(DateTime date) {
    int yearr = date.year;
    if (DateTime.now().year == date.year) {
      return '';
    } else {
      return " $yearr";
    }
  }

  static hour(DateTime date) {
    int hourr = date.hour;
    return hourr;
  }

  static minute(DateTime date) {
    int minutee = date.minute;
    return minutee;
  }

  static DateTime dayDate(DateTime dateTime) {
    DateTime todayDate =
        DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    return todayDate;
  }

  static String dateToString(DateTime dateTime) {
    if (dayDate(dateTime) == dayDate(DateTime.now())) {
      return 'Today';
    } else if (dayDate(dateTime).difference(dayDate(DateTime.now())).inDays ==
        1) {
      return 'Tomorrow';
    } else if (dayDate(dateTime).difference(dayDate(DateTime.now())).inDays ==
        -1) {
      return 'Yesterday';
    } else {
      String weekDay = daysOfTheWeek[dateTime.weekday - 1];
      int day = dateTime.day;
      String month = monthList[dateTime.month - 1];
      String year = dateTime.year.toString();
      if (dateTime.year == DateTime.now().year) {
        return '$weekDay, $day $month';
      } else {
        return '$weekDay, $day $month $year';
      }
    }
  }
}

Duration parseDuration(String durationString) {
  List<String> components = durationString.split(':');

  int hours = int.parse(components[0]);
  int minutes = int.parse(components[1]);
  int seconds = double.parse(components[2]).floor();

  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}
