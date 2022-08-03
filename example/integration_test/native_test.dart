import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:magisk_detector/magisk_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    "Magisk Detector Test",
    () {
      final detector = MagiskDetector.instance
        ..enforceRestartRequirement = false;

      testWidgets(
        "Native Test",
        (tester) async {
          bool? restartRequired;
          try {
            restartRequired = await detector.isRestartRequired();
          } catch (err) {
            if (kDebugMode) {
              print(err,);
            }
          }
          expect(restartRequired != null, true,);

          if (restartRequired != true || !detector.enforceRestartRequirement) {
            bool? isMagiskDetected;
            try {
              isMagiskDetected = await detector.detectMagisk();
            } catch (err) {
              if (kDebugMode) {
                print(err,);
              }
            }
            expect(isMagiskDetected != null, true,);
          }
        },
      );
    },
  );
}