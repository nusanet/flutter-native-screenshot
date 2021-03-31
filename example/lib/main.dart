import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_screenshot/flutter_native_screenshot.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _imgHolder;

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
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('NativeScreenshot Example'),
        ),
        bottomNavigationBar: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Press to capture screenshot'),
              onPressed: () async {
                String path = await FlutterNativeScreenshot.takeScreenshot();
                debugPrint('Screenshot taken, path: $path');

                if (path == null || path.isEmpty) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Error taking the screenshot :('),
                    backgroundColor: Colors.red,
                  )); // showSnackBar()

                  return;
                } // if error

                _scaffoldKey.currentState
                    .showSnackBar(SnackBar(content: Text('The screenshot has been saved to: $path'))); // showSnackBar()

                File imgFile = File(path);
                _imgHolder = Image.file(imgFile);

                setState(() {});
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
} // _MyAppState
