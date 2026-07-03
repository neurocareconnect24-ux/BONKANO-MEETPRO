import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/Encounter/model/encounters_list_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('EncounterElement Model', () {
    group('fromJson', () {
      test('should parse valid encounter list response', () {
        final json = TestJsonFixtures.encounterListJson();
        final response = EncounterListRes.fromJson(json);

        expect(response.status, isTrue);
        expect(response.data.length, 2);

        final first = response.data[0];
        expect(first.id, 1);
        expect(first.encounterDate, '2026-03-21');
        expect(first.userId, 100);
        expect(first.userName, 'Patient One');
        expect(first.clinicId, 10);
        expect(first.doctorId, 1);
        expect(first.status, isTrue); // status: 1 → true
      });

      test('should parse status 0 as false and 1 as true', () {
        final json = TestJsonFixtures.encounterListJson();
        final response = EncounterListRes.fromJson(json);

        expect(response.data[0].status, isTrue); // status: 1
        expect(response.data[1].status, isFalse); // status: 0
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{'status': true, 'data': [<String, dynamic>{}], 'message': ''};
        final response = EncounterListRes.fromJson(json);

        final encounter = response.data[0];
        expect(encounter.id, -1);
        expect(encounter.userId, -1);
        expect(encounter.clinicId, -1);
        expect(encounter.doctorId, -1);
        expect(encounter.encounterDate, '');
        expect(encounter.userName, '');
        expect(encounter.status, isFalse);
      });

      test('should handle null data list', () {
        final json = <String, dynamic>{'status': true, 'data': null, 'message': ''};
        final response = EncounterListRes.fromJson(json);
        expect(response.data, isEmpty);
      });

      test('should handle wrong types gracefully', () {
        final json = <String, dynamic>{
          'status': true,
          'data': [
            <String, dynamic>{
              'id': 'not_int',
              'user_id': 'not_int',
              'clinic_id': null,
              'status': 'not_int',
            }
          ],
        };
        final response = EncounterListRes.fromJson(json);

        final encounter = response.data[0];
        expect(encounter.id, -1);
        expect(encounter.userId, -1);
        expect(encounter.clinicId, -1);
        expect(encounter.status, isFalse);
      });
    });

    group('toJson', () {
      test('should serialize and deserialize roundtrip', () {
        final original = TestEncounterFactory.create(
          id: 42,
          userId: 100,
          clinicId: 10,
          doctorId: 1,
        );
        final json = original.toJson();
        final restored = EncounterElement.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.userId, original.userId);
        expect(restored.clinicId, original.clinicId);
        expect(restored.doctorId, original.doctorId);
        expect(restored.encounterDate, original.encounterDate);
        expect(restored.userName, original.userName);
      });
    });

    group('Default Values', () {
      test('should initialize with safe defaults (all IDs = -1)', () {
        final encounter = EncounterElement();

        expect(encounter.id, -1);
        expect(encounter.userId, -1);
        expect(encounter.clinicId, -1);
        expect(encounter.doctorId, -1);
        expect(encounter.appointmentId, -1);
        expect(encounter.status, isFalse);
      });
    });

    group('Data Integrity', () {
      test('encounter with invalid IDs should be detectable', () {
        final invalid = TestEncounterFactory.createWithInvalidIds();

        expect(invalid.id.isNegative, isTrue);
        expect(invalid.userId.isNegative, isTrue);
        expect(invalid.clinicId.isNegative, isTrue);
        expect(invalid.doctorId.isNegative, isTrue);
      });

      test('encounter with valid IDs should have positive values', () {
        final valid = TestEncounterFactory.create();

        expect(valid.id, greaterThan(0));
        expect(valid.userId, greaterThan(0));
        expect(valid.clinicId, greaterThan(0));
        expect(valid.doctorId, greaterThan(0));
      });
    });
  });
}
