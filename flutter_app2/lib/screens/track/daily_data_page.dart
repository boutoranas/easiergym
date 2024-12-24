import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_app/const.dart';

class DailyDataPage extends StatefulWidget {
  const DailyDataPage({super.key});

  @override
  State<DailyDataPage> createState() => _DailyDataPageState();
}

class _DailyDataPageState extends State<DailyDataPage> {
  TextStyle tilesStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17.5,
  );
  TextStyle displayNumbers = const TextStyle(
    fontWeight: FontWeight.w900,
  );

  bool moreDetails = false;

  double waterIntake = 0.0;

  List bodyParts = [
    "Right arm",
    "Left arm",
    "Left thigh",
    "Right thigh",
    "Left calf",
    "Right calf",
    "Hips",
    "Waist",
    "Chest",
    "Neck",
    "Penis"
  ];

  List mesurements = [32, 33, 53, 53, 38, 36, 71, 53, 80, 26, 34];

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return FadingEdgeScrollView.fromScrollView(
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Energy balance',
                            style: tilesStyle,
                          )),
                      PopupMenuButton(
                        onSelected: (value) {},
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit goal',
                              child: Text('Edit goal'),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Text('Share with firends'),
                            ),
                            const PopupMenuItem(
                              value: 'clear data',
                              child: Text('Clear today\'s data'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '3951',
                            style: displayNumbers,
                          ),
                          const Text('Consumed'),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRect(
                            clipBehavior: Clip.none,
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: 0.75,
                              child: Transform.rotate(
                                angle: 3 * math.pi / 2,
                                child: SizedBox(
                                  height: 95,
                                  width: 95,
                                  child: CircularCappedProgressIndicator(
                                    value: 0.5,
                                    color: Colors.grey[400],
                                    strokeWidth: 5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ClipRect(
                            clipBehavior: Clip.none,
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: 0.75,
                              child: Transform.rotate(
                                angle: 3 * math.pi / 2,
                                child: SizedBox(
                                  height: 95,
                                  width: 95,
                                  child: CircularCappedProgressIndicator(
                                    strokeWidth: 9,
                                    value: 0.4,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '512',
                                style: displayNumbers,
                              ),
                              const Text('Left')
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '315',
                            style: displayNumbers,
                          ),
                          const Text('Burned'),
                        ],
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 15)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: const Divider(
                height: 1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Const.horizontalPagePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Calorie intake',
                                style: tilesStyle,
                              )),
                          IconButton(
                              onPressed: () {}, icon: const Icon(Icons.edit))
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //Carbs
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircularCappedProgressIndicator(
                                      value: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircularCappedProgressIndicator(
                                      strokeWidth: 7,
                                      value: 312 / 468,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '312',
                                        style: displayNumbers,
                                      ),
                                      const Text('/468'),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 8)),
                              const Text('Carbs'),
                            ],
                          ),
                          //Protein
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircularCappedProgressIndicator(
                                      value: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircularCappedProgressIndicator(
                                      strokeWidth: 7,
                                      value: 128 / 156,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '128',
                                        style: displayNumbers,
                                      ),
                                      const Text('/156'),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 8)),
                              const Text('Protein'),
                            ],
                          ),
                          //fats
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircularCappedProgressIndicator(
                                      value: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircularCappedProgressIndicator(
                                      strokeWidth: 7,
                                      value: 67 / 114,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '67',
                                        style: displayNumbers,
                                      ),
                                      const Text('/114'),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 8)),
                              const Text('Fats'),
                            ],
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 10)),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text('More details'),
                          children: [
                            ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: const [
                                  ListTile(
                                    title: Text('Saturated fats'),
                                    trailing: Text('12 g'),
                                  ),
                                  ListTile(
                                    title: Text('Sugar'),
                                    trailing: Text('102 g'),
                                  ),
                                  ListTile(
                                    title: Text('Sodium'),
                                    trailing: Text('930 mg'),
                                  ),
                                  ListTile(
                                    title: Text('Fiber'),
                                    trailing: Text('53 g'),
                                  ),
                                ]),
                            const Text('Vitamins',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: const [
                                  ListTile(
                                    title: Text('Vitamin A'),
                                    trailing: Text('123 mg'),
                                  ),
                                  ListTile(
                                    title: Text('Vitamin B12'),
                                    trailing: Text('198 mg'),
                                  ),
                                  ListTile(
                                    title: Text('Vitamin B13'),
                                    trailing: Text('12 mg'),
                                  ),
                                  ListTile(
                                    title: Text('Vitamin C'),
                                    trailing: Text('269 mg'),
                                  ),
                                  ListTile(
                                    title: Text('Vitamin D'),
                                    trailing: Text('45 mg'),
                                  ),
                                  ListTile(
                                    title: Text('Vitamin K'),
                                    trailing: Text('8 mg'),
                                  ),
                                ]),
                            const Text('Minerals',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: const [
                                ListTile(
                                  title: Text('Magnesium'),
                                  trailing: Text('13 mg'),
                                ),
                                ListTile(
                                  title: Text('Calcium'),
                                  trailing: Text('45 mg'),
                                ),
                                ListTile(
                                  title: Text('Zinc'),
                                  trailing: Text('5 mg'),
                                ),
                                ListTile(
                                  title: Text('Iron'),
                                  trailing: Text('80 mg'),
                                ),
                                ListTile(
                                  title: Text('Iodine'),
                                  trailing: Text('2 mg'),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Const.horizontalPagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Meals:',
                            style: tilesStyle,
                          )),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: Const.horizontalPagePadding),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, i) {
                      List exampleMeals = [
                        "Morning Breakfast",
                        "Lunch",
                        "Snacks",
                        "Dinner",
                      ];
                      List<int> exampleCalories = [
                        780,
                        976,
                        542,
                        69,
                      ];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Theme.of(context).cardColor,
                        ),
                        width: 110,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                exampleMeals[i],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${exampleCalories[i].toString()} kcal',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 25)),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: const Divider(
                height: 1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: 15)),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Activities',
                        style: tilesStyle,
                      )),
                  const Padding(padding: EdgeInsets.only(bottom: 15)),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: 2,
            itemBuilder: (context, i) {
              List exampleActivities = [
                "running",
                "cycling",
              ];
              List caloriesBurned = [320, 156];
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Const.horizontalPagePadding),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: exampleActivities.length > 1
                        ? (i == exampleActivities.length - 1 || i == 0
                            ? BorderRadius.only(
                                topLeft: Radius.circular(i == 0 ? 15 : 0),
                                topRight: Radius.circular(i == 0 ? 15 : 0),
                                bottomLeft: Radius.circular(i != 0 ? 15 : 0),
                                bottomRight: Radius.circular(i != 0 ? 15 : 0),
                              )
                            : BorderRadius.circular(0))
                        : BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(exampleActivities[i]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${caloriesBurned[i]} kcal'),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: IconButton(
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(Icons.edit)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: TextButton(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  )),
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Add an activity'),
                      SizedBox(
                        width: 3,
                      ),
                      Icon(Icons.add),
                    ],
                  )),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: const Divider(
                height: 1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: EdgeInsets.only(bottom: 3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Water Intake',
                            style: tilesStyle,
                          )),
                      /* SizedBox(
                        height: 25,
                        width: 30,
                        child: IconButton(
                            padding: EdgeInsets.only(right: 10),
                            constraints: BoxConstraints(),
                            onPressed: () {},
                            icon: const Icon(Icons.edit)),
                      ) */
                      PopupMenuButton(
                        onSelected: (value) {},
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit goal',
                              child: Text('Edit goal'),
                            ),
                            const PopupMenuItem(
                              value: 'edit volume',
                              child: Text('Edit cup volume'),
                            ),
                            const PopupMenuItem(
                              value: 'reminders',
                              child: Text(
                                  0 == 1 ? 'Edit reminders' : 'Set reminders'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 3)),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              height: waterIntake / 1750 * 160,
                              color: Colors.blue,
                              duration: Duration(
                                milliseconds: 500,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(-0.8, 0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  waterIntake += 200;
                                  print(waterIntake);
                                });
                              },
                              child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 3,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 30,
                                      ),
                                      Text('200 ml',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  )),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(waterIntake / 1750 * 100).ceil()}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                    '${(waterIntake / 1000).toStringAsFixed(2)}/1.75 L')
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment(0.8, 0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  waterIntake -= 200;
                                  print(waterIntake);
                                });
                              },
                              child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 3,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.remove,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 30,
                                      ),
                                      Text('200 ml',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 25)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: const Divider(
                height: 1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: EdgeInsets.only(bottom: 15)),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add measurements',
                        style: tilesStyle,
                      )),
                  Padding(padding: EdgeInsets.only(bottom: 15)),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                    child: ListTile(
                      title: Text('Weight'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('87 kg'),
                          Padding(padding: EdgeInsets.only(right: 3)),
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    child: ListTile(
                      title: Text('Body fat'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('23 %'),
                          Padding(padding: EdgeInsets.only(right: 3)),
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    child: ListTile(
                      title: Text('Muscle mass'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('66 kg'),
                          Padding(padding: EdgeInsets.only(right: 3)),
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                    ),
                    child: ExpansionTile(
                        title: Text('Body parts'),
                        children: List.generate(
                          11,
                          (index) => ListTile(
                            title: Text(bodyParts[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${mesurements[index]} cm"),
                                Padding(padding: EdgeInsets.only(right: 3)),
                                SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: IconButton(
                                    padding: const EdgeInsets.all(0),
                                    constraints: const BoxConstraints(),
                                    onPressed: () {},
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 25)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
