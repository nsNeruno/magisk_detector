import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:magisk_detector/magisk_detector.dart';

class MagiskDetectorPlatform extends MagiskDetector {

  @override
  @protected
  @visibleForTesting
  Future<bool> haveSu() async {
    var haveSu = await _channel.invokeMethod("haveSu",);
    if (haveSu is int) {
      switch (haveSu) {
        case 0:
          return true;
        case -1:
          return false;
      }
    }
    throw PlatformException(
      code: _errorCode,
      message: "Unable to determine SU state",
      details: haveSu,
    );
  }

  @override
  @protected
  @visibleForTesting
  Future<bool> haveMagicMount() async {
    var magicMount = await _channel.invokeMethod("haveMagicMount",);
    if (magicMount is int) {
      switch (magicMount) {
        case 0:
          return false;
        case 1:
          return true;
      }
    }
    throw PlatformException(
      code: _errorCode,
      message: "Unexpected Magic Mount: $magicMount",
      details: magicMount,
    );
  }

  @override
  @protected
  @visibleForTesting
  Future<bool> haveMagiskDSocket() async {
    var dSocket = await _channel.invokeMethod("findMagiskdSocket",);
    if (dSocket is int) {
      switch (dSocket) {
        case 0:
          return false;
        case -1:
          throw PlatformException(
            code: _errorCode,
            message: "Unexpected/Unknown error",
          );
        case -2:
          assert(
            () {
              log(
                "SElinux is incorrect, can be ignored",
              );
              return true;
            }(),
          );
          return false;
        case -3:
          assert(
            () {
              log(
                "MagiskDSocket check is not supported on Android10+",
              );
              return true;
            }(),
          );
          return false;
        default: return true;
      }
    }
    throw PlatformException(
      code: _errorCode,
      message: "Undetermined socket check state",
      details: dSocket,
    );
  }

  @override
  @protected
  @visibleForTesting
  Future<bool> isIoctlModified() async {
    var ioctl = await _channel.invokeMethod("testIoctl",);
    if (ioctl is int) {
      switch (ioctl) {
        case 0:
          assert(
            () {
              log(
                "IOCTL Check Ignored. Operation not supported",
              );
              return true;
            }(),
          );
          return false;
        case 1:
          return false;
        case 2:
          return true;
      }
    }
    throw PlatformException(
      code: _errorCode,
      message: "Unexpected IOCTL Code",
      details: ioctl,
    );
  }

  Future<int?> _getProps() async {
    var props = await _channel.invokeMethod("props",);
    return props is int ? props : null;
  }

  @override
  @protected
  @visibleForTesting
  Future<bool> propsCheck() async {
    var props = await _getProps();
    switch (props) {
      case 0:
        return false;
      case 1:
        return true;
      case 2:
        if (enforceRestartRequirement) {
          throw PlatformException(
            code: _errorCode,
            message: "A restart is required to complete detection",
          );
        }
        return false;
      default:
        throw PlatformException(
          code: _errorCode,
          message: "Unexpected Props check result",
          details: props,
        );
    }
  }

  @override
  Future<bool> isRestartRequired() async {
    var props = await _getProps();
    if (props == null) {
      throw PlatformException(
        code: _errorCode,
        message: "Missing Props check result",
        details: props,
      );
    }
    return props == 2;
  }

  @override
  Future<bool> detectMagisk() => Future.wait(
    [
      haveSu(),
      haveMagicMount(),
      haveMagiskDSocket(),
      isIoctlModified(),
      propsCheck(),
    ],
    eagerError: true,
  ).then(
    (checkResults) => checkResults.contains(true,),
  );

  static const _errorCode = "MAGISK_ERROR";
  // ignore: prefer_const_constructors
  static late final _channel = MethodChannel("magisk_detector_channel",);
}