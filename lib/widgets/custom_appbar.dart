import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

AppBar getCustomAppBar({
  required BuildContext context,
  String title = 'Face Detector',
  bool autoLeading = true,
}) {
  goToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  return AppBar(
    title: Text(title),
    actions: [
      IconButton(
        tooltip: 'Sign Out',
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          goToHome();
        },
        icon: const Icon(Icons.logout),
      ),
    ],
    automaticallyImplyLeading: autoLeading,
  );
}
