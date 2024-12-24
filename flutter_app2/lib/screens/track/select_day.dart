import 'package:flutter/material.dart';
import 'package:flutter_app/services/date%20formater.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../widgets/custom appbar.dart';

class SelectTrackingDay extends StatefulWidget {
  final DateTime initialDay;
  final Function navigateToDay;
  const SelectTrackingDay(
      {super.key, required this.initialDay, required this.navigateToDay});

  @override
  State<SelectTrackingDay> createState() => _SelectTrackingDayState();
}

class _SelectTrackingDayState extends State<SelectTrackingDay> {
  @override
  Widget build(BuildContext context) {
    int firstDayOfTheWeek = 1;

    int _month = widget.initialDay.month, _year = widget.initialDay.year;

    ValueNotifier<String> viewMonth =
        ValueNotifier('${widget.initialDay.month} ${widget.initialDay.year}');

    void viewChanged(ViewChangedDetails viewChangedDetails) {
      _month = (viewChangedDetails
              .visibleDates[viewChangedDetails.visibleDates.length ~/ 2])
          .month;
      _year = (viewChangedDetails
              .visibleDates[viewChangedDetails.visibleDates.length ~/ 2])
          .year;
      viewMonth.value = '${_month} ${_year}';
    }

    return Scaffold(
      appBar: customAppBar(
        title: 'Select day',
        context: context,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ValueListenableBuilder(
              valueListenable: viewMonth,
              builder: (context, value, child) {
                return SfCalendar(
                  minDate: DateTime.parse('2000-01-01'),
                  maxDate: DateTime.parse('2100-01-01'),
                  showNavigationArrow: true,
                  view: CalendarView.month,
                  initialDisplayDate: widget.initialDay,
                  initialSelectedDate: widget.initialDay,
                  onTap: (calendarTapDetails) {
                    Navigator.pop(context);
                    DateTime now = calendarTapDetails.date!;
                    int day = DateTime.utc(now.year, now.month, now.day)
                        .difference(DateTime.utc(2000, 1, 1))
                        .inDays;
                    widget.navigateToDay(day);
                  },
                  viewNavigationMode: ViewNavigationMode.none,
                  firstDayOfWeek: firstDayOfTheWeek,
                  headerHeight: 50,
                  headerStyle: const CalendarHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                      )),
                  selectionDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 6)),
                  onViewChanged: viewChanged,
                  monthCellBuilder: (context, details) {
                    Color? color;
                    if (DateFormater.dayDate(details.date).month ==
                        int.parse(viewMonth.value.split(' ').first)) {
                      if (DateFormater.dayDate(details.date) ==
                          DateTime.utc(2023, 6, 29)) {
                        color = Colors.green;
                      }
                      if (DateFormater.dayDate(details.date) ==
                          DateTime.utc(2023, 7, 17)) {
                        color = Colors.green;
                      }
                      if (DateFormater.dayDate(details.date) ==
                          DateTime.utc(2023, 7, 16)) {
                        color = Colors.red;
                      }
                    }
                    return Container(
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            DateFormater.dayDate(details.date).month == _month
                                ? Border.all(width: 1, color: Colors.grey)
                                : null,
                        color: color,
                      ),
                      child: Center(
                        child: Text(
                          '${DateFormater.dayDate(details.date).day}',
                          style: DateFormater.dayDate(details.date) ==
                                  DateFormater.dayDate(DateTime.now())
                              ? TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )
                              : DateFormater.dayDate(details.date).month !=
                                      _month
                                  ? TextStyle(
                                      color: Color.fromARGB(255, 158, 158, 158),
                                    )
                                  : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1/31',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Text('Accomplished'),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Text('Day streak'),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
