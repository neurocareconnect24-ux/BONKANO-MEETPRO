import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/auth/model/login_response.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('UserData Model', () {
    group('fromJson', () {
      test('should parse valid login response correctly', () {
        final json = TestJsonFixtures.loginSuccessJson();
        final response = UserResponse.fromJson(json);

        expect(response.status, isTrue);
        expect(response.message, 'Login successful');
        expect(response.userData.id, 1);
        expect(response.userData.firstName, 'Dr');
        expect(response.userData.lastName, 'Test');
        expect(response.userData.email, 'doctor@test.com');
        expect(response.userData.apiToken, 'fresh-api-token-xyz');
        expect(response.userData.userRole, contains('doctor'));
        expect(response.userData.userType, 'doctor');
        expect(response.userData.isSocialLogin, isFalse);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{'status': true, 'message': 'ok', 'data': <String, dynamic>{}};
        final response = UserResponse.fromJson(json);

        expect(response.userData.id, -1);
        expect(response.userData.firstName, '');
        expect(response.userData.lastName, '');
        expect(response.userData.email, '');
        expect(response.userData.apiToken, '');
        expect(response.userData.userRole, isEmpty);
        expect(response.userData.isSocialLogin, isFalse);
      });

      test('should handle null data gracefully', () {
        final json = {'status': false, 'message': 'Error', 'data': null};
        final response = UserResponse.fromJson(json);

        expect(response.status, isFalse);
        expect(response.userData.id, -1);
      });

      test('should handle wrong types gracefully', () {
        final json = <String, dynamic>{
          'status': 'not_a_bool',
          'message': 123,
          'data': <String, dynamic>{
            'id': 'not_an_int',
            'first_name': 456,
            'email': true,
            'user_role': 'not_a_list',
            'is_social_login': 'not_a_bool',
          },
        };
        final response = UserResponse.fromJson(json);

        expect(response.status, isFalse);
        expect(response.message, '');
        expect(response.userData.id, -1);
        expect(response.userData.firstName, '');
        expect(response.userData.email, '');
        expect(response.userData.userRole, isEmpty);
        expect(response.userData.isSocialLogin, isFalse);
      });

      test('should fallback userName to firstName + lastName', () {
        final json = <String, dynamic>{
          'status': true,
          'data': <String, dynamic>{
            'first_name': 'Jean',
            'last_name': 'Dupont',
          },
        };
        final response = UserResponse.fromJson(json);
        expect(response.userData.userName, 'Jean Dupont');
      });

      test('should parse selectedClinic when present', () {
        final json = TestJsonFixtures.loginSuccessJson(clinicId: 42);
        final response = UserResponse.fromJson(json);

        expect(response.userData.selectedClinic, isNotNull);
        expect(response.userData.selectedClinic!.id, 42);
      });

      test('should handle selectedClinic when absent', () {
        final json = <String, dynamic>{
          'status': true,
          'data': <String, dynamic>{'id': 1},
        };
        final response = UserResponse.fromJson(json);
        // Should not crash - selectedClinic gets default ClinicData()
        expect(response.userData.id, 1);
      });
    });

    group('toJson', () {
      test('should serialize and deserialize roundtrip', () {
        final original = TestUserFactory.createDoctor();
        final json = original.toJson();
        final restored = UserData.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.firstName, original.firstName);
        expect(restored.email, original.email);
        expect(restored.apiToken, original.apiToken);
        expect(restored.userRole, original.userRole);
        expect(restored.userType, original.userType);
        expect(restored.isSocialLogin, original.isSocialLogin);
      });
    });

    group('Default Values', () {
      test('should initialize with safe defaults', () {
        final user = UserData();

        expect(user.id, -1);
        expect(user.firstName, '');
        expect(user.email, '');
        expect(user.apiToken, '');
        expect(user.userRole, isEmpty);
        expect(user.isSocialLogin, isFalse);
      });
    });

    group('Role Checks', () {
      test('doctor role should be identified', () {
        final doctor = TestUserFactory.createDoctor();
        expect(doctor.userRole.contains('doctor'), isTrue);
        expect(doctor.userRole.contains('vendor'), isFalse);
      });

      test('vendor role should be identified', () {
        final vendor = TestUserFactory.createVendor();
        expect(vendor.userRole.contains('vendor'), isTrue);
        expect(vendor.userRole.contains('doctor'), isFalse);
      });

      test('multi-role user should have both roles', () {
        final multi = TestUserFactory.createMultiRoleUser();
        expect(multi.userRole.contains('vendor'), isTrue);
        expect(multi.userRole.contains('doctor'), isTrue);
      });

      test('social login user should have isSocialLogin true', () {
        final social = TestUserFactory.createSocialLoginUser();
        expect(social.isSocialLogin, isTrue);
        expect(social.loginType, 'google');
      });
    });
  });
}
