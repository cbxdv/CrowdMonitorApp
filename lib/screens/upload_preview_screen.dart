import 'dart:io';

import 'package:crowd_monitor/utilities/storage_native_utils.dart'
    if (dart.library.io) 'package:crowd_monitor/utilities/storage_native_utils.dart'
    if (dart.library.html) 'package:crowd_monitor/utilities/storage_web_utils.dart';
import 'package:crowd_monitor/widgets/custom_appbar.dart';
import 'package:crowd_monitor/widgets/loading_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UploadPreviewScreen extends StatefulWidget {
  const UploadPreviewScreen(
      {Key? key, required this.imagePath, required this.personData})
      : super(key: key);

  final String imagePath;
  final Map personData;

  @override
  State<UploadPreviewScreen> createState() => _UploadPreviewScreenState();
}

class _UploadPreviewScreenState extends State<UploadPreviewScreen> {
  bool uploaded = false;

  saveToCloud(context) async {
    loadingDialog(context: context, text: 'Uploading');
    try {
      await uploadImage(widget.imagePath, widget.personData);
      Navigator.pop(context);
      setState(() {
        uploaded = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Successfully Uploaded'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
      setState(() {
        uploaded = true;
      });
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getCustomAppBar(
          context: context, title: 'Upload Image', autoLeading: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: kIsWeb
                      ? Image.network(widget.imagePath, fit: BoxFit.cover)
                      : Image.file(File(widget.imagePath), fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.personData['name'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: uploaded
                      ? null
                      : () {
                          saveToCloud(context);
                        },
                  child: const Text('Upload'),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    },
                    child: const Text('Back to Home'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
