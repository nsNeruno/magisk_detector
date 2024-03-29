import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magisk_detector/magisk_detector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MagiskDetectionDemoApp());
}

class MagiskDetectionDemoApp extends StatelessWidget {
  const MagiskDetectionDemoApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magisk Detection Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MagiskDetectionDemoPage(),
    );
  }
}

class MagiskDetectionDemoPage extends StatelessWidget {

  const MagiskDetectionDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Magisk Detection Demo",),
      ),
      body: Center(
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          child: FutureBuilder<bool>(
            future: MagiskDetector.instance.detectMagisk(),
            builder: (_, snapshot,) {
              final error = snapshot.error;
              if (error is Error) {
                if (kDebugMode) {
                  print(error.stackTrace,);
                }
                return Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                );
              }
              final isMagiskDetected = snapshot.data;
              if (isMagiskDetected == null) {
                return const SizedBox.shrink();
              }
              return Text(
                "Magisk Detected:\n$isMagiskDetected",
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ),
    );
  }
}