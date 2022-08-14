import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:magisk_detector/magisk_detector.dart';

class MagiskDetectorPlatform extends MagiskDetector {

  MagiskDetectorPlatform() {
    _channel.setMethodCallHandler(
      (call) async {
        if (kDebugMode) {
          var args = call.arguments;
          String? message;
          if (args is Map) {
            try {
              message = const JsonEncoder.withIndent('\t',).convert(args,);
            } catch (_) {
              message = args.toString();
            }
          }
          log(
            'errors: ${call.method}${message != null ? '\n$message' : ''}',
            name: 'detectMagisk',
          );
        }
        switch (call.method) {
          case "onServiceRemoteException":
          case "onAppHackedError":
            _isAppHacked = true;
            break;
        }
      },
    );
  }

  @override
  @protected
  @visibleForTesting
  Future<bool> haveSu() async {
    var haveSu = await _channel.invokeMethod("haveSu",);
    if (haveSu is int) {
      if (kDebugMode) {
        log(
          'haveSu: $haveSu',
          name: 'detectMagisk',
        );
      }
      switch (haveSu) {
        case 1:
          return true;
        case 0:
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
      if (kDebugMode) {
        log(
          'Magisk Module affected $magicMount file(s)',
          name: 'detectMagisk.haveMagicMount',
        );
      }
      return magicMount > 0;
    }
    throw PlatformException(
      code: _errorCode,
      message: "Unexpected Magic Mount: $magicMount",
      details: magicMount,
    );
  }

  @override
  Future<bool> haveMagiskHide() async {
    var pid = await _channel.invokeMethod("haveMagiskHide",);
    if (pid is int) {
      final found = pid > 0;
      if (kDebugMode) {
        log(
          'haveMagiskHide: ${found ? 'Magisk process found at PID $pid' : 'Magisk process not found'}',
          name: 'detectMagisk',
        );
      }
      return found;
    }
    throw PlatformException(
      code: _errorCode,
      message: "Unexpected PID Response Code: $pid",
      details: pid,
    );
  }

  @override
  bool isAppHacked() => _isAppHacked;

  @override
  Future<bool> detectMagisk() => Future.wait(
    [
      Future.value(isAppHacked(),),
      haveSu(),
      haveMagicMount(),
      haveMagiskHide(),
    ],
    eagerError: true,
  ).then(
    (checkResults) {
      if (kDebugMode) {
        log(
          const JsonEncoder.withIndent('\t',).convert(
            {
              "isAppHacked": checkResults[0],
              "haveSu": checkResults[1],
              "haveMagicMount": checkResults[2],
              "haveMagiskHide": checkResults[3],
            },
          ),
          name: 'detectMagisk',
        );
      }
      return checkResults.contains(true,);
    },
  ).catchError(
    (err) {
      if (kDebugMode) {
        Error? error;
        if (err is Error) {
          error = err;
        }
        log(
          error.toString(),
          name: 'detectMagisk.error',
          error: error,
          stackTrace: error?.stackTrace,
        );
      }
      return err;
    },
    test: (_) => false,
  );

  bool _isAppHacked = false;

  static const _errorCode = "MAGISK_ERROR";
  // ignore: prefer_const_constructors
  static late final _channel = MethodChannel("magisk_detector_channel",);
}