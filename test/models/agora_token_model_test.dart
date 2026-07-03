import 'package:flutter_test/flutter_test.dart';
import 'package:bonkano_meet_pro/screens/appointment/model/agora_token_res_model.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AgoraTokenRes Model', () {
    group('fromJson - nested data format', () {
      test('should parse token from data.token (nested)', () {
        final json = TestJsonFixtures.agoraTokenNestedJson();
        final result = AgoraTokenRes.fromJson(json);

        expect(result.status, isTrue);
        expect(result.token, 'nested-agora-token');
        expect(result.channelName, 'nested-channel');
        expect(result.uid, 11111);
      });
    });

    group('fromJson - flat format', () {
      test('should parse token from root level (flat)', () {
        final json = TestJsonFixtures.agoraTokenFlatJson();
        final result = AgoraTokenRes.fromJson(json);

        expect(result.status, isTrue);
        expect(result.token, 'flat-agora-token');
        expect(result.channelName, 'flat-channel');
        expect(result.uid, 22222);
      });
    });

    group('fromJson - edge cases', () {
      test('should handle empty/missing data gracefully', () {
        final json = <String, dynamic>{'status': false, 'message': 'Error'};
        final result = AgoraTokenRes.fromJson(json);

        expect(result.status, isFalse);
        expect(result.token, '');
        expect(result.channelName, '');
        expect(result.uid, 0);
      });

      test('should handle null values in data map', () {
        final json = <String, dynamic>{
          'status': true,
          'data': <String, dynamic>{
            'token': null,
            'channel_name': null,
            'uid': null,
          },
        };
        final result = AgoraTokenRes.fromJson(json);

        expect(result.token, '');
        expect(result.channelName, '');
        expect(result.uid, 0);
      });

      test('should handle wrong types in data map', () {
        final json = <String, dynamic>{
          'status': true,
          'data': <String, dynamic>{
            'token': 123,
            'channel_name': true,
            'uid': 'not_int',
          },
        };
        final result = AgoraTokenRes.fromJson(json);

        expect(result.token, '');
        expect(result.channelName, '');
        expect(result.uid, 0);
      });
    });

    group('Token Validation', () {
      test('valid token should have non-empty token and channelName', () {
        final valid = TestAgoraFactory.createValid();

        expect(valid.token.isNotEmpty, isTrue);
        expect(valid.channelName.isNotEmpty, isTrue);
        expect(valid.uid, greaterThan(0));
      });

      test('empty token should be detectable', () {
        final empty = TestAgoraFactory.createEmpty();

        expect(empty.token.isEmpty, isTrue);
        expect(empty.channelName.isEmpty, isTrue);
        expect(empty.status, isFalse);
      });

      test('BUG B10: token expiry not handled - token should carry expiry info', () {
        // This test documents that the model has no expiry field.
        // When token expires mid-call, onTokenPrivilegeWillExpire fires
        // but there's no refresh mechanism.
        final token = TestAgoraFactory.createValid();

        // No expiry field exists — this is a design gap
        // The model should ideally include: expiresAt, isExpired()
        expect(token.toJson().containsKey('expires_at'), isFalse,
            reason: 'BUG B10: AgoraTokenRes has no expiry tracking. '
                'onTokenPrivilegeWillExpire in video_call_controller.dart:142 '
                'only logs but does not refresh the token.');
      });
    });

    group('toJson', () {
      test('should serialize correctly', () {
        final original = TestAgoraFactory.createValid();
        final json = original.toJson();

        expect(json['status'], isTrue);
        expect(json['token'], original.token);
        expect(json['channel_name'], original.channelName);
        expect(json['uid'], original.uid);
      });
    });
  });
}
