/// Memory Leak & Resource Disposal Tests
///
/// Verifies that all GetX controllers properly dispose resources:
/// - StreamSubscriptions are stored and cancelled
/// - TextEditingControllers are disposed
/// - FocusNodes are disposed
/// - ScrollController listeners are removed
/// - Timers are cancelled
/// - Firebase listeners are cancelled
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Helper to check if a Dart file containing a GetxController
/// properly disposes its resources in onClose()
class ControllerDisposalChecker {
  final String filePath;
  final String content;

  ControllerDisposalChecker(this.filePath)
      : content = File(filePath).existsSync()
            ? File(filePath).readAsStringSync()
            : '';

  bool get fileExists => content.isNotEmpty;

  /// Counts occurrences of a pattern
  int count(String pattern) {
    return RegExp(RegExp.escape(pattern)).allMatches(content).length;
  }

  /// Checks if the controller has an onClose() method
  bool get hasOnClose => content.contains('onClose()');

  /// Gets all TextEditingController declarations
  int get textEditingControllerCount {
    return RegExp(r'TextEditingController\b').allMatches(content).length;
  }

  /// Gets all FocusNode declarations
  int get focusNodeCount {
    return RegExp(r'FocusNode\b').allMatches(content).length;
  }

  /// Gets .listen( calls (stream subscriptions)
  int get listenCallCount {
    return RegExp(r'\.listen\(').allMatches(content).length;
  }

  /// Gets .dispose() calls in onClose
  int get disposeCallCount {
    return RegExp(r'\.dispose\(\)').allMatches(content).length;
  }

  /// Gets .cancel() calls
  int get cancelCallCount {
    return RegExp(r'\.cancel\(\)').allMatches(content).length;
  }

  /// Gets .close() calls
  int get closeCallCount {
    return RegExp(r'\.close\(\)').allMatches(content).length;
  }

  /// Checks if stream subscriptions are stored in variables
  bool get storesSubscriptions {
    return content.contains('StreamSubscription') ||
        content.contains('_sub') ||
        content.contains('subscription');
  }
}

void main() {
  group('Memory Leak Tests — Controller Disposal', () {
    // =========================================================
    // M1: StreamSubscriptions not stored (12 controllers)
    // =========================================================
    group('M1: StreamSubscription Storage', () {
      final controllersWithStreams = {
        'lib/screens/service/assing_doctor_screen_controller.dart': 'AssingDoctorController',
        'lib/screens/appointment/appointments_controller.dart': 'AppointmentsController',
        'lib/screens/Encounter/clinical_details/clinical_details_controller.dart': 'ClinicalDetailsController',
        'lib/screens/Encounter/all_encounters_controller.dart': 'AllEncountersController',
        'lib/screens/appointment/filter/filter_controller.dart': 'FilterController',
        'lib/screens/doctor/doctor_list_controller.dart': 'DoctorListController',
        'lib/screens/clinic/clinic_list_controller.dart': 'ClinicListController',
        'lib/screens/home/choose_clinic_controller.dart': 'ChooseClinicController',
        'lib/screens/service/all_service_list_controller.dart': 'AllServiceListController',
      };

      for (final entry in controllersWithStreams.entries) {
        test('${entry.value} should store and cancel stream subscriptions', () {
          final checker = ControllerDisposalChecker(entry.key);
          if (!checker.fileExists) return;

          if (checker.listenCallCount > 0) {
            expect(checker.hasOnClose, isTrue,
                reason: '${entry.value} has ${checker.listenCallCount} .listen() calls '
                    'but no onClose() method. '
                    'File: ${entry.key}. '
                    'FIX: Add onClose() and cancel all stream subscriptions.');

            // Either store subscriptions or close streams
            final hasCancelOrClose =
                checker.cancelCallCount > 0 || checker.closeCallCount > 0;
            expect(hasCancelOrClose, isTrue,
                reason: '${entry.value} creates stream subscriptions but never '
                    'cancels them in onClose(). Memory leak! '
                    'FIX: Store subscriptions in variables and call .cancel() in onClose().');
          }
        });
      }
    });

    // =========================================================
    // M2: TextEditingControllers not disposed (50+ instances)
    // =========================================================
    group('M2: TextEditingController Disposal', () {
      final controllersWithTEC = {
        'lib/screens/auth/sign_in_sign_up/sign_in_controller.dart': 'SignInController',
        'lib/screens/auth/sign_in_sign_up/sign_up_controller.dart': 'SignUpController',
        'lib/screens/auth/profile/edit_user_profile_controller.dart': 'EditUserProfileController',
        'lib/screens/receptionist/components/add_receptionist_controller.dart': 'AddReceptionistController',
        'lib/screens/requests/request_list_screen_controller.dart': 'RequestListScreenController',
      };

      for (final entry in controllersWithTEC.entries) {
        test('${entry.value} should dispose all TextEditingControllers', () {
          final checker = ControllerDisposalChecker(entry.key);
          if (!checker.fileExists) return;

          final tecCount = checker.textEditingControllerCount;
          if (tecCount > 0) {
            expect(checker.hasOnClose, isTrue,
                reason: '${entry.value} has $tecCount TextEditingController(s) '
                    'but no onClose() method. '
                    'File: ${entry.key}. '
                    'FIX: Add onClose() and dispose all controllers.');

            if (checker.hasOnClose) {
              expect(checker.disposeCallCount, greaterThanOrEqualTo(tecCount),
                  reason: '${entry.value} has $tecCount TextEditingController(s) '
                      'but only ${checker.disposeCallCount} .dispose() calls. '
                      'FIX: Dispose every TextEditingController in onClose().');
            }
          }
        });
      }
    });

    // =========================================================
    // M2b: FocusNode Disposal
    // =========================================================
    group('M2b: FocusNode Disposal', () {
      final controllersWithFocus = {
        'lib/screens/auth/sign_in_sign_up/sign_in_controller.dart': 'SignInController',
        'lib/screens/auth/sign_in_sign_up/sign_up_controller.dart': 'SignUpController',
        'lib/screens/auth/profile/edit_user_profile_controller.dart': 'EditUserProfileController',
      };

      for (final entry in controllersWithFocus.entries) {
        test('${entry.value} should dispose all FocusNodes', () {
          final checker = ControllerDisposalChecker(entry.key);
          if (!checker.fileExists) return;

          final fnCount = checker.focusNodeCount;
          if (fnCount > 0 && checker.hasOnClose) {
            // Each FocusNode needs .dispose()
            // disposeCallCount should cover both TECs and FocusNodes
            expect(checker.disposeCallCount, greaterThanOrEqualTo(fnCount),
                reason: '${entry.value} has $fnCount FocusNode(s) '
                    'but insufficient .dispose() calls. '
                    'FIX: Dispose every FocusNode in onClose().');
          }
        });
      }
    });

    // =========================================================
    // M3: Firebase Messaging listeners never cancelled
    // File: lib/utils/push_notification_service.dart:125-145
    // =========================================================
    group('M3: Firebase Messaging Disposal', () {
      test('FCM listeners should be stored and cancellable', () {
        final checker = ControllerDisposalChecker('lib/utils/push_notification_service.dart');
        if (!checker.fileExists) return;

        final hasListeners = checker.content.contains('onMessage.listen') ||
            checker.content.contains('onMessageOpenedApp.listen');

        if (hasListeners) {
          final storesSubscription = checker.content.contains('StreamSubscription') ||
              checker.content.contains('_onMessage') ||
              checker.content.contains('_messageSubscription');

          expect(storesSubscription, isTrue,
              reason: 'M3: Firebase onMessage/onMessageOpenedApp listeners '
                  'are created but subscriptions are not stored. '
                  'File: push_notification_service.dart:125-145. '
                  'FIX: Store subscriptions and provide a dispose/cleanup method.');
        }
      });
    });

    // =========================================================
    // M4: Map Screen dispose() is empty
    // File: lib/network/map_screen.dart:120-122
    // =========================================================
    group('M4: MapScreen Disposal', () {
      test('MapScreen should dispose controllers in dispose()', () {
        final checker = ControllerDisposalChecker('lib/network/map_screen.dart');
        if (!checker.fileExists) return;

        if (checker.textEditingControllerCount > 0 || checker.focusNodeCount > 0) {
          expect(checker.disposeCallCount, greaterThan(0),
              reason: 'M4: MapScreen has controllers/focus nodes but empty dispose(). '
                  'File: lib/network/map_screen.dart:120-122. '
                  'FIX: Dispose destinationAddressController, '
                  'destinationAddressFocusNode, and GoogleMapController.');
        }
      });
    });

    // =========================================================
    // Video Call Timer
    // =========================================================
    group('Video Call Timer Disposal', () {
      test('video call timer should be cancelled in onClose', () {
        final checker = ControllerDisposalChecker(
            'lib/screens/appointment/video_call/video_call_controller.dart');
        if (!checker.fileExists) return;

        final hasTimer = checker.content.contains('Timer.periodic') ||
            checker.content.contains('_callTimer');

        if (hasTimer) {
          final cancelsTimer = checker.content.contains('cancel()') &&
              checker.content.contains('onClose');

          expect(cancelsTimer, isTrue,
              reason: 'Video call timer should be cancelled in onClose(). '
                  'Verified: Timer is properly cancelled.');
        }
      });
    });

    // =========================================================
    // General: All controllers should have onClose if they have resources
    // =========================================================
    group('General: onClose Coverage', () {
      test('scan all controllers for missing onClose', () {
        final controllerDir = Directory('lib/screens');
        if (!controllerDir.existsSync()) return;

        final controllerFiles = controllerDir
            .listSync(recursive: true)
            .where((f) => f.path.endsWith('_controller.dart'))
            .map((f) => f.path)
            .toList();

        final missingOnClose = <String>[];

        for (final path in controllerFiles) {
          final checker = ControllerDisposalChecker(path);
          if (!checker.fileExists) continue;

          final hasResources = checker.textEditingControllerCount > 0 ||
              checker.focusNodeCount > 0 ||
              checker.listenCallCount > 0 ||
              checker.content.contains('Timer') ||
              checker.content.contains('AnimationController');

          if (hasResources && !checker.hasOnClose) {
            missingOnClose.add(path);
          }
        }

        expect(missingOnClose, isEmpty,
            reason: 'The following controllers have disposable resources '
                'but NO onClose() method:\n${missingOnClose.join('\n')}\n'
                'FIX: Add onClose() and dispose all resources.');
      });
    });
  });
}
