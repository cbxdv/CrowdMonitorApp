import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_monitor/screens/camera_screen.dart';
import 'package:crowd_monitor/screens/upload_preview_screen.dart';
import 'package:crowd_monitor/widgets/custom_appbar.dart';
import 'package:crowd_monitor/widgets/error_dialog.dart';
import 'package:crowd_monitor/widgets/new_person_sheet.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonSelectScreen extends StatefulWidget {
  const PersonSelectScreen({Key? key}) : super(key: key);

  @override
  State<PersonSelectScreen> createState() => _PersonSelectScreenState();
}

class _PersonSelectScreenState extends State<PersonSelectScreen> {
  List<Map> peopleData = [];
  bool isLoading = true;

  Future<List<Map>> _getData() async {
    try {
      final res =
          await FirebaseFirestore.instance.collection('availablePeople').get();
      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
    return [];
  }

  void fetchData() async {
    final data = await _getData();
    setState(() {
      peopleData = data;
      isLoading = false;
    });
  }

  goToCameraScreen(cameras, personData) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            CameraScreen(cameras: cameras, personData: personData),
      ),
    );
  }

  goToPreviewScreen(filePath, personData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => UploadPreviewScreen(
          imagePath: filePath,
          personData: personData,
        ),
      ),
    );
  }

  personSelectHandler(Map personData) async {
    // 1 -> Image from camera
    // 0 -> Image from gallery

    final selectedOption = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: const Text('Capture new image'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: const Text('Select from gallery'),
            ),
          ],
        ),
      ),
    );

    if (selectedOption == 0) {
      ImagePicker picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      goToPreviewScreen(file.path, personData);
    } else if (selectedOption == 1) {
      if (kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        late List<CameraDescription> cameras;
        cameras = await availableCameras();
        goToCameraScreen(cameras, personData);
      } else {
        ImagePicker picker = ImagePicker();
        final file = await picker.pickImage(source: ImageSource.camera);
        if (file == null) return;
        goToPreviewScreen(file.path, personData);
      }
    }
  }

  Widget getListTile(personData) {
    const defaultImagePath =
        'https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg';

    Future<Image> getImage(imagePath) async {
      if (imagePath == null || imagePath.isEmpty) {
        return Image.network(defaultImagePath);
      } else {
        final data = await FirebaseStorage.instance.ref(imagePath).getData();
        if (data == null) return Image.network(defaultImagePath);
        return Image.memory(data);
      }
    }

    return ListTile(
      onTap: () {
        personSelectHandler(personData);
      },
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: FutureBuilder(
          future: getImage(personData['latestImage'].toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.active) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 0.9,
                ),
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return Image.network(defaultImagePath);
            }
            return data;
          },
        ),
      ),
      title: Text(personData['name']),
    );
  }

  addNewHandler() async {
    final personData = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const NewPersonSheet();
      },
    );
    if (personData == null) return;
    setState(() {
      peopleData.add(personData);
    });
    personSelectHandler(personData);
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getCustomAppBar(
        context: context,
        title: 'Select the person',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewHandler,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : peopleData.isEmpty
              ? const Center(child: Text('No data found'))
              : ListView.builder(
                  itemCount: peopleData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return getListTile(peopleData[index]);
                  },
                ),
    );
  }
}
