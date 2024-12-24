import 'package:flutter/material.dart';

import '../view routine.dart';

class RoutineCardInExplore extends StatelessWidget {
  final Function navigateBackToWkSection;
  final Map routineMap;
  const RoutineCardInExplore(
      {super.key,
      required this.routineMap,
      required this.navigateBackToWkSection});

  stars(int i, BuildContext context) {
    Color starsColor = Theme.of(context).colorScheme.primary;
    List<Widget> difficulty = [];
    if (i == 0) {
      difficulty = [
        const Text("Level: "),
        Icon(
          Icons.star,
          color: starsColor,
        ),
        const Icon(
          Icons.star_border,
          color: Colors.grey,
        ),
        const Icon(
          Icons.star_border,
          color: Colors.grey,
        ),
      ];
    } else if (i == 1) {
      difficulty = [
        const Text("Level: "),
        Icon(
          Icons.star,
          color: starsColor,
        ),
        Icon(
          Icons.star,
          color: starsColor,
        ),
        const Icon(
          Icons.star_border,
          color: Colors.grey,
        )
      ];
    } else {
      difficulty = [
        const Text("Level: "),
        Icon(
          Icons.star,
          color: starsColor,
        ),
        Icon(
          Icons.star,
          color: starsColor,
        ),
        Icon(
          Icons.star,
          color: starsColor,
        )
      ];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: difficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewRoutine(
                        navigateBackToWkSection: navigateBackToWkSection,
                        routineMap: routineMap,
                      )));
        },
        child: Container(
          width: 158,
          height: 100,
          //color: Theme.of(context).cardColor,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Column(
              children: [
                Text(
                  routineMap["name"],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                stars(routineMap["difficulty"], context),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
