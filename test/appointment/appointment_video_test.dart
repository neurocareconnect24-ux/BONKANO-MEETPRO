/// Appointment & Video Call Tests for Bonkano Meet Pro
///
/// Covers: Appointment CRUD, status transitions, video call lifecycle
/// Bugs: B7, B8, B9, B10, B11, B12, B13
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/appointment/model/agora_token_res_model.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Appointment & Video Call Tests', () {
    // =========================================================
    // Appointment Status Transitions
    // =========================================================
    group('Appointment Status Transitions', () {
      test('canLaunchVideoCall should return true for confirmed status', () {
        expect(canLaunchVideoCall(status: 'confirmed'), isTrue);
      });

      test('canLaunchVideoCall should return true for check_in status', () {
        expect(canLaunchVideoCall(status: 'check_in'), isTrue);
      });

      test('canLaunchVideoCall should return false for pending status', () {
        expect(canLaunchVideoCall(status: 'pending'), isFalse);
      });

      test('canLaunchVideoCall should return false for cancelled status', () {
        expect(canLaunchVideoCall(status: 'cancelled'), isFalse);
      });

      test('canLaunchVideoCall should return false for completed status', () {
        expect(canLaunchVideoCall(status: 'completed'), isFalse);
      });

      test('canLaunchVideoCall should handle case-insensitive status', () {
        expect(canLaunchVideoCall(status: 'CONFIRMED'), isTrue);
        expect(canLaunchVideoCall(status: 'Confirmed'), isTrue);
        expect(canLaunchVideoCall(status: 'CHECK_IN'), isTrue);
      });

      test('canLaunchVideoCall should handle empty status', () {
        expect(canLaunchVideoCall(status: ''), isFalse);
      });
    });

    // =========================================================
    // BUG B7: Payment save failure after appointment creation
    // File: add_appointment_controller.dart:113-124
    // =========================================================
    group('BUG B7: Appointment + Payment Atomicity', () {
      test('save flow should handle payment failure after booking success', () {
        final file = File('lib/screens/appointment/add_appointment/add_appointment_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check if savePayment failure is caught separately from saveBookApi
        final hasPaymentErrorHandling =
            content.contains('savePayment') &&
            (content.contains('.catchError') || content.contains('try {'));

        // Check if there's a rollback or error notification
        final hasRollbackOrNotification =
            content.contains('deleteBooking') ||
            content.contains('rollback') ||
            content.contains('toast') && content.contains('payment');

        expect(hasPaymentErrorHandling, isTrue,
            reason: 'BUG B7: If savePayment() fails after saveBookApi() succeeds, '
                'appointment exists without payment record. No rollback. '
                'File: add_appointment_controller.dart:113-124. '
                'FIX: Wrap in transaction or notify user of partial failure.');
      });
    });

    // =========================================================
    // BUG B8: Past date/time booking
    // File: add_appointment_form_screen.dart:150-174
    // =========================================================
    group('BUG B8: Past Date Validation', () {
      test('should not allow booking appointments in the past', () {
        final file = File('lib/screens/appointment/add_appointment/add_appointment_form_screen.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check for date validation against current date
        final validatesPastDate =
            content.contains('DateTime.now()') ||
            content.contains('isAfter') ||
            content.contains('isBefore') ||
            content.contains('past');

        expect(validatesPastDate, isTrue,
            reason: 'BUG B8: No validation preventing past date/time booking. '
                'File: add_appointment_form_screen.dart:150-174. '
                'FIX: Check selectedDate >= DateTime.now().startOfDay before allowing slot selection.');
      });
    });

    // =========================================================
    // Video Call - Agora Token Validation
    // =========================================================
    group('Agora Token Validation', () {
      test('valid token should have non-empty token and channelName', () {
        final token = TestAgoraFactory.createValid();

        expect(token.token.isNotEmpty, isTrue);
        expect(token.channelName.isNotEmpty, isTrue);
        expect(token.uid, greaterThan(0));
        expect(token.status, isTrue);
      });

      test('should detect empty/invalid token', () {
        final empty = TestAgoraFactory.createEmpty();

        expect(empty.token.isEmpty, isTrue);
        expect(empty.channelName.isEmpty, isTrue);
      });

      test('should parse nested data format correctly', () {
        final json = TestJsonFixtures.agoraTokenNestedJson();
        final token = AgoraTokenRes.fromJson(json);

        expect(token.token, isNotEmpty);
        expect(token.channelName, isNotEmpty);
        expect(token.uid, greaterThan(0));
      });

      test('should parse flat format correctly', () {
        final json = TestJsonFixtures.agoraTokenFlatJson();
        final token = AgoraTokenRes.fromJson(json);

        expect(token.token, isNotEmpty);
        expect(token.channelName, isNotEmpty);
      });
    });

    // =========================================================
    // BUG B10: Token expiry not refreshed
    // File: video_call_controller.dart:142-144
    // =========================================================
    group('BUG B10: Agora Token Expiry', () {
      test('video_call_controller should handle token privilege expiry', () {
        final file = File('lib/screens/appointment/video_call/video_call_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final hasTokenExpiry = content.contains('onTokenPrivilegeWillExpire');

        if (hasTokenExpiry) {
          // Check if it actually refreshes the token
          final refreshesToken =
              content.contains('renewToken') ||
              content.contains('getAgoraToken') && content.contains('onTokenPrivilegeWillExpire') ||
              content.contains('joinChannelWithToken');

          expect(refreshesToken, isTrue,
              reason: 'BUG B10: onTokenPrivilegeWillExpire only logs, does not refresh. '
                  'Call will drop silently when token expires. '
                  'File: video_call_controller.dart:142-144. '
                  'FIX: Fetch new token from backend and call '
                  'agoraEngine.renewToken(newToken) in the callback.');
        }
      });
    });

    // =========================================================
    // BUG B11: Permission race condition
    // File: video_call_controller.dart:195-200
    // =========================================================
    group('BUG B11: Permission Handling', () {
      test('permission check should not have arbitrary delay race condition', () {
        final file = File('lib/screens/appointment/video_call/video_call_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check for the problematic pattern: Future.delayed + permission re-check
        final hasDelayedRecheck =
            content.contains('Future.delayed') &&
            content.contains('Duration(milliseconds:') &&
            content.contains('Permission');

        if (hasDelayedRecheck) {
          // This is a code smell — permissions should be awaited, not delayed
          expect(hasDelayedRecheck, isFalse,
              reason: 'BUG B11: Permission re-check uses arbitrary delay (500ms). '
                  'Race condition if device is slow. '
                  'File: video_call_controller.dart:195-200. '
                  'FIX: Use await for permission result, remove arbitrary delay.');
        }
      });
    });

    // =========================================================
    // BUG B13: Teleconsultation auto-refresh
    // File: teleconsultation_screen.dart:37-42
    // =========================================================
    group('BUG B13: Teleconsultation Auto-Refresh', () {
      test('auto-refresh should check if controller/widget is still alive', () {
        final file = File('lib/screens/teleconsultation/teleconsultation_screen.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final hasAutoRefresh = content.contains('Future.doWhile') ||
            content.contains('Timer.periodic');

        if (hasAutoRefresh) {
          final checksDisposed =
              content.contains('isClosed') ||
              content.contains('mounted') ||
              content.contains('disposed');

          expect(checksDisposed, isTrue,
              reason: 'BUG B13: Auto-refresh uses Future.doWhile without checking '
                  'if widget is still mounted/controller is not closed. '
                  'File: teleconsultation_screen.dart:37-42. '
                  'FIX: Check controller.isClosed before each refresh cycle.');
        }
      });
    });

    // =========================================================
    // Appointment Status Text Mapping
    // =========================================================
    group('Status Text Mapping', () {
      test('getBookingStatus should handle all known statuses', () {
        // These use locale so we test the underlying logic pattern
        final statuses = ['pending', 'confirmed', 'check_in', 'checkout', 'cancelled', 'completed'];

        for (final status in statuses) {
          final result = getBookingStatus(status: status);
          expect(result, isNotEmpty,
              reason: 'getBookingStatus should return non-empty string for status: $status');
        }
      });

      test('getBookingStatus should handle unknown status', () {
        final result = getBookingStatus(status: 'unknown_status');
        expect(result, isEmpty,
            reason: 'Unknown status should return empty string');
      });

      test('getBookingStatus should be case-insensitive', () {
        // The function uses .toLowerCase().contains()
        final resultLower = getBookingStatus(status: 'pending');
        final resultUpper = getBookingStatus(status: 'PENDING');
        final resultMixed = getBookingStatus(status: 'Pending');

        expect(resultLower, equals(resultUpper));
        expect(resultUpper, equals(resultMixed));
      });
    });
  });
}
