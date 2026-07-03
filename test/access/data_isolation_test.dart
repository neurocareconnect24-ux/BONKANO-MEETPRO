/// Data Isolation & Role-Based Access Tests
///
/// Verifies that patient data, encounters, and medical records
/// are properly scoped by role and clinic.
/// Bugs: B14, B23, B24, B25
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/utils/constants.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Data Isolation & Role-Based Access Tests', () {
    // =========================================================
    // Role Definitions
    // =========================================================
    group('Role Constants Integrity', () {
      test('all three roles should be defined', () {
        expect(EmployeeKeyConst.vendor, isNotEmpty);
        expect(EmployeeKeyConst.doctor, isNotEmpty);
        expect(EmployeeKeyConst.receptionist, isNotEmpty);
      });

      test('roles should be distinct', () {
        expect(EmployeeKeyConst.vendor, isNot(EmployeeKeyConst.doctor));
        expect(EmployeeKeyConst.doctor, isNot(EmployeeKeyConst.receptionist));
        expect(EmployeeKeyConst.vendor, isNot(EmployeeKeyConst.receptionist));
      });
    });

    // =========================================================
    // Patient Data Access Control
    // =========================================================
    group('Patient Data Access', () {
      test('doctor should only see patients from selected clinic', () {
        final doctor = TestUserFactory.createDoctor();
        expect(doctor.userRole.contains(EmployeeKeyConst.doctor), isTrue);

        // Doctor's patient list should be filtered by clinic
        final file = File('lib/screens/patient/all_patient_list_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check that clinic filter is applied for doctors
        final hasClinicFilter = content.contains('selectedAppClinic.value.id') ||
            content.contains('clinicId');

        expect(hasClinicFilter, isTrue,
            reason: 'Doctor should only see patients from their selected clinic. '
                'FIX: Apply clinic_id filter in getPatientList().');
      });

      test('BUG B14: vendor should filter patients by managed clinics', () {
        final vendor = TestUserFactory.createVendor();
        expect(vendor.userRole.contains(EmployeeKeyConst.vendor), isTrue);

        // Even vendors should not see ALL patients globally
        // They should see patients from clinics they manage
        final file = File('lib/screens/Encounter/add_encounter/add_encounter_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check the patient fetching for encounter creation
        final vendorFiltersPatients = content.contains('vendor') &&
            content.contains('clinicId');

        expect(vendorFiltersPatients, isTrue,
            reason: 'BUG B14: Vendor can access all patients without clinic filter. '
                'File: add_encounter_controller.dart:133. '
                'FIX: Filter patients by vendor\'s managed clinic_id.');
      });
    });

    // =========================================================
    // Encounter Data Access Control
    // =========================================================
    group('Encounter Data Access', () {
      test('encounters should be filtered by clinic for doctors', () {
        final file = File('lib/screens/Encounter/all_encounters_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final hasClinicFilter = content.contains('selectedAppClinic.value.id') ||
            content.contains('clinicId');

        expect(hasClinicFilter, isTrue,
            reason: 'Encounters must be filtered by clinic for doctor role.');
      });
    });

    // =========================================================
    // BUG B23: Null crash in clinic_api.dart
    // File: clinic_api.dart:131
    // =========================================================
    group('BUG B23: Clinic API Null Safety', () {
      test('clinic image check should use && not ||', () {
        final file = File('lib/api/clinic_api.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Bug: if (imageFile != null || imageFile!.isNotEmpty)
        // Should be: if (imageFile != null && imageFile!.isNotEmpty)
        // The || causes crash when imageFile is null because imageFile! is evaluated
        final hasDangerousOr = RegExp(
            r'imageFile\s*!=\s*null\s*\|\|\s*imageFile!'
        ).hasMatch(content);

        expect(hasDangerousOr, isFalse,
            reason: 'BUG B23: CRITICAL - clinic_api.dart uses || instead of && '
                'in null check: "if (imageFile != null || imageFile!.isNotEmpty)". '
                'When imageFile is null, the force unwrap imageFile! crashes. '
                'File: clinic_api.dart:131. '
                'FIX: Change || to &&.');
      });
    });

    // =========================================================
    // BUG B24: Doctor form missing validations
    // File: add_doctor_form.dart
    // =========================================================
    group('BUG B24: Doctor Form Validations', () {
      test('add doctor should validate image, clinic, and service selection', () {
        final file = File('lib/screens/doctor/add_doctor/add_doctor_form.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check for image validation
        final validatesImage = content.contains('imageFile') &&
            (content.contains('isEmpty') || content.contains('isNotEmpty') ||
             content.contains('toast') && content.contains('image'));

        expect(validatesImage, isTrue,
            reason: 'BUG B24: Add Doctor form has no image validation. '
                'FIX: Require profile image before submission.');
      });
    });

    // =========================================================
    // BUG B25: Password pre-filled from localStorage on edit
    // File: add_doctor_controller.dart:166-172
    // =========================================================
    group('BUG B25: Password Security in Edit Mode', () {
      test('edit doctor should NOT pre-fill password from localStorage', () {
        final file = File('lib/screens/doctor/add_doctor/add_doctor_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final preFilsPassword = content.contains('USER_PASSWORD') &&
            content.contains('getValueFromLocal') &&
            content.contains('passwordCont');

        expect(preFilsPassword, isFalse,
            reason: 'BUG B25: Edit doctor pre-fills password from localStorage. '
                'This is a security issue — stored plaintext password exposed. '
                'File: add_doctor_controller.dart:166-172. '
                'FIX: Don\'t pre-fill password field. Require current password re-entry.');
      });
    });

    // =========================================================
    // API Header Authorization
    // =========================================================
    group('API Authorization Headers', () {
      test('network_utils should add Bearer token for authenticated requests', () {
        final file = File('lib/network/network_utils.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();

        final addsBearerToken = content.contains('Bearer') &&
            content.contains('apiToken') &&
            content.contains('authorizationHeader');

        expect(addsBearerToken, isTrue,
            reason: 'Authorization header must include Bearer token for authenticated requests.');
      });

      test('register endpoint should NOT require auth token', () {
        final file = File('lib/network/network_utils.dart');
        final content = file.readAsStringSync();

        // Register endpoint has special handling — no auth required
        final hasRegisterCheck = content.contains('APIEndPoints.register');

        expect(hasRegisterCheck, isTrue,
            reason: 'Register endpoint should be handled specially (no auth required).');
      });
    });

    // =========================================================
    // Service Access by Role
    // =========================================================
    group('Service Access Control', () {
      test('doctor should only see own services', () {
        final file = File('lib/screens/service/assing_doctor_screen_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final doctorFilter = content.contains('EmployeeKeyConst.doctor') &&
            (content.contains('removeWhere') || content.contains('where'));

        expect(doctorFilter, isTrue,
            reason: 'Doctor role should filter services to only show their own.');
      });
    });

    // =========================================================
    // Concurrent Request Protection
    // BUG B26
    // =========================================================
    group('BUG B26: Double-Click Protection', () {
      test('controllers should check isLoading before API calls', () {
        final criticalControllers = [
          'lib/screens/Encounter/add_encounter/add_encounter_controller.dart',
          'lib/screens/appointment/add_appointment/add_appointment_controller.dart',
          'lib/screens/doctor/add_doctor/add_doctor_controller.dart',
          'lib/screens/clinic/add_clinic_form/add_clinic_controller.dart',
        ];

        final missingGuards = <String>[];

        for (final path in criticalControllers) {
          final file = File(path);
          if (!file.existsSync()) continue;

          final content = file.readAsStringSync();

          // Check for isLoading guard at the start of save methods
          final hasLoadingGuard = content.contains('if (isLoading.value)') ||
              content.contains('isLoading.isTrue') ||
              content.contains('if (isLoading.value == true)');

          if (!hasLoadingGuard) {
            missingGuards.add(path);
          }
        }

        expect(missingGuards, isEmpty,
            reason: 'BUG B26: These controllers lack double-click protection:\n'
                '${missingGuards.join('\n')}\n'
                'FIX: Add "if (isLoading.value) return;" at start of save methods.');
      });
    });
  });
}
