# magisk_detector

Magisk Detector for Android in Pure Dart. Based from [DetectMagiskHide](https://github.com/darvincisec/DetectMagiskHide).

## Features

This is a straight adaptation attempt at reproducing the logics from the original creator repository.  
Currently this repository doesn't adapt the native C++ approach.  
Available checks:
- General SuperUser check (common root check)
- Blacklisted mount path check from `/proc/self/mounts`

## Getting started
Add to your project via `pubspec.yaml`
```yaml
magisk_detector:
  git:
    url: https://github.com/nsNeruno/magisk_detector.git
```

## Usage

You can use it straight away by importing it first.
```dart
import 'package:magisk_detector/magisk_detector.dart';
``` 

Straightforward usage.
```dart
MagiskDetector().detectMagisk().then(
  (isMagiskFound) {
    /// Do something  
  },
);
final isMagickFound = await MagiskDetector().detectMagisk();
if (isMagiskFound) {
  /// Do something
}
```

## Additional information

Further references and tests are required. Feel free to raise an [issue](https://github.com/nsNeruno/magisk_detector/issues).
