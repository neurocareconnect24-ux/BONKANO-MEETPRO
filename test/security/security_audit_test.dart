/// Security Audit Tests for Bonkano Meet Pro
///
/// Tests for Phase 1 security findings:
/// C1: SSL/TLS validation disabled
/// C2: Password stored in plaintext
/// C3: Keystore passwords in repo
/// C4: Demo credentials in production
/// C5: Payment secret keys client-side
/// H1: Agora App ID hardcoded
/// H2: Sensitive data in logs
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PHASE 1 — Security Audit Tests', () {
    // =========================================================
    // C1: SSL/TLS Certificate Validation Disabled
    // File: lib/utils/common_base.dart:861-866
    // =========================================================
    group('C1: SSL Certificate Validation', () {
      test('MyHttpOverrides should NOT accept all certificates', () {
        final file = File('lib/utils/common_base.dart');
        expect(file.existsSync(), isTrue, reason: 'common_base.dart must exist');

        final content = file.readAsStringSync();

        // Check for the dangerous pattern: badCertificateCallback returning true
        final hasDangerousOverride = content.contains(
                'badCertificateCallback') &&
            content.contains('=> true');

        expect(hasDangerousOverride, isFalse,
            reason:
                'CRITICAL C1: badCertificateCallback returns true unconditionally. '
                'This disables SSL validation and makes the app vulnerable to MITM attacks. '
                'File: lib/utils/common_base.dart:861-866. '
                'FIX: Return false or implement proper certificate pinning.');
      });
    });

    // =========================================================
    // C2: Password Stored in Plaintext
    // File: lib/network/network_utils.dart:121,131
    //       lib/screens/auth/sign_in_sign_up/sign_in_controller.dart:66-68
    // =========================================================
    group('C2: Password Storage', () {
      test('should NOT store raw password in SharedPreferences/GetStorage', () {
        final file = File('lib/network/network_utils.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check for password retrieval from plain storage
        final storesPassword = content.contains('USER_PASSWORD') &&
            content.contains('getValueFromLocal');

        expect(storesPassword, isFalse,
            reason:
                'CRITICAL C2: Password stored in plaintext in GetStorage. '
                'File: lib/network/network_utils.dart:121. '
                'FIX: Use flutter_secure_storage and implement refresh tokens.');
      });

      test('sign_in_controller should NOT save raw password', () {
        final file = File('lib/screens/auth/sign_in_sign_up/sign_in_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check for password saving to local storage
        final savesPassword = content.contains('USER_PASSWORD') &&
            (content.contains('setValueToLocal') || content.contains('setValue'));

        expect(savesPassword, isFalse,
            reason:
                'CRITICAL C2: sign_in_controller saves raw password to local storage. '
                'File: lib/screens/auth/sign_in_sign_up/sign_in_controller.dart:165. '
                'FIX: Never persist passwords. Use refresh tokens instead.');
      });
    });

    // =========================================================
    // C3: Android Keystore Credentials in Repo
    // File: android/key.properties
    // =========================================================
    group('C3: Keystore Security', () {
      test('key.properties should NOT contain hardcoded passwords', () {
        final file = File('android/key.properties');
        if (!file.existsSync()) {
          // If file doesn't exist, that's actually OK (should be in CI/CD)
          return;
        }

        final content = file.readAsStringSync();

        final hasHardcodedPassword =
            content.contains('NeuroCare2024!') ||
            RegExp(r'storePassword=.+').hasMatch(content);

        expect(hasHardcodedPassword, isFalse,
            reason:
                'CRITICAL C3: Keystore passwords hardcoded in key.properties. '
                'File: android/key.properties. '
                'FIX: Move to CI/CD env variables, add key.properties to .gitignore.');
      });

      test('key.properties should be in .gitignore', () {
        final gitignore = File('.gitignore');
        if (!gitignore.existsSync()) return;

        final content = gitignore.readAsStringSync();
        final isIgnored = content.contains('key.properties');

        expect(isIgnored, isTrue,
            reason: 'CRITICAL C3: key.properties is not in .gitignore. '
                'FIX: Add "android/key.properties" to .gitignore.');
      });
    });

    // =========================================================
    // C4: Demo/Test Credentials in Production
    // File: lib/utils/constants.dart:303-309
    // =========================================================
    group('C4: Demo Credentials', () {
      test('should NOT contain hardcoded demo emails/passwords', () {
        final file = File('lib/utils/constants.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final hasDemoCredentials =
            content.contains('vendor@bonkanomeet.com') ||
            content.contains('doctor@bonkanomeet.com') ||
            content.contains('receptionist@bonkanomeet.com');

        expect(hasDemoCredentials, isFalse,
            reason:
                'CRITICAL C4: Demo credentials present in production code. '
                'File: lib/utils/constants.dart:303-309. '
                'FIX: Remove or wrap in kDebugMode conditional.');
      });

      test('should NOT contain DEFAULT_PASS constant', () {
        final file = File('lib/utils/constants.dart');
        final content = file.readAsStringSync();

        final hasDefaultPass = content.contains("DEFAULT_PASS = '12345678'") ||
            content.contains('DEFAULT_PASS = "12345678"');

        expect(hasDefaultPass, isFalse,
            reason:
                'CRITICAL C4: Default password "12345678" hardcoded. '
                'File: lib/utils/constants.dart:15. '
                'FIX: Remove DEFAULT_PASS constant entirely.');
      });
    });

    // =========================================================
    // C5: Payment Secret Keys Client-Side
    // File: lib/screens/auth/model/app_configuration_res.dart:237-340
    // =========================================================
    group('C5: Payment Gateway Secrets', () {
      test('should NOT parse/store payment secret keys on client', () {
        final file = File('lib/screens/auth/model/app_configuration_res.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final hasSecretKeys =
            content.contains('razorpaySecretkey') ||
            content.contains('stripeSecretkey') ||
            content.contains('paystackSecretkey') ||
            content.contains('paypalSecretkey') ||
            content.contains('flutterwaveSecretkey');

        expect(hasSecretKeys, isFalse,
            reason:
                'CRITICAL C5: Payment gateway SECRET keys parsed client-side. '
                'File: lib/screens/auth/model/app_configuration_res.dart:237-340. '
                'FIX: Remove secret key fields. All payment processing must be server-side.');
      });
    });

    // =========================================================
    // H1: Hardcoded Agora App ID
    // File: lib/configs.dart:54
    // =========================================================
    group('H1: Agora Configuration', () {
      test('Agora App ID should NOT be hardcoded in source', () {
        final file = File('lib/configs.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final hasHardcodedId = content.contains('bffd3c50c66f43a0a2db7493e3dddfc6');

        expect(hasHardcodedId, isFalse,
            reason:
                'HIGH H1: Agora App ID hardcoded in configs.dart:54. '
                'FIX: Fetch from backend API alongside the Agora token.');
      });
    });

    // =========================================================
    // H2: Sensitive Data Logging
    // File: lib/utils/local_storage.dart:7,13
    // =========================================================
    group('H2: Sensitive Data in Logs', () {
      test('local_storage should NOT log values unconditionally', () {
        final file = File('lib/utils/local_storage.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check if log() contains $value or $val without kDebugMode guard
        final logsValues =
            content.contains(r'$value') && content.contains('log(') ||
            content.contains(r'$val') && content.contains('log(');

        // Check if there's a kDebugMode guard
        final hasDebugGuard = content.contains('kDebugMode') ||
            content.contains('kReleaseMode');

        if (logsValues) {
          expect(hasDebugGuard, isTrue,
              reason:
                  'HIGH H2: local_storage.dart logs sensitive values without debug guard. '
                  'File: lib/utils/local_storage.dart:7,13. '
                  'FIX: Wrap log() calls in "if (kDebugMode)" blocks.');
        }
      });

      test('network_utils should NOT log authorization headers', () {
        final file = File('lib/network/network_utils.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check for logging of request/response with headers
        final logsHeaders = content.contains('jsonEncode(request)') &&
            content.contains('log(') &&
            !content.contains('kDebugMode');

        // This is a soft check — logging in debug is OK, in release is not
        if (logsHeaders) {
          expect(content.contains('kDebugMode') || content.contains('kReleaseMode'), isTrue,
              reason:
                  'HIGH H5: Authorization tokens logged in network_utils. '
                  'File: lib/network/network_utils.dart:43-50. '
                  'FIX: Remove sensitive headers from log output.');
        }
      });
    });

    // =========================================================
    // Additional: No Certificate Pinning
    // =========================================================
    group('Certificate Pinning', () {
      test('should implement certificate pinning for critical endpoints', () {
        final file = File('lib/network/network_utils.dart');
        final content = file.readAsStringSync();

        final hasCertPinning = content.contains('SecurityContext') ||
            content.contains('certificate') ||
            content.contains('pinning');

        // This is an advisory test — pinning is strongly recommended
        expect(hasCertPinning, isTrue,
            reason:
                'ADVISORY: No certificate pinning found in network layer. '
                'For a medical app handling patient data, implement cert pinning '
                'for auth and data endpoints.');
      });
    });

    // =========================================================
    // Additional: Firebase Config
    // =========================================================
    group('Firebase Configuration', () {
      test('iOS Firebase API key should not be placeholder', () {
        final file = File('lib/firebase_options.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final hasPlaceholder = content.contains("apiKey: 'FIREBASE API KEY'") ||
            content.contains('apiKey: "FIREBASE API KEY"');

        expect(hasPlaceholder, isFalse,
            reason:
                'MEDIUM: iOS Firebase API key is a placeholder. '
                'File: lib/firebase_options.dart:59. '
                'FIX: Configure proper iOS Firebase credentials.');
      });
    });
  });
}
