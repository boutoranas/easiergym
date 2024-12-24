import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../main.dart';
import '../../services/date formater.dart';
import '../../widgets/resume workout bar.dart';
import 'local widgets/history log card.dart';

class HistorySection extends StatefulWidget {
  const HistorySection({
    super.key,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> with RouteAware {
  ScrollController scrollController = ScrollController();

  Map? userDataMap = DataGestion.userDataMap;
  late List logsList = DataGestion.logsList(userDataMap);

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  void updateState(function) {
    if (function == "Delete") {
      setState(() {});
    }
    if (function == "Save as Routine") {
      Navigator.pop(context);
    }
  }

  late List months = [];
  late List weeks = [];
  @override
  void initState() {
    getMonths();

    super.initState();
  }

  getMonths() {
    //months
    months.clear();
    if (userDataMap != null && userDataMap!["logs"] != null) {
      userDataMap!["logs"].forEach((k, v) {
        String month = DateTime.fromMillisecondsSinceEpoch(v["tdate"])
            .month
            .toString()
            .padLeft(2, '0');
        String year =
            DateTime.fromMillisecondsSinceEpoch(v["tdate"]).year.toString();
        if (!months.contains("$year${month}01")) {
          months.add("$year${month}01");
        }
      });
    }
    months.sort((a, b) => b.compareTo(a));
  }

  String getMonth(month) {
    DateTime date = DateTime.parse(month);
    if (date.year == DateTime.now().year) {
      return "${DateFormater.month(date)}";
    } else {
      return "${DateFormater.month(date)} ${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    userDataMap = DataGestion.userDataMap;
    logsList = DataGestion.logsList(userDataMap);
    getMonths();
    return Scaffold(
      appBar: customAppBar(
          title: 'History', leading: null, actions: null, context: context),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.only(bottom: 10)),
          Expanded(
            flex: 100,
            child: months.isNotEmpty
                ? FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: months.length,
                        itemBuilder: ((context, index) {
                          List monthsLogs = [];
                          for (var element in logsList) {
                            String month = DateTime.fromMillisecondsSinceEpoch(
                                    element["tdate"])
                                .month
                                .toString()
                                .padLeft(2, '0');
                            String year = DateTime.fromMillisecondsSinceEpoch(
                                    element["tdate"])
                                .year
                                .toString();
                            if (months[index] == "$year${month}01") {
                              monthsLogs.add(element);
                            }
                          }
                          monthsLogs
                              .sort((a, b) => b["tdate"].compareTo(a["tdate"]));
                          return ListTile(
                            title: Text(
                              "${getMonth(months[index])} (${monthsLogs.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: monthsLogs.length,
                              itemBuilder: ((context, i) {
                                return HistoryLogCard(
                                  updateState: updateState,
                                  id: monthsLogs[i]["id"],
                                  name: monthsLogs[i]["name"],
                                  time: monthsLogs[i]["tdate"],
                                );
                              }),
                            ),
                          );
                        })),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text("No routines performed"),
                  ),
          ),
        ],
      ),
    );
  }
}
