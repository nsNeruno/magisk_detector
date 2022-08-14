library magisk_detector;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magisk_detector/src/platform.dart';

import 'src/models.dart';

/// TODO: Documentations
abstract class MagiskDetector extends AndroidOnlyRuntime {

  Future<bool> detectMagisk();

  @protected
  @visibleForTesting
  Future<bool> haveSu();

  @protected
  @visibleForTesting
  Future<bool> haveMagicMount();

  @protected
  @visibleForTesting
  Future<bool> haveMagiskHide();

  bool isAppHacked() => false;

  static late final MagiskDetector instance = MagiskDetectorPlatform();
}