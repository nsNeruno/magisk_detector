# magisk_detector

Flutter Support for integrating Magisk Detector for Android Application. Based from [MagiskDetector](https://github.com/vvb2060/MagiskDetector/).

## Features

This is a straight adaptation attempt at reproducing the logics from the original creator repository. Allows to perform a check on your Android device if it's currently using Magisk Root Bypassing module.

## Getting started
Add to your project via `pubspec.yaml`
```yaml
magisk_detector:
  git:
    url: https://github.com/nsNeruno/magisk_detector.git
```

## Usage
### Setup your Project
On your app's `build.gradle` file, add this line under `android` group, where you can see values like `compileSdkVersion`
```gradle
android {
    compileSdkVersion 30
    // You need to have this version installed on your SDK Manager
    ndkVersion '21.3.6528147'
    // ...
}
```
Then on your AndroidManifest.xml (under android/app/src/main/), add this inside the <application> tag:
```xml
<manifest ...>
    <application ...>
        <!-- Your application manifest data here -->
    
        <!-- Add this to connect to Magisk Detector Remote Service -->
        <service
           android:name="lab.neruno.magisk_detector.RemoteService"
           android:isolatedProcess="true"
           android:useAppZygote="true" />
    </application>
</manifest>
```

### Adding the Code
You can use it straight away by importing it first.
```dart
import 'package:magisk_detector/magisk_detector.dart';
```
### APIs
```dart
// Future-then pattern
MagiskDetector.instance.detectMagisk().then(
  (isMagiskFound) {
    /// Do something  
  },
);
// or the async-await pattern
final isMagiskFound = await MagiskDetector.instance.detectMagisk();
if (isMagiskFound) {
  /// Do something
}

// Additional APIs
// On some devices, you might encounter Exceptions where a restart 
// is asked by the Detector. Before calling the detect command,
// you may check is a RESTART is required

// Returns Future<bool>
MagiskDetector.instance.isRestartRequired();

// And if you opt out from strict restart check
MagiskDetector.instance.enforceRestartRequirement = false
```

## Known Issue
The restart requirement will most likely encounter problem starting on Android 11 and above, due to the crashes caused by EncryptedSharedPreference class provided by androidx.crypto dependency.  
Because of that, the Props Hash check section will defaults to passed status for now.

## Additional information

Further references and tests are required. Feel free to raise an [issue](https://github.com/nsNeruno/magisk_detector/issues).

And big thanks to [vvb2060](https://github.com/vvb2060) for showing the way.