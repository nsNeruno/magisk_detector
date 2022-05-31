import 'dart:io';

import 'package:flutter/services.dart' show PlatformException;

abstract class AndroidOnlyRuntime {

  AndroidOnlyRuntime() {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: "InvalidPlatform",
        message: "Only available for Android",
        details: null,
      );
    }
  }
}