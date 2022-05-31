import 'dart:io';

import 'package:magisk_detector/src/models/android_only_runtime.dart';

class SuperUserDetector extends AndroidOnlyRuntime {

  Future<bool> check() {
    return Future.wait(
      _suPaths.map(
        (path) => File(path,).exists(),
      ),
    ).then(
      (checkResults) => checkResults.contains(true,),
    );
  }

  final _suPaths = [
    "/data/local/su",
    "/data/local/bin/su",
    "/data/local/xbin/su",
    "/sbin/su",
    "/su/bin/su",
    "/system/bin/su",
    "/system/bin/.ext/su",
    "/system/bin/failsafe/su",
    "/system/sd/xbin/su",
    "/system/usr/we-need-root/su",
    "/system/xbin/su",
    "/cache/su",
    "/data/su",
    "/dev/su",
  ];
}