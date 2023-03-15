import 'package:crowd_monitor/screens/gallery_screen.dart';
import 'package:crowd_monitor/screens/person_select_screen.dart';
import 'package:crowd_monitor/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isScreenWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: getCustomAppBar(context: context, title: 'Face Detector'),
      body: Center(
        widthFactor: 100,
        child: Flex(
          direction: isScreenWide ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            HomeScreenOption(title: 'Gallery', component: GalleryScreen()),
            HomeScreenOption(
                title: 'Upload Image', component: PersonSelectScreen())
          ],
        ),
      ),
    );
  }
}

class HomeScreenOption extends StatelessWidget {
  const HomeScreenOption(
      {Key? key, required this.title, required this.component})
      : super(key: key);

  final String title;
  final Widget component;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => component));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }
}
