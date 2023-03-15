import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_monitor/screens/image_screen.dart';
import 'package:crowd_monitor/widgets/custom_appbar.dart';
import 'package:crowd_monitor/widgets/error_dialog.dart';
import 'package:crowd_monitor/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool isLoading = true;
  List imagesList = [];

  getImagesList() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await FirebaseFirestore.instance
          .collection('uploads')
          .doc(user.email)
          .get();

      final data = res.data();
      if (data == null) return;

      final images = data['images'];
      if (images == null) return;

      setState(() {
        imagesList = images;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog(context, e.toString());
    }
  }

  deleteHandler(imageData) async {
    Navigator.pop(context);
    loadingDialog(context: context, text: 'Deleting');

    final imagePath = imageData['path'];
    final email = FirebaseAuth.instance.currentUser!.email;
    final personId = imageData['id'];

    if (email == null || imagePath == null) {
      Navigator.pop(context);
      return;
    }

    // Deleting the image
    await FirebaseStorage.instance.ref(imagePath).delete();

    // Deleting the entry from uploads
    FirebaseFirestore.instance.collection('uploads').doc(email).update({
      'images': FieldValue.arrayRemove([imageData])
    });

    //// Updating the latest image entry ////

    // Getting the path from the server
    final nameData = await FirebaseFirestore.instance
        .collection('availablePeople')
        .doc(personId)
        .get();
    final pathInServer = nameData.get('latestImage');
    // Checking whether the path matches the path deleted
    if (pathInServer == imageData['path']) {
      String newPath = '';
      final uploadsData = await FirebaseFirestore.instance
          .collection('uploads')
          .doc(email)
          .get();
      // Getting new imagePath from the uploaded list
      final images = uploadsData.get('images');
      if (images == null || (images as List).isEmpty) {
        newPath = '';
      } else {
        newPath = images.last['path'] as String;
      }
      // Updating the latest image field with new path
      await FirebaseFirestore.instance
          .collection('availablePeople')
          .doc(personId)
          .update({'latestImage': newPath});
    }
    Navigator.pop(context);
    getImagesList();
  }

  @override
  void initState() {
    getImagesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getCustomAppBar(context: context, title: 'Gallery'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imagesList.isEmpty
              ? const Center(
                  child: Text('No images uploaded'),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    crossAxisCount: 3,
                  ),
                  itemCount: imagesList.length,
                  itemBuilder: (context, index) {
                    return GridImage(
                        imageData: imagesList[index],
                        deleteHandler: deleteHandler);
                  },
                ),
    );
  }
}

class GridImage extends StatefulWidget {
  const GridImage(
      {Key? key, required this.imageData, required this.deleteHandler})
      : super(key: key);
  final Map imageData;
  final Function deleteHandler;

  @override
  State<GridImage> createState() => _GridImageState();
}

class _GridImageState extends State<GridImage> {
  late Uint8List image;
  bool isLoading = true;

  getImage() async {
    final data =
        await FirebaseStorage.instance.ref(widget.imageData['path']).getData();
    if (data == null) return;
    setState(() {
      image = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isLoading) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageScreen(
                image: image,
                imageData: widget.imageData,
                deleteHandler: widget.deleteHandler),
          ),
        );
      },
      child: Container(
        color: Colors.black12,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Image.memory(image),
        ),
      ),
    );
  }
}
