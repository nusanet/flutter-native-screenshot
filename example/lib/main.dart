import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_screenshot/flutter_native_screenshot.dart';

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
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Flutter Native Screenshot'),
          ),
          bottomNavigationBar: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text('Press to capture screenshot'),
                onPressed: () async {
                  _doTakeScreenshot();
                },
              )
            ],
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            child: _imgHolder,
          ),
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
