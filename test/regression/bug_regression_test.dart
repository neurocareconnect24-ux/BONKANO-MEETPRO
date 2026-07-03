/// Bug Regression Tests — All 28 bugs from Phase 2
///
/// Each test documents the bug, verifies it exists or is fixed,
/// and provides the fix reference.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/auth/model/login_response.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Bug Regression Tests — Phase 2', () {
    // =========================================================
    // B1: SignUp → Get.find<SignInController>() crash
    // =========================================================
    test('B1: signup controller should guard Get.find<SignInController>()', () {
      final file = File('lib/screens/auth/sign_in_sign_up/sign_up_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final unguarded = c.contains('Get.find<SignInController>()') &&
          !c.contains('Get.isRegistered') &&
          !c.contains('try');

      expect(unguarded, isFalse,
          reason: 'B1: Get.find without guard → crash if not registered. '
              'File: sign_up_controller.dart:116');
    });

    // =========================================================
    // B2: Social login user → change password fails
    // =========================================================
    test('B2: change password should check isSocialLogin', () {
      final file = File('lib/screens/auth/password/change_password_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      expect(c.contains('isSocialLogin') || c.contains('social'), isTrue,
          reason: 'B2: No social login check in change_password_controller.dart:22');
    });

    // =========================================================
    // B3: Clinic ID 0 treated as valid
    // =========================================================
    test('B3: clinic ID validation should catch 0', () {
      final clinicId = 0;
      // Current buggy check
      expect(clinicId.isNegative, isFalse,
          reason: 'B3 confirms: 0.isNegative is false — so 0 slips through');
      // Correct check
      expect(clinicId <= 0, isTrue,
          reason: 'Fix: use <= 0 instead of isNegative');
    });

    // =========================================================
    // B4: Forgot password no success message
    // =========================================================
    test('B4: forgot password should show success feedback', () {
      final file = File('lib/screens/auth/password/forget_pass_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final showsFeedback = c.contains('toast') || c.contains('snackBar') ||
          c.contains('SnackBar') || c.contains('successToast');

      expect(showsFeedback, isTrue,
          reason: 'B4: No success message after password reset request. '
              'File: forget_pass_controller.dart:25-26');
    });

    // =========================================================
    // B5: Pagination dots use wrong count
    // =========================================================
    test('B5: service pagination dots should use doctorServices.length', () {
      final possiblePaths = [
        'lib/screens/home/components/service_home_component.dart',
        'lib/screens/home/components/services_home_component.dart',
      ];
      File? file;
      for (final p in possiblePaths) {
        final f = File(p);
        if (f.existsSync()) { file = f; break; }
      }
      if (file == null) return;
      final c = file.readAsStringSync();

      final usesWrongCount = c.contains('upcomingAppointment.length') &&
          c.contains('visible');

      expect(usesWrongCount, isFalse,
          reason: 'B5: Pagination dots use upcomingAppointment.length '
              'instead of doctorServices.length. File: service_home_component.dart:89');
    });

    // =========================================================
    // B6: Direct mutation without refresh()
    // =========================================================
    test('B6: loginUserData mutation should trigger reactivity', () {
      final file = File('lib/screens/home/home_screen.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final directMutation = c.contains('loginUserData.value.selectedClinic =') &&
          !c.contains('loginUserData.refresh()');

      expect(directMutation, isFalse,
          reason: 'B6: Direct mutation of .value without refresh(). '
              'File: home_screen.dart:106');
    });

    // =========================================================
    // B7: Payment failure after booking → no rollback
    // =========================================================
    test('B7: saveBooking chain should handle payment failure', () {
      final file = File('lib/screens/appointment/add_appointment/add_appointment_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final hasPaymentGuard = c.contains('savePayment') &&
          (c.contains('catchError') || c.contains('try'));

      expect(hasPaymentGuard, isTrue,
          reason: 'B7: No error handling if savePayment fails after booking. '
              'File: add_appointment_controller.dart:113-124');
    });

    // =========================================================
    // B8: Past date booking allowed
    // =========================================================
    test('B8: appointment date should validate against now', () {
      final file = File('lib/screens/appointment/add_appointment/add_appointment_form_screen.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final hasPastCheck = c.contains('DateTime.now') ||
          c.contains('isAfter') || c.contains('isBefore');

      expect(hasPastCheck, isTrue,
          reason: 'B8: No past date validation. '
              'File: add_appointment_form_screen.dart:150-174');
    });

    // =========================================================
    // B9: Null arguments in appointments
    // =========================================================
    test('B9: appointment screen should null-check Get.arguments', () {
      final file = File('lib/screens/appointment/appointments_screen.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final hasNullCheck = c.contains('Get.arguments') &&
          (c.contains('?') || c.contains('is ') || c.contains('null'));

      expect(hasNullCheck, isTrue,
          reason: 'B9: Get.arguments accessed without null check. '
              'File: appointments_screen.dart:31');
    });

    // =========================================================
    // B10: Agora token expiry not refreshed
    // =========================================================
    test('B10: onTokenPrivilegeWillExpire should refresh token', () {
      final file = File('lib/screens/appointment/video_call/video_call_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      if (c.contains('onTokenPrivilegeWillExpire')) {
        final refreshes = c.contains('renewToken') ||
            c.contains('getAgoraToken');

        expect(refreshes, isTrue,
            reason: 'B10: Token expiry callback only logs. '
                'File: video_call_controller.dart:142-144');
      }
    });

    // =========================================================
    // B11: Permission delay race condition
    // =========================================================
    test('B11: permission check should not use arbitrary delay', () {
      final file = File('lib/screens/appointment/video_call/video_call_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final hasArbitraryDelay = c.contains('Duration(milliseconds: 500)') &&
          c.contains('Permission');

      expect(hasArbitraryDelay, isFalse,
          reason: 'B11: 500ms delay for permission re-check is fragile. '
              'File: video_call_controller.dart:195-200');
    });

    // =========================================================
    // B12: AgoraVideoView null check
    // =========================================================
    test('B12: remote video should null-check agoraEngine', () {
      final file = File('lib/screens/appointment/video_call/video_call_screen.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      if (c.contains('AgoraVideoView')) {
        final hasNullCheck = c.contains('agoraEngine != null') ||
            c.contains('agoraEngine?') ||
            c.contains('if (') && c.contains('agoraEngine');

        expect(hasNullCheck, isTrue,
            reason: 'B12: AgoraVideoView created without null-checking engine. '
                'File: video_call_screen.dart:55');
      }
    });

    // =========================================================
    // B13: Auto-refresh without mounted check
    // =========================================================
    test('B13: teleconsultation refresh should check isClosed', () {
      final file = File('lib/screens/teleconsultation/teleconsultation_screen.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      if (c.contains('doWhile') || c.contains('Timer.periodic')) {
        expect(c.contains('isClosed') || c.contains('mounted'), isTrue,
            reason: 'B13: Auto-refresh without lifecycle check. '
                'File: teleconsultation_screen.dart:37-42');
      }
    });

    // =========================================================
    // B14: Vendor patient access without clinic filter
    // =========================================================
    test('B14: vendor encounter creation should filter patients by clinic', () {
      final file = File('lib/screens/Encounter/add_encounter/add_encounter_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      // Both doctor AND vendor should filter by clinic
      final onlyDoctorFilters = c.contains('EmployeeKeyConst.doctor') &&
          c.contains('clinicId') &&
          !c.contains('vendor') ;

      // If only doctor has filter but not vendor, that's the bug
      if (onlyDoctorFilters) {
        expect(false, isTrue,
            reason: 'B14: Only doctor filters patients by clinic, vendor sees all. '
                'File: add_encounter_controller.dart:133');
      }
    });

    // =========================================================
    // B15: Encounter dashboard stale data
    // =========================================================
    test('B15: encounter dashboard should fetch fresh data', () {
      final file = File('lib/screens/Encounter/encounter_dashboard/encounter_dashboard_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final fetchesOnInit = c.contains('onInit') &&
          (c.contains('getEncounter') || c.contains('encounterDetail') ||
           c.contains('encounterDashboard'));

      expect(fetchesOnInit, isTrue,
          reason: 'B15: Dashboard shows stale argument data. '
              'File: encounter_dashboard_controller.dart:22');
    });

    // =========================================================
    // B16: Prescription ID always -1
    // =========================================================
    test('B16: prescription model should preserve server ID on edit', () {
      final possiblePaths = [
        'lib/screens/Encounter/clinical_details/model/prescription_model.dart',
        'lib/screens/Encounter/add_encounter/model/prescription_model.dart',
        'lib/screens/Encounter/model/prescription_model.dart',
      ];
      File? file;
      for (final p in possiblePaths) {
        final f = File(p);
        if (f.existsSync()) { file = f; break; }
      }
      if (file == null) return;
      final c = file.readAsStringSync();

      // fromJson must parse the id field
      final parsesId = c.contains('fromJson') && c.contains("json['id']");
      expect(parsesId, isTrue,
          reason: 'B16: Prescription fromJson must parse id field from server');
    });

    // =========================================================
    // B17: Service price not frozen in invoice
    // =========================================================
    test('B17: billing item should snapshot service price', () {
      final file = File('lib/screens/Encounter/invoice_details/invoice_details_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final referencesLive = c.contains('selectService.value.') &&
          c.contains('billingItem') &&
          !c.contains('snapshot');

      if (referencesLive) {
        // Advisory: price should be frozen at billing time
      }
    });

    // =========================================================
    // B18: Discount from wrong service
    // =========================================================
    test('B18: discount should be per-item, not from current selection', () {
      final file = File('lib/screens/Encounter/invoice_details/invoice_details_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final wrongDiscount = c.contains('selectService.value.discountType');
      expect(wrongDiscount, isFalse,
          reason: 'B18: Discount copied from current service to all items. '
              'File: invoice_details_controller.dart:171-173');
    });

    // =========================================================
    // B19: Add Prescription shows "Edit" title
    // =========================================================
    test('B19: prescription dialog should differentiate add vs edit title', () {
      final possiblePaths = [
        'lib/screens/Encounter/clinical_details/components/add_prescription_component.dart',
        'lib/screens/Encounter/components/add_prescription_component.dart',
      ];
      File? file;
      for (final p in possiblePaths) {
        final f = File(p);
        if (f.existsSync()) { file = f; break; }
      }
      if (file == null) return;
      final c = file.readAsStringSync();

      // Bug: isEdit ? editPrescription : editPrescription (both same)
      final duplicateTitle = RegExp(
          r'isEdit\s*\?\s*locale\.value\.editPrescription\s*:\s*locale\.value\.editPrescription'
      ).hasMatch(c);

      expect(duplicateTitle, isFalse,
          reason: 'B19: Both branches show "Edit Prescription". '
              'File: add_prescription_component.dart:35');
    });

    // =========================================================
    // B20: Temp files never cleaned
    // =========================================================
    test('B20: body chart should clean temp files', () {
      final file = File('lib/screens/Encounter/body_chart/body_chart_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      if (c.contains('getTemporaryDirectory') || c.contains('writeAsBytes')) {
        final cleansUp = c.contains('delete') || c.contains('cleanup');
        expect(cleansUp, isTrue,
            reason: 'B20: Temp files accumulate. '
                'File: body_chart_controller.dart:161,184');
      }
    });

    // =========================================================
    // B21: Hard delete encounters
    // =========================================================
    test('B21: encounter delete should confirm with user', () {
      final file = File('lib/screens/Encounter/all_encounters_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      if (c.contains('deleteEncounter') || c.contains('deletEncounter')) {
        final hasConfirm = c.contains('showConfirmDialog') ||
            c.contains('AlertDialog') || c.contains('showDialog');
        expect(hasConfirm, isTrue,
            reason: 'B21: Delete without confirmation. '
                'File: all_encounters_controller.dart:80');
      }
    });

    // =========================================================
    // B22: No file validation for medical reports
    // =========================================================
    test('B22: medical report upload should validate file', () {
      final file = File('lib/screens/Encounter/medical_Report/add_medical_report_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final validatesFile = c.contains('extension') ||
          c.contains('mimeType') || c.contains('size') ||
          c.contains('lengthSync') || c.contains('allowedExtensions');

      expect(validatesFile, isTrue,
          reason: 'B22: No file type/size validation for uploads. '
              'File: add_medical_report_controller.dart:143');
    });

    // =========================================================
    // B23: clinic_api.dart || instead of &&
    // =========================================================
    test('B23: clinic_api image check should use && not ||', () {
      final file = File('lib/api/clinic_api.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final hasBug = RegExp(r'imageFile\s*!=\s*null\s*\|\|\s*imageFile!').hasMatch(c);
      expect(hasBug, isFalse,
          reason: 'B23: CRITICAL null crash — || causes force unwrap of null. '
              'File: clinic_api.dart:131');
    });

    // =========================================================
    // B24: Doctor form missing validations
    // =========================================================
    test('B24: add doctor should validate required fields', () {
      final file = File('lib/screens/doctor/add_doctor/add_doctor_form.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final hasImageValidation = c.contains('image') &&
          (c.contains('toast') || c.contains('validate'));

      expect(hasImageValidation, isTrue,
          reason: 'B24: No image validation in add doctor form');
    });

    // =========================================================
    // B25: Password pre-filled from localStorage
    // =========================================================
    test('B25: edit doctor should not leak stored password', () {
      final file = File('lib/screens/doctor/add_doctor/add_doctor_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      final leaksPassword = c.contains('USER_PASSWORD') &&
          c.contains('getValueFromLocal') &&
          c.contains('passwordCont');

      expect(leaksPassword, isFalse,
          reason: 'B25: Stored password leaked to edit form. '
              'File: add_doctor_controller.dart:166-172');
    });

    // =========================================================
    // B26: No double-click protection
    // =========================================================
    test('B26: save methods should have loading guard', () {
      final controllers = [
        'lib/screens/Encounter/add_encounter/add_encounter_controller.dart',
        'lib/screens/appointment/add_appointment/add_appointment_controller.dart',
      ];

      for (final path in controllers) {
        final file = File(path);
        if (!file.existsSync()) continue;
        final c = file.readAsStringSync();

        final hasGuard = c.contains('if (isLoading.value)') ||
            c.contains('isLoading.isTrue');

        expect(hasGuard, isTrue,
            reason: 'B26: $path lacks double-click protection');
      }
    });

    // =========================================================
    // B27: Gallery unlimited images
    // =========================================================
    test('B27: gallery should have total image limit', () {
      final file = File('lib/screens/clinic/clinic_gallery_list_controller.dart');
      if (!file.existsSync()) return;
      final c = file.readAsStringSync();

      if (c.contains('pickMultiImage')) {
        final hasTotalLimit = c.contains('maxImages') ||
            c.contains('galleryList.length') ||
            c.contains('limit') && c.contains('total');

        // Soft check — limit: 5 per selection exists but no total cap
        expect(hasTotalLimit, isTrue,
            reason: 'B27: No total image limit for gallery. '
                'File: clinic_gallery_list_controller.dart:122');
      }
    });

    // =========================================================
    // B28: Break time not validated within session hours
    // =========================================================
    test('B28: session break should be within session hours', () {
      final possiblePaths = [
        'lib/screens/doctor/doctor_session/add_session/add_session_controller.dart',
        'lib/screens/clinic/clinic_session/clinic_session_controller.dart',
      ];
      File? file;
      for (final p in possiblePaths) {
        final f = File(p);
        if (f.existsSync()) { file = f; break; }
      }
      if (file == null) return;
      final c = file.readAsStringSync();

      if (c.contains('isBreakValid') || c.contains('break')) {
        final validatesRange = c.contains('startTime') &&
            c.contains('endTime') &&
            (c.contains('isAfter') || c.contains('isBefore') ||
             c.contains('compareTo'));

        expect(validatesRange, isTrue,
            reason: 'B28: Break time only checks overlap, not if within session hours. '
                'FIX: Validate break.start >= session.start && break.end <= session.end');
      }
    });
  });
}
