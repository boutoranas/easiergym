import 'package:flutter/material.dart';

class SubscriptionMain extends StatefulWidget {
  const SubscriptionMain({super.key});

  @override
  State<SubscriptionMain> createState() => _SubscriptionMainState();
}

class _SubscriptionMainState extends State<SubscriptionMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscriptions',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        shape: const Border(bottom: BorderSide(width: 1, color: Colors.black)),
      ),
      body: const Column(
        children: [],
      ),
    );
  }
}
