import 'package:camera/camera.dart';
import 'package:crowd_monitor/screens/upload_preview_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.cameras,
    required this.personData,
  });
  final List<CameraDescription> cameras;
  final Map personData;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int cameraIndex = 0;

  initializeCamera(newCameraIndex) {
    _controller = CameraController(
      widget.cameras[newCameraIndex],
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  capture(context) async {
    try {
      final XFile file = await _controller.takePicture();
      final imagePath = file.path;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadPreviewScreen(
              imagePath: imagePath, personData: widget.personData),
        ),
      );
    } catch (e) {
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
  void initState() {
    initializeCamera(cameraIndex);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 500, child: CameraPreview(_controller)),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          widget.personData['name'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (widget.cameras.length > 1) {
                                  initializeCamera(cameraIndex);
                                  setState(() {
                                    cameraIndex = cameraIndex == 1 ? 0 : 1;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No other cameras found'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.cameraswitch,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                capture(context);
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              iconSize: 45,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
