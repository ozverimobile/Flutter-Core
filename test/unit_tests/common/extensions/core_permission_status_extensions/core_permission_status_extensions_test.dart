import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CorePermissionStatusExtensions Tests', () {
    group('isGranted', () {
      test('returns true for granted status', () {
        const status = CorePermissionStatus.granted;
        expect(status.isGranted, isTrue);
      });

      test('returns false for non-granted statuses', () {
        final nonGrantedStatuses = [
          CorePermissionStatus.permanentlyDenied,
          CorePermissionStatus.neverPrompted,
          CorePermissionStatus.postponed,
        ];

        for (final status in nonGrantedStatuses) {
          expect(status.isGranted, isFalse);
        }
      });
    });

    group('isPermanentlyDenied', () {
      test('returns true for permanentlyDenied status', () {
        const status = CorePermissionStatus.permanentlyDenied;
        expect(status.isPermanentlyDenied, isTrue);
      });

      test('returns false for non-permanentlyDenied statuses', () {
        final nonPermanentlyDeniedStatuses = [
          CorePermissionStatus.granted,
          CorePermissionStatus.neverPrompted,
          CorePermissionStatus.postponed,
        ];

        for (final status in nonPermanentlyDeniedStatuses) {
          expect(status.isPermanentlyDenied, isFalse);
        }
      });
    });

    group('isNeverPrompted', () {
      test('returns true for neverPrompted status', () {
        const status = CorePermissionStatus.neverPrompted;
        expect(status.isNeverPrompted, isTrue);
      });

      test('returns false for non-neverPrompted statuses', () {
        final nonNeverPromptedStatuses = [
          CorePermissionStatus.granted,
          CorePermissionStatus.permanentlyDenied,
          CorePermissionStatus.postponed,
        ];

        for (final status in nonNeverPromptedStatuses) {
          expect(status.isNeverPrompted, isFalse);
        }
      });
    });

    group('isPostponed', () {
      test('returns true for postponed status', () {
        const status = CorePermissionStatus.postponed;
        expect(status.isPostponed, isTrue);
      });

      test('returns false for non-postponed statuses', () {
        final nonPostponedStatuses = [
          CorePermissionStatus.granted,
          CorePermissionStatus.permanentlyDenied,
          CorePermissionStatus.neverPrompted,
        ];

        for (final status in nonPostponedStatuses) {
          expect(status.isPostponed, isFalse);
        }
      });
    });
  });

  group('Future<CorePermissionStatusExtensions> Test ', () {
    group('isGranted', () {
      test('returns true for granted status', () async {
        final status = Future.value(CorePermissionStatus.granted);
        expect(await status.isGranted, isTrue);
      });

      test('returns false for non-granted statuses', () async {
        final nonGrantedStatuses = [
          Future.value(CorePermissionStatus.permanentlyDenied),
          Future.value(CorePermissionStatus.neverPrompted),
          Future.value(CorePermissionStatus.postponed),
        ];

        for (final status in nonGrantedStatuses) {
          expect(await status.isGranted, isFalse);
        }
      });
    });

    group('isPermanentlyDenied', () {
      test('returns true for permanentlyDenied status', () async {
        final status = Future.value(CorePermissionStatus.permanentlyDenied);
        expect(await status.isPermanentlyDenied, isTrue);
      });

      test('returns false for non-permanentlyDenied statuses', () async {
        final nonPermanentlyDeniedStatuses = [
          Future.value(CorePermissionStatus.granted),
          Future.value(CorePermissionStatus.neverPrompted),
          Future.value(CorePermissionStatus.postponed),
        ];

        for (final status in nonPermanentlyDeniedStatuses) {
          expect(await status.isPermanentlyDenied, isFalse);
        }
      });
    });

    group('isNeverPrompted', () {
      test('returns true for neverPrompted status', () async {
        final status = Future.value(CorePermissionStatus.neverPrompted);
        expect(await status.isNeverPrompted, isTrue);
      });

      test('returns false for non-neverPrompted statuses', () async {
        final nonNeverPromptedStatuses = [
          Future.value(CorePermissionStatus.granted),
          Future.value(CorePermissionStatus.permanentlyDenied),
          Future.value(CorePermissionStatus.postponed),
        ];

        for (final status in nonNeverPromptedStatuses) {
          expect(await status.isNeverPrompted, isFalse);
        }
      });
    });

    group('isPostponed', () {
      test('returns true for postponed status', () async {
        final status = Future.value(CorePermissionStatus.postponed);
        expect(await status.isPostponed, isTrue);
      });

      test('returns false for non-postponed statuses', () async {
        final nonPostponedStatuses = [
          Future.value(CorePermissionStatus.granted),
          Future.value(CorePermissionStatus.permanentlyDenied),
          Future.value(CorePermissionStatus.neverPrompted),
        ];

        for (final status in nonPostponedStatuses) {
          expect(await status.isPostponed, isFalse);
        }
      });
    });
  });
}
