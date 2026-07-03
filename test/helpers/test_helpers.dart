/// Test helpers and mocks for Bonkano Meet Pro tests
///
/// Provides factory methods for creating test data objects
/// and mock utilities used across all test files.
library;

import 'package:bonkano_meet_pro/screens/auth/model/login_response.dart';
import 'package:bonkano_meet_pro/screens/Encounter/model/encounters_list_model.dart';
import 'package:bonkano_meet_pro/screens/appointment/model/agora_token_res_model.dart';

/// Factory for creating test UserData objects
class TestUserFactory {
  static UserData createDoctor({
    int id = 1,
    String email = 'doctor@test.com',
    String apiToken = 'test-token-123',
    int clinicId = 10,
  }) {
    return UserData(
      id: id,
      firstName: 'Dr',
      lastName: 'Test',
      userName: 'Dr Test',
      email: email,
      apiToken: apiToken,
      userRole: ['doctor'],
      userType: 'doctor',
      loginType: 'user',
      isSocialLogin: false,
      mobile: '+22901234567',
      gender: 'male',
    );
  }

  static UserData createVendor({
    int id = 2,
    String email = 'vendor@test.com',
    String apiToken = 'vendor-token-123',
  }) {
    return UserData(
      id: id,
      firstName: 'Vendor',
      lastName: 'Test',
      userName: 'Vendor Test',
      email: email,
      apiToken: apiToken,
      userRole: ['vendor'],
      userType: 'vendor',
      loginType: 'user',
      isSocialLogin: false,
    );
  }

  static UserData createReceptionist({
    int id = 3,
    String email = 'receptionist@test.com',
    String apiToken = 'recep-token-123',
  }) {
    return UserData(
      id: id,
      firstName: 'Receptionist',
      lastName: 'Test',
      userName: 'Receptionist Test',
      email: email,
      apiToken: apiToken,
      userRole: ['receptionist'],
      userType: 'receptionist',
      loginType: 'user',
      isSocialLogin: false,
    );
  }

  static UserData createSocialLoginUser({
    String loginType = 'google',
  }) {
    return UserData(
      id: 4,
      firstName: 'Social',
      lastName: 'User',
      userName: 'Social User',
      email: 'social@gmail.com',
      apiToken: 'social-token-456',
      userRole: ['doctor'],
      userType: 'doctor',
      loginType: loginType,
      isSocialLogin: true,
    );
  }

  static UserData createMultiRoleUser() {
    return UserData(
      id: 5,
      firstName: 'Multi',
      lastName: 'Role',
      userName: 'Multi Role',
      email: 'multi@test.com',
      apiToken: 'multi-token-789',
      userRole: ['vendor', 'doctor'],
      userType: 'vendor',
      loginType: 'user',
      isSocialLogin: false,
    );
  }

  static UserData createInvalidUser() {
    return UserData(
      id: -1,
      firstName: '',
      lastName: '',
      email: '',
      apiToken: '',
      userRole: [],
      userType: '',
    );
  }
}

/// Factory for creating test EncounterElement objects
class TestEncounterFactory {
  static EncounterElement create({
    int id = 1,
    int userId = 100,
    int clinicId = 10,
    int doctorId = 1,
    bool status = true,
    String encounterDate = '2026-03-21',
  }) {
    return EncounterElement(
      id: id,
      encounterDate: encounterDate,
      userId: userId,
      userName: 'Patient Test',
      userEmail: 'patient@test.com',
      userPhone: '+22900000000',
      clinicId: clinicId,
      clinicName: 'Test Clinic',
      doctorId: doctorId,
      doctorName: 'Dr Test',
      description: 'Test encounter',
      status: status,
    );
  }

  static EncounterElement createWithInvalidIds() {
    return EncounterElement(
      id: -1,
      userId: -1,
      clinicId: -1,
      doctorId: -1,
    );
  }
}

/// Factory for creating test AgoraTokenRes objects
class TestAgoraFactory {
  static AgoraTokenRes createValid() {
    return AgoraTokenRes(
      status: true,
      token: 'agora-test-token-abc123',
      channelName: 'test-channel-001',
      uid: 12345,
      message: 'Token generated successfully',
    );
  }

  static AgoraTokenRes createEmpty() {
    return AgoraTokenRes(
      status: false,
      token: '',
      channelName: '',
      uid: 0,
      message: 'Failed to generate token',
    );
  }

  static AgoraTokenRes createExpired() {
    return AgoraTokenRes(
      status: true,
      token: 'expired-token',
      channelName: 'test-channel-expired',
      uid: 99999,
      message: 'Token expired',
    );
  }
}

/// JSON fixtures for API response testing
class TestJsonFixtures {
  static Map<String, dynamic> loginSuccessJson({
    String role = 'doctor',
    int clinicId = 10,
  }) {
    return {
      'status': true,
      'message': 'Login successful',
      'data': {
        'id': 1,
        'first_name': 'Dr',
        'last_name': 'Test',
        'user_name': 'Dr Test',
        'email': 'doctor@test.com',
        'mobile': '+22901234567',
        'gender': 'male',
        'user_role': [role],
        'api_token': 'fresh-api-token-xyz',
        'profile_image': '',
        'login_type': 'user',
        'is_social_login': false,
        'user_type': role,
        'address': '123 Test St',
        'city': 'Cotonou',
        'state': 'Littoral',
        'country': 'Benin',
        'pinCode': '00229',
        'date_of_birth': '1985-06-15',
        'selected_clinic': {
          'id': clinicId,
          'clinic_name': 'NeuroCare Clinic',
        },
      },
    };
  }

  static Map<String, dynamic> loginFailureJson() {
    return {
      'status': false,
      'message': 'Invalid credentials',
      'data': null,
    };
  }

  static Map<String, dynamic> encounterListJson() {
    return {
      'status': true,
      'message': 'Encounters fetched successfully',
      'data': [
        {
          'id': 1,
          'encounter_date': '2026-03-21',
          'user_id': 100,
          'user_name': 'Patient One',
          'user_email': 'patient1@test.com',
          'user_phone': '+22900000001',
          'clinic_id': 10,
          'clinic_name': 'NeuroCare Clinic',
          'doctor_id': 1,
          'doctor_name': 'Dr Test',
          'appointment_id': 50,
          'description': 'Follow-up consultation',
          'status': 1,
        },
        {
          'id': 2,
          'encounter_date': '2026-03-20',
          'user_id': 101,
          'user_name': 'Patient Two',
          'user_email': 'patient2@test.com',
          'user_phone': '+22900000002',
          'clinic_id': 10,
          'clinic_name': 'NeuroCare Clinic',
          'doctor_id': 1,
          'doctor_name': 'Dr Test',
          'appointment_id': 51,
          'description': 'Initial consultation',
          'status': 0,
        },
      ],
    };
  }

  static Map<String, dynamic> agoraTokenJson() {
    return {
      'status': true,
      'message': 'Token generated',
      'data': {
        'token': 'agora-live-token-xyz',
        'channel_name': 'appointment-42-channel',
        'uid': 54321,
      },
    };
  }

  static Map<String, dynamic> agoraTokenNestedJson() {
    return {
      'status': true,
      'message': 'Token generated',
      'data': {
        'token': 'nested-agora-token',
        'channel_name': 'nested-channel',
        'uid': 11111,
      },
    };
  }

  static Map<String, dynamic> agoraTokenFlatJson() {
    return {
      'status': true,
      'message': 'Token generated',
      'token': 'flat-agora-token',
      'channel_name': 'flat-channel',
      'uid': 22222,
    };
  }
}
