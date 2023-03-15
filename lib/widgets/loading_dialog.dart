import 'package:flutter/material.dart';

Future loadingDialog({required BuildContext context, String text = 'Loading'}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 30),
                Text(text),
              ],
            ),
          ),
        ),
      );
    },
  );
}
