import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/screens/stats/add%20measurement.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

class MeasurementsPage extends StatelessWidget {
  MeasurementsPage({super.key});

  ScrollController scrollController = ScrollController();

  List measurements = [
    ...["Body weight", "Body fat", "Calories"],
    ...InAppData.bodyPartsList
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: 'Measurements',
          leading: null,
          actions: null,
          context: context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: measurements.length,
                  itemBuilder: (context, i) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddMeasurement(
                                        measurement: measurements[i])));
                          },
                          title: Text(measurements[i]),
                          trailing: const Icon(Icons.add),
                        ),
                        const Divider(
                          height: 5,
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
