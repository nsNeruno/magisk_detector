import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

ffi.DynamicLibrary _load() => ffi.DynamicLibrary.open("libvvb2060.so",);

final magiskDetector = _load();

typedef CInt32Interop = ffi.Int32 Function();
typedef CCharArrayInterop = ffi.Pointer<Utf8> Function();

typedef DartIntInterop = int Function();

final DartIntInterop haveSu = magiskDetector.lookup<ffi.NativeFunction<CInt32Interop>>('nHaveSu',).asFunction();

final DartIntInterop haveMagicMount = magiskDetector.lookup<ffi.NativeFunction<CInt32Interop>>('nHaveMagicMount',).asFunction();

final DartIntInterop findMagiskDSocket = magiskDetector.lookup<ffi.NativeFunction<CInt32Interop>>('findMagiskDSocket',).asFunction();

final DartIntInterop testIoCtl = magiskDetector.lookup<ffi.NativeFunction<CInt32Interop>>('testIoCtl',).asFunction();

String getPropsHash() {
  CCharArrayInterop f = magiskDetector.lookup<ffi.NativeFunction<CCharArrayInterop>>('nGetPropsHash',).asFunction();
  return f().toDartString();
}