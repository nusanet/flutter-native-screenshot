# flutter_native_screenshot

A Flutter plugin to take screenshot on Android & iOS. This plugin also saved screenshot as image and return a path.

## Instalation

Add

```
flutter_native_screenshot: ^<latest_version>
```

to your `pubspec.yaml` file.

### Android
You must add

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

to your `AndroidManifest.xml` inside `android/src/main/` directory.

Also you need to add a property to `application` tag to fix an issue with permissions writing to `EXTERNAL_STORAGE`:

```
android:requestLegacyExternalStorage="true"
```

### iOS
If don't add

```
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Take pretty screenshots and save it to the PhotoLibrary.</string>
```

to your `info.plist` file inside `ios/Runner` directory, the application will crash.

## Use

Import the library:

```
import 'package:flutter_native_screenshot/flutter_native_screenshot.dart';
```

and take a screenshot:

```
String path = await FlutterNativeScreenshot.takeScreenshot()
```

In error case the function returns `null` and the screenshot path if success.