import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      dismissDirection: DismissDirection.endToStart,
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.primary,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  )
      /* .closed
      .then((value) => ScaffoldMessenger.of(context).removeCurrentSnackBar()) */
      ;
}
