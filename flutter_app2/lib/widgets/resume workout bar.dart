import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/timer.dart';

class ResumeWourkout extends StatelessWidget {
  const ResumeWourkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 8, 185, 230),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(12), topLeft: Radius.circular(12)),
        /* border: Border(
              top: BorderSide(
            width: 1,
            color: Colors.black,
          )) */
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(7.0),
          child: Column(
            children: [
              Text(
                "Resume workout",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Timerr(),
            ],
          ),
        ),
      ),
    );
  }
}
