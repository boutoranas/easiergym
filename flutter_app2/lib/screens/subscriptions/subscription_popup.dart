import 'package:flutter/material.dart';
import 'package:flutter_app/screens/subscriptions/subscription_main.dart';
import 'package:flutter_app/services/custom_icons.dart';
import 'package:flutter_app/widgets/button.dart';

showsubscriptionPopUp(BuildContext context, String privilege) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Switch to Premium'),
        content:
            const Text('Get multiple privileges with premium including ...'),
        actions: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: button(
                  context: context,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubscriptionMain()));
                  },
                  height: 45,
                  text: '  Get premium',
                  color: const Color.fromARGB(255, 230, 195, 0),
                  icon: CustomIcons.premium,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          /* TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscriptionMain()));
            },
            child: Text(
              'Get premium',
              style: TextStyle(
                color: Color.fromARGB(255, 230, 195, 0),
              ),
            ),
          ), */
        ],
      );
    },
  );
}
