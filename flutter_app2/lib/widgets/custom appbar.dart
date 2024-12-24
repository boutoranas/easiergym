import 'package:flutter/material.dart';

import '../screens/subscriptions/subscription_main.dart';
import '../services/custom_icons.dart';

PreferredSizeWidget customAppBar({
  required String title,
  Widget? leading,
  List<Widget>? actions,
  required BuildContext context,
  Color? backgroundColor,
}) {
  //workout log not implementing this widget
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
      ),
    ),
    leading: leading,
    //elevation: 0,
    //shape: const Border(bottom: BorderSide(width: 1, color: Colors.black)),
    backgroundColor: backgroundColor,
    actions: actions != null
        ? [
            ...actions,
            SubscriptionIconButton(context),
            const SizedBox(
              width: 10,
            ),
          ]
        : [
            SubscriptionIconButton(context),
            const SizedBox(
              width: 10,
            ),
          ],
  );
}

Widget SubscriptionIconButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SubscriptionMain()));
    },
    icon: const Icon(
      CustomIcons.premium,
      color: Color.fromARGB(255, 230, 195, 0),
    ),
    tooltip: 'Premium',
    padding: const EdgeInsets.all(10),
    constraints: const BoxConstraints(),
  );
}
