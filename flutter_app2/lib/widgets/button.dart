import 'package:flutter/material.dart';

Widget button({
  required BuildContext context,
  double width = double.infinity,
  double height = 45,
  required Function? onPressed,
  Color? color,
  double elevation = 0,
  required String text,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        /* border: const Border(
          top: BorderSide(color: Colors.black, width: 1.5),
          bottom: BorderSide(color: Colors.black, width: 1.5),
          left: BorderSide(color: Colors.black, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
        ), */
      ),
      child: MaterialButton(
        minWidth: width,
        height: height,
        onPressed: onPressed != null
            ? () {
                onPressed();
              }
            : null,
        color: color ?? Theme.of(context).colorScheme.primary,
        //elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: icon == null
            ? Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.black),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      icon,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
