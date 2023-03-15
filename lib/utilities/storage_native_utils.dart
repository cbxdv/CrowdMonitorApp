import 'dart:io';

import 'package:crowd_monitor/utilities/firestore_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> uploadImage(String imagePath, Map personData) async {
  final email = FirebaseAuth.instance.currentUser?.email ?? '';
  final personId = personData['id'];
  final personName = personData['name'];
  final now = DateTime.now().toIso8601String();

  final newName = '${email}_$now.jpg';
  final newPath = 'images/$personId/$newName';

  final File file = File(imagePath);

  await FirebaseStorage.instance.ref().child(newPath).putFile(file);
  await addImageEntry(
      {'uploaded': now, 'path': newPath, 'name': personName, 'id': personId});
}
