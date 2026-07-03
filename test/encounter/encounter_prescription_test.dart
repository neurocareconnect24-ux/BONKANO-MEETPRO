/// Encounter & Prescription Tests for Bonkano Meet Pro
///
/// Covers: Encounter CRUD, clinical details, prescriptions, invoicing
/// Bugs: B14, B15, B16, B17, B18, B19, B20, B21, B22
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/Encounter/model/encounters_list_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Encounter & Prescription Tests', () {
    // =========================================================
    // Encounter Model Parsing
    // =========================================================
    group('Encounter Model', () {
      test('should parse valid encounter list', () {
        final json = TestJsonFixtures.encounterListJson();
        final response = EncounterListRes.fromJson(json);

        expect(response.status, isTrue);
        expect(response.data.length, 2);
        expect(response.data[0].id, 1);
        expect(response.data[0].clinicId, 10);
        expect(response.data[0].doctorId, 1);
      });

      test('should handle empty encounter list', () {
        final json = {'status': true, 'data': [], 'message': 'No encounters'};
        final response = EncounterListRes.fromJson(json);

        expect(response.data, isEmpty);
      });

      test('encounter status should map int to bool correctly', () {
        // status: 1 → true (active), status: 0 → false (inactive)
        final activeJson = {'status': 1};
        final inactiveJson = {'status': 0};

        final active = EncounterElement.fromJson(activeJson);
        final inactive = EncounterElement.fromJson(inactiveJson);

        expect(active.status, isTrue);
        expect(inactive.status, isFalse);
      });
    });

    // =========================================================
    // BUG B14: Vendor sees all patients without clinic filter
    // File: add_encounter_controller.dart:133
    // =========================================================
    group('BUG B14: Patient Data Isolation', () {
      test('vendor patient filter should be scoped to clinic', () {
        final file = File('lib/screens/Encounter/add_encounter/add_encounter_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check if vendor role gets all patients unfiltered
        // The bug: vendor doesn't filter by clinic_id when fetching patients
        final vendorGetsAllPatients =
            content.contains('getPatientsList') ||
            content.contains('getPatients');

        if (vendorGetsAllPatients) {
          // Check that clinic filter is applied for ALL roles
          final hasClinicFilterForAll =
              !content.contains('EmployeeKeyConst.doctor') ||
              content.contains('clinicId') && content.contains('vendor');

          expect(hasClinicFilterForAll, isTrue,
              reason: 'BUG B14: Vendor can see ALL patients without clinic filter. '
                  'This violates patient data isolation. '
                  'File: add_encounter_controller.dart:133. '
                  'FIX: Apply clinic_id filter for ALL roles, not just doctors.');
        }
      });
    });

    // =========================================================
    // BUG B15: Encounter Dashboard shows stale data
    // File: encounter_dashboard_controller.dart:22
    // =========================================================
    group('BUG B15: Encounter Dashboard Freshness', () {
      test('encounter dashboard should refresh data from API', () {
        final file = File('lib/screens/Encounter/encounter_dashboard/encounter_dashboard_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check if onInit/onReady fetches fresh data
        final fetchesFreshData =
            content.contains('getEncounterDetail') ||
            content.contains('encounterDetail') ||
            content.contains('encounterDashboardDetail');

        expect(fetchesFreshData, isTrue,
            reason: 'BUG B15: Dashboard only shows passed argument data, never refreshes. '
                'If encounter was updated elsewhere, stale data is shown. '
                'File: encounter_dashboard_controller.dart:22. '
                'FIX: Call API to get fresh encounter data in onInit().');
      });
    });

    // =========================================================
    // BUG B16: Prescription ID always -1
    // =========================================================
    group('BUG B16: Prescription ID', () {
      test('new prescriptions should have proper ID handling', () {
        // Look for prescription model to verify default id
        final possiblePaths = [
          'lib/screens/Encounter/clinical_details/model/prescription_model.dart',
          'lib/screens/Encounter/add_encounter/model/prescription_model.dart',
          'lib/screens/Encounter/model/prescription_model.dart',
        ];

        File? prescriptionFile;
        for (final path in possiblePaths) {
          final f = File(path);
          if (f.existsSync()) {
            prescriptionFile = f;
            break;
          }
        }

        if (prescriptionFile == null) return;

        final content = prescriptionFile.readAsStringSync();

        // Check if prescription defaults to id = -1
        final defaultsToNegative =
            content.contains('id = -1') || content.contains('this.id = -1');

        // This is expected for new prescriptions, but the bug is that
        // edited prescriptions also get -1 and become duplicates
        if (defaultsToNegative) {
          // Verify that edit flow preserves the server-assigned ID
          final preservesId = content.contains('fromJson') &&
              content.contains("json['id']");

          expect(preservesId, isTrue,
              reason: 'BUG B16: Prescription model should preserve server ID from fromJson. '
                  'New prescriptions default to -1 which is OK, but edits must keep server ID. '
                  'FIX: Ensure clinical_details_controller preserves ID when loading from server.');
        }
      });
    });

    // =========================================================
    // BUG B17: Service price not frozen at billing time
    // File: invoice_details_controller.dart:162
    // =========================================================
    group('BUG B17: Billing Price Integrity', () {
      test('service price should be frozen when added to invoice', () {
        final file = File('lib/screens/Encounter/invoice_details/invoice_details_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check if billing item captures price at time of addition
        // vs referencing live service price
        final capturesPrice =
            content.contains('serviceAmount') &&
            content.contains('BillingItem');

        // The issue is whether this price can change later
        // Check for any re-calculation pattern
        final recalculatesLater =
            content.contains('selectService.value.') &&
            content.contains('billingItem');

        if (capturesPrice && recalculatesLater) {
          // Should be capturing a snapshot, not a reference
          expect(recalculatesLater, isFalse,
              reason: 'BUG B17: Invoice references live service price instead of snapshot. '
                  'File: invoice_details_controller.dart:162. '
                  'FIX: Copy price value at time of addition, do not reference live object.');
        }
      });
    });

    // =========================================================
    // BUG B18: Discount applied from wrong service
    // File: invoice_details_controller.dart:171-173
    // =========================================================
    group('BUG B18: Per-Item Discount', () {
      test('discount should be per billing item, not from current selection', () {
        final file = File('lib/screens/Encounter/invoice_details/invoice_details_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        // Check if discount is copied from selectService (bug)
        // vs being specific to each billing item
        final copiesFromCurrentSelection =
            content.contains('selectService.value.discountType') ||
            content.contains('selectService.value.discountValue') ||
            content.contains('selectService.value.discountAmount');

        expect(copiesFromCurrentSelection, isFalse,
            reason: 'BUG B18: Discount copied from currently selected service '
                'to ALL billing items on save. Editing item B changes discount on item A. '
                'File: invoice_details_controller.dart:171-173. '
                'FIX: Each BillingItem should store its own discount at creation time.');
      });
    });

    // =========================================================
    // BUG B19: Add Prescription shows "Edit" title
    // File: add_prescription_component.dart:35
    // =========================================================
    group('BUG B19: Prescription Dialog Title', () {
      test('add vs edit title should use different locale strings', () {
        final possiblePaths = [
          'lib/screens/Encounter/clinical_details/components/add_prescription_component.dart',
          'lib/screens/Encounter/components/add_prescription_component.dart',
        ];

        File? file;
        for (final path in possiblePaths) {
          final f = File(path);
          if (f.existsSync()) {
            file = f;
            break;
          }
        }

        if (file == null) return;

        final content = file.readAsStringSync();

        // Check for the bug: both branches use editPrescription
        final hasDuplicateTitle = RegExp(
            r'isEdit\s*\?\s*locale\.value\.editPrescription\s*:\s*locale\.value\.editPrescription',
        ).hasMatch(content);

        expect(hasDuplicateTitle, isFalse,
            reason: 'BUG B19: Both add and edit branches show "Edit Prescription" title. '
                'File: add_prescription_component.dart:35. '
                'FIX: Use locale.value.addPrescription for the add case.');
      });
    });

    // =========================================================
    // BUG B20: Temp files never cleaned
    // File: body_chart_controller.dart:161,184
    // =========================================================
    group('BUG B20: Temporary File Cleanup', () {
      test('body chart controller should clean up temp files', () {
        final file = File('lib/screens/Encounter/body_chart/body_chart_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final createsTemp = content.contains('getTemporaryDirectory') ||
            content.contains('writeAsBytes') ||
            content.contains('File(');

        if (createsTemp) {
          final cleansUp = content.contains('delete()') ||
              content.contains('deleteSync') ||
              content.contains('cleanup') ||
              content.contains('clearTemp');

          expect(cleansUp, isTrue,
              reason: 'BUG B20: Temp files created for body chart images are never cleaned. '
                  'Files accumulate over time consuming device storage. '
                  'File: body_chart_controller.dart:161,184. '
                  'FIX: Delete temp files in onClose() or after successful upload.');
        }
      });
    });

    // =========================================================
    // BUG B21: Hard delete encounters
    // File: all_encounters_controller.dart:80
    // =========================================================
    group('BUG B21: Encounter Deletion Safety', () {
      test('encounter delete should have confirmation dialog', () {
        final file = File('lib/screens/Encounter/all_encounters_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final hasDeleteConfirmation =
            content.contains('showConfirmDialog') ||
            content.contains('AlertDialog') ||
            content.contains('showDialog') ||
            content.contains('confirmDialog');

        expect(hasDeleteConfirmation, isTrue,
            reason: 'BUG B21: Encounter deletion is permanent without undo. '
                'At minimum, a confirmation dialog is required. '
                'File: all_encounters_controller.dart:80. '
                'FIX: Add confirmation dialog and consider soft-delete.');
      });
    });

    // =========================================================
    // BUG B22: No file type/size validation for medical reports
    // File: add_medical_report_controller.dart:143
    // =========================================================
    group('BUG B22: Medical Report File Validation', () {
      test('should validate file type and size before upload', () {
        final file = File('lib/screens/Encounter/medical_Report/add_medical_report_controller.dart');
        if (!file.existsSync()) return;

        final content = file.readAsStringSync();

        final validatesFileType = content.contains('extension') ||
            content.contains('mimeType') ||
            content.contains('allowedExtensions') ||
            content.contains('type: FileType');

        final validatesFileSize = content.contains('lengthSync') ||
            content.contains('size') ||
            content.contains('maxFileSize') ||
            content.contains('bytes');

        expect(validatesFileType, isTrue,
            reason: 'BUG B22: No file type validation for medical report uploads. '
                'Any file can be uploaded. '
                'File: add_medical_report_controller.dart:143. '
                'FIX: Restrict to PDF, JPG, PNG. Validate MIME type.');

        expect(validatesFileSize, isTrue,
            reason: 'BUG B22: No file size validation for medical report uploads. '
                'FIX: Add max size limit (e.g., 10MB).');
      });
    });

    // =========================================================
    // Encounter Data Integrity
    // =========================================================
    group('Encounter Data Integrity', () {
      test('encounter should have all required IDs positive', () {
        final encounter = TestEncounterFactory.create();

        expect(encounter.id, greaterThan(0));
        expect(encounter.userId, greaterThan(0));
        expect(encounter.clinicId, greaterThan(0));
        expect(encounter.doctorId, greaterThan(0));
      });

      test('encounter with -1 IDs should be invalid', () {
        final invalid = TestEncounterFactory.createWithInvalidIds();

        expect(invalid.id, lessThan(0));
        expect(invalid.userId, lessThan(0));
        expect(invalid.clinicId, lessThan(0));
      });

      test('encounter date should not be empty for valid encounters', () {
        final encounter = TestEncounterFactory.create();
        expect(encounter.encounterDate.isNotEmpty, isTrue);
      });
    });
  });
}
