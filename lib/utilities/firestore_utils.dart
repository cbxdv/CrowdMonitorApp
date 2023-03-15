import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addNewUserUploadEntry(String email) async {
  await FirebaseFirestore.instance
      .collection('uploads')
      .doc(email)
      .set({'id': email, 'images': []});
}

Future<Map> addNewPerson(String name) async {
  final firestore_ = FirebaseFirestore.instance;
  // Getting a new random ID from FirebaseFirestore
  final personId = firestore_.collection('availablePeople').doc().id.toString();
  final Map<String, dynamic> newData = {
    'id': personId,
    'name': name,
  };
  await firestore_.collection('availablePeople').doc(personId).set(newData);
  return newData;
}

Future<void> addImageEntry(Map imageData) async {
  final firestore_ = FirebaseFirestore.instance;
  final email = FirebaseAuth.instance.currentUser!.email;
  final personId = imageData['id'];
  if (email == null || email.isEmpty) return;
  await firestore_.collection('uploads').doc(email).update({
    'images': FieldValue.arrayUnion([imageData])
  });
  await firestore_
      .collection('availablePeople')
      .doc(personId)
      .update({'latestImage': imageData['path']});
}
