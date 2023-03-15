import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:crowd_monitor/utilities/firestore_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';

Future<void> uploadImage(String imagePath, Map personData) async {
  final email = FirebaseAuth.instance.currentUser?.email ?? '';
  final personId = personData['id'];
  final personName = personData['name'];
  final now = DateTime.now().toIso8601String();

  final newName = '${email}_${now.toString()}.jpg';
  final newPath = 'images/$personId/$newName';

  Uint8List imageData = await XFile(imagePath).readAsBytes();
  final metadata = SettableMetadata(contentType: 'image/jpg');
  final uploadTask =
      FirebaseStorageWeb(bucket: 'gs://crowd-monitor-4ac40.appspot.com')
          .ref('')
          .child(newPath)
          .putData(imageData, metadata);
  await uploadTask.onComplete;
  await addImageEntry(
      {'uploaded': now, 'path': newPath, 'name': personName, 'id': personId});
}
