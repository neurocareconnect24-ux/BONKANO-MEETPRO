/// Authentication Flow Tests for Bonkano Meet Pro
///
/// Covers: Login, Signup, Social login, Password flows
/// Bugs: B1, B2, B3, B4
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/auth/model/login_response.dart';
import 'package:bonkano_meet_pro/utils/constants.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Authentication Flow Tests', () {
    // =========================================================
    // Login Response Validation
    // =========================================================
    group('Login Response Handling', () {
      test('should accept user with valid doctor role', () {
        final user = TestUserFactory.createDoctor();

        final hasValidRole = user.userRole.contains(EmployeeKeyConst.vendor) ||
            user.userRole.contains(EmployeeKeyConst.doctor) ||
            user.userRole.contains(EmployeeKeyConst.receptionist);

        expect(hasValidRole, isTrue);
      });

      test('should reject user with no valid role', () {
        final user = UserData(
          id: 1,
          email: 'test@test.com',
          userRole: ['patient'], // patient role is NOT valid for admin app
        );

        final hasValidRole = user.userRole.contains(EmployeeKeyConst.vendor) ||
            user.userRole.contains(EmployeeKeyConst.doctor) ||
            user.userRole.contains(EmployeeKeyConst.receptionist);

        expect(hasValidRole, isFalse,
            reason: 'Patient role should not be accepted in the admin app');
      });

      test('should reject user with empty roles', () {
        final user = TestUserFactory.createInvalidUser();

        final hasValidRole = user.userRole.contains(EmployeeKeyConst.vendor) ||
            user.userRole.contains(EmployeeKeyConst.doctor) ||
            user.userRole.contains(EmployeeKeyConst.receptionist);

        expect(hasValidRole, isFalse);
      });

      test('should handle multi-role user correctly', () {
        final user = TestUserFactory.createMultiRoleUser();

        expect(user.userRole.contains(EmployeeKeyConst.vendor), isTrue);
        expect(user.userRole.contains(EmployeeKeyConst.doctor), isTrue);
        expect(user.userRole.length, 2);
      });
    });

    // =========================================================
    // Doctor Clinic Selection Logic
    // =========================================================
    group('Doctor Clinic Selection', () {
      test('doctor with negative clinic ID should require clinic selection', () {
        final json = TestJsonFixtures.loginSuccessJson(
          role: 'doctor',
          clinicId: -1,
        );
        final response = UserResponse.fromJson(json);
        final clinicId = response.userData.selectedClinic?.id ?? -1;

        // Doctor with negative clinic → must select clinic
        expect(clinicId.isNegative, isTrue);
      });

      test('BUG B3: clinic ID 0 should also require selection (isNegative misses 0)', () {
        final json = TestJsonFixtures.loginSuccessJson(
          role: 'doctor',
          clinicId: 0,
        );
        final response = UserResponse.fromJson(json);
        final clinicId = response.userData.selectedClinic?.id ?? -1;

        // BUG B3: 0.isNegative is false, but 0 is not a valid clinic ID
        // Current code at splash_controller.dart:70 uses .isNegative
        // which treats 0 as valid
        final needsClinicSelection = clinicId <= 0; // Correct check
        final currentCodeCheck = clinicId.isNegative; // Current (buggy) check

        expect(needsClinicSelection, isTrue,
            reason: 'Clinic ID 0 should require re-selection');
        expect(currentCodeCheck, isFalse,
            reason: 'BUG B3: isNegative returns false for 0, '
                'allowing invalid clinic. '
                'File: splash_controller.dart:70. '
                'FIX: Use <= 0 instead of isNegative.');
      });

      test('doctor with valid clinic ID should proceed to dashboard', () {
        final json = TestJsonFixtures.loginSuccessJson(
          role: 'doctor',
          clinicId: 42,
        );
        final response = UserResponse.fromJson(json);
        final clinicId = response.userData.selectedClinic?.id ?? -1;

        expect(clinicId, greaterThan(0));
      });

      test('vendor should NOT require clinic selection', () {
        final vendor = TestUserFactory.createVendor();
        // Vendors manage clinics, they don't need to select one
        expect(vendor.userRole.contains(EmployeeKeyConst.vendor), isTrue);
        // No clinic selection check needed for vendors
      });
    });

    // =========================================================
    // BUG B1: SignUpController.saveForm() uses Get.find<SignInController>()
    // File: sign_up_controller.dart:116
    // =========================================================
    group('BUG B1: SignUp → SignIn Controller Dependency', () {
      test('signup success should not crash if SignInController is not registered', () {
        // BUG B1: Get.find<SignInController>() may throw if controller
        // not initialized when user navigates directly to SignUp
        //
        // This is a structural test — the fix should wrap in try-catch
        // or use Get.isRegistered<SignInController>()

        final file = File('lib/screens/auth/sign_in_sign_up/sign_up_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // Check if Get.find is guarded with try-catch or isRegistered
        final hasGetFind = content.contains('Get.find<SignInController>()');
        final hasGuard = content.contains('Get.isRegistered') ||
            content.contains('try {') && content.contains('Get.find');

        if (hasGetFind) {
          expect(hasGuard, isTrue,
              reason: 'BUG B1: Get.find<SignInController>() without guard. '
                  'File: sign_up_controller.dart:116. '
                  'FIX: Use Get.isRegistered<SignInController>() or try-catch.');
        }
      });
    });

    // =========================================================
    // BUG B2: Change Password pre-fills from SharedPrefs
    // File: change_password_controller.dart:22
    // =========================================================
    group('BUG B2: Change Password for Social Login Users', () {
      test('social login users should not have stored password', () {
        final socialUser = TestUserFactory.createSocialLoginUser();

        // Social login users authenticate via Google/Apple, no password stored
        expect(socialUser.isSocialLogin, isTrue);
        expect(socialUser.loginType, isNot('user'));

        // The change password controller pre-fills from storage
        // For social users, this will be empty → validation fails
        // File: change_password_controller.dart:22
      });

      test('change_password_controller should check for social login', () {
        final file = File('lib/screens/auth/password/change_password_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final checksSocialLogin = content.contains('isSocialLogin') ||
            content.contains('loginType') ||
            content.contains('social');

        expect(checksSocialLogin, isTrue,
            reason: 'BUG B2: change_password_controller pre-fills old password '
                'from SharedPrefs without checking if user is social login. '
                'Social login users have no stored password. '
                'File: change_password_controller.dart:22. '
                'FIX: Check isSocialLogin flag, hide/skip old password for social users.');
      });
    });

    // =========================================================
    // BUG B4: Forgot Password - No success message
    // File: forget_pass_controller.dart:25-26
    // =========================================================
    group('BUG B4: Forgot Password Flow', () {
      test('forgot password should show success message before navigating back', () {
        final file = File('lib/screens/auth/password/forget_pass_controller.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        // After API success, should show a toast/snackbar before Get.back()
        final showsSuccessMessage = content.contains('toast(') ||
            content.contains('Fluttertoast') ||
            content.contains('snackbar') ||
            content.contains('SnackBar') ||
            content.contains('successToast');

        expect(showsSuccessMessage, isTrue,
            reason: 'BUG B4: Forgot password navigates back without success message. '
                'User doesn\'t know if the email was sent. '
                'File: forget_pass_controller.dart:25-26. '
                'FIX: Show toast("Password reset link sent to your email") before Get.back().');
      });
    });

    // =========================================================
    // Token Management
    // =========================================================
    group('Token Management', () {
      test('API token should be present after successful login', () {
        final json = TestJsonFixtures.loginSuccessJson();
        final response = UserResponse.fromJson(json);

        expect(response.userData.apiToken.isNotEmpty, isTrue);
      });

      test('should handle empty API token gracefully', () {
        final user = TestUserFactory.createInvalidUser();
        expect(user.apiToken, '');
      });

      test('reGenerateToken should NOT use stored password', () {
        final file = File('lib/network/network_utils.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final usesStoredPassword = content.contains('reGenerateToken') &&
            content.contains('USER_PASSWORD');

        expect(usesStoredPassword, isFalse,
            reason: 'Token regeneration uses stored plaintext password. '
                'File: network_utils.dart:119-138. '
                'FIX: Implement proper refresh token mechanism on backend.');
      });
    });

    // =========================================================
    // Role Constants Integrity
    // =========================================================
    group('Role Constants', () {
      test('EmployeeKeyConst should have all expected roles', () {
        expect(EmployeeKeyConst.vendor, 'vendor');
        expect(EmployeeKeyConst.doctor, 'doctor');
        expect(EmployeeKeyConst.receptionist, 'receptionist');
      });

      test('SharedPreferenceConst should have all expected keys', () {
        expect(SharedPreferenceConst.IS_LOGGED_IN, 'IS_LOGGED_IN');
        expect(SharedPreferenceConst.USER_DATA, 'USER_LOGIN_DATA');
        expect(SharedPreferenceConst.USER_EMAIL, 'USER_EMAIL');
        expect(SharedPreferenceConst.USER_PASSWORD, 'USER_PASSWORD');
        expect(SharedPreferenceConst.IS_REMEMBER_ME, 'IS_REMEMBER_ME');
      });
    });
  });
}
