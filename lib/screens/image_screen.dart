import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen(
      {Key? key,
      required this.image,
      required this.imageData,
      required this.deleteHandler})
      : super(key: key);

  final Uint8List image;
  final Map imageData;
  final Function deleteHandler;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  bool isShowingTopBar = true;
  bool isShowingBox = false;
  bool isLoading = false;

  topBarHandler() {
    setState(() {
      isShowingTopBar = !isShowingTopBar;
    });
  }

  boxSwitchHandler(bool newValue) {
    setState(() {
      isShowingBox = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onTap: topBarHandler,
              child: InteractiveViewer(
                panEnabled: true,
                child: Center(
                  child: Image.memory(
                    widget.image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isShowingTopBar ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.white.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Tooltip(
                            message: 'Show faces',
                            child: Switch(
                              value: isShowingBox,
                              onChanged: boxSwitchHandler,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      color: Colors.white.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return getDetailsSheet(
                                        context, widget.imageData);
                                  },
                                );
                              },
                              icon: const Icon(Icons.info),
                            ),
                            IconButton(
                              onPressed: () {
                                widget.deleteHandler(widget.imageData);
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

getDetailsSheet(context, imageData) {
  final uploaded = DateFormat('EEEE, MMMM d yyyy, h:mm a')
      .format(DateTime.parse(imageData['uploaded']));
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.center,
          child: Text(
            'Details',
            style: TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Name'),
          subtitle: Text(imageData['name']),
        ),
        ListTile(
          title: const Text('Uploaded'),
          subtitle: Text(uploaded),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
