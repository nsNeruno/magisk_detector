library magisk_detector;

import 'package:magisk_detector/src/detectors.dart';

import 'src/models.dart';

class MagiskDetector extends AndroidOnlyRuntime {

  Future<bool> detectMagisk() => Future.wait(
    [
      SuperUserDetector().check(),
      MountPathDetector().check(),
    ],
  ).then(
    (checkResults,) => checkResults.contains(true,),
  );
}