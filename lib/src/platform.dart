import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:magisk_detector/magisk_detector.dart';
import 'package:secure_shared_preferences/secure_shared_pref.dart';

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

  Future<String?> _getBootId() => _channel.invokeMethod("getBootId",);

  Future<String?> _getPropsHash() => _channel.invokeMethod("getPropsHash",);
  
  Future<int> _getProps() async {
    final sp = await SecureSharedPref.getInstance();
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if ((androidInfo.version.sdkInt ?? 16) < 30) {
      // TODO: Handle Android 11 and above
      if (kDebugMode) {
        print("Props Hash currently not supported on Android 11 and above",);
      }
      return 0;
    }
    var fingerprint = androidInfo.fingerprint;
    var spFingerprint = await sp.getString("fingerprint", isEncrypted: true,) ?? "";
    assert(
      () {
        log(
          "spFingerprint=$spFingerprint \n  fingerprint=$fingerprint",
          name: "MagiskDetector",
        );
        return true;
      }(),
    );
    var spBootId = await sp.getString("boot_id", isEncrypted: true,) ?? "";
    var bootId = await _getBootId();
    assert(
      () {
        log(
          "spBootId=$spBootId \n  bootId=$bootId",
          name: "MagiskDetector"
        );
        return true;
      }(),
    );
    var spPropsHash = await sp.getString("props_hash", isEncrypted: true,) ?? "";
    if (spFingerprint == fingerprint && spBootId.isNotEmpty && spPropsHash.isNotEmpty) {
      if (spBootId != bootId) {
        var propsHash = await _getPropsHash();
        return spPropsHash == propsHash ? 0 : 1;
      } else {
        return 2;
      }
    } else {
      sp.putString(
        "fingerprint",
        fingerprint ?? "",
      );
      sp.putString(
        "boot_id",
        bootId ?? "",
      );
      var propsHash = await _getPropsHash();
      sp.putString(
        "props_hash",
        propsHash ?? "",
      );
      assert(
        () {
          if (fingerprint?.isNotEmpty != true) {
            log(
              "Fingerprint is missing",
              name: "MagiskDetector.Props",
            );
          }
          if (bootId?.isNotEmpty != true) {
            log(
              "Boot ID is missing",
              name: "MagiskDetector.Props",
            );
          }
          if (propsHash == null) {
            log(
              "Hash is missing",
              name: "MagiskDetector.Props",
            );
          }
          return true;
        }(),
      );
      return 2;
    }
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
    (checkResults) {
      if (kDebugMode) {
        print(
          {
            "haveSu": checkResults[0],
            "haveMagicMount": checkResults[1],
            "haveMagiskDSocket": checkResults[2],
            "isIoctlModified": checkResults[3],
            "propsCheck": checkResults[4],
          },
        );
      }
      return checkResults.contains(true,);
    },
  ).catchError(
    (err) {
      if (kDebugMode) {
        print("detectMagisk.error: $err",);
      }
    },
  );

  static const _errorCode = "MAGISK_ERROR";
  // ignore: prefer_const_constructors
  static late final _channel = MethodChannel("magisk_detector_channel",);
}