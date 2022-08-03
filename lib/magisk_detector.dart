library magisk_detector;

import 'package:flutter/foundation.dart';
import 'package:magisk_detector/src/platform.dart';

import 'src/models.dart';

/// TODO: Documentations
abstract class MagiskDetector extends AndroidOnlyRuntime {

  Future<bool> detectMagisk();

  Future<bool> isRestartRequired();

  bool enforceRestartRequirement = true;

  @protected
  @visibleForTesting
  Future<bool> haveSu();

  @protected
  @visibleForTesting
  Future<bool> haveMagicMount();

  @protected
  @visibleForTesting
  Future<bool> haveMagiskDSocket();

  @protected
  @visibleForTesting
  Future<bool> isIoctlModified();

  @protected
  @visibleForTesting
  Future<bool> propsCheck();

  static late final MagiskDetector instance = MagiskDetectorPlatform();
}