import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_screenshot/flutter_native_screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _imgHolder;

  @override
  void initState() {
    super.initState();
    _imgHolder = Center(
      child: Icon(Icons.image),
    );
  } // initState()

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Native Screenshot'),
        ),
        bottomNavigationBar: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Press to capture screenshot'),
              onPressed: () async {
                Map<Permission, PermissionStatus> resultPermission = await [
                  Permission.storage,
                  Permission.photos,
                ].request();
                final resultPermissionStorage = resultPermission[Permission.storage];
                final resultPermissionPhotos = resultPermission[Permission.photos];
                if (resultPermissionStorage == PermissionStatus.granted &&
                    resultPermissionPhotos == PermissionStatus.granted) {
                  _doTakeScreenshot();
                  return;
                } else {
                  _showSnackBar('Permission not granted');
                }
              },
            )
          ],
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: _imgHolder,
        ),
      ),
    );
  } // build()

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _doTakeScreenshot() async {
    String? path = await FlutterNativeScreenshot.takeScreenshot();
    debugPrint('Screenshot taken, path: $path');
    if (path == null || path.isEmpty) {
      _showSnackBar('Error taking the screenshot :(');
      return;
    } // if error
    _showSnackBar('The screenshot has been saved to: $path');
    File imgFile = File(path);
    _imgHolder = Image.file(imgFile);
    setState(() {});
  }
} // _MyAppState
