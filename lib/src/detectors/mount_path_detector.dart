import 'dart:io';

import 'package:magisk_detector/src/models/android_only_runtime.dart';

class MountPathDetector extends AndroidOnlyRuntime {

  Future<bool> check() async {
    final entries = await File("/proc/self/mounts",).readAsLines();
    for (var entry in entries) {
      if (_blackListedPaths.any((path) => entry.contains(path,),)) {
        return true;
      }
    }
    return false;
  }

  final _blackListedPaths = [
    "magisk",
    "core/mirror",
    "core/img",
  ];
}