// packages/datetime_pickers/test/src/date/abbrevated_month_test.dart

import 'package:datetime_pickers/src/date/abbrevated_month.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AbbreviatedMonth', () {
    const localizations = AbbreviatedMonth();

    const expectedMonths = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    test(
      'datePickerMonth returns 3-letter abbreviation for each month (1..12)',
      () {
        for (var month = 1; month <= 12; month++) {
          expect(
            localizations.datePickerMonth(month),
            expectedMonths[month - 1],
          );
        }
      },
    );

    test(
      'datePickerStandaloneMonth returns 3-letter abbreviation for each month (1..12)',
      () {
        for (var month = 1; month <= 12; month++) {
          expect(
            localizations.datePickerStandaloneMonth(month),
            expectedMonths[month - 1],
          );
        }
      },
    );
  });

  group('AbbreviatedMonth.delegate', () {
    const delegate = AbbreviatedMonth.delegate;

    test(
      'isSupported returns true for English and false for other locales',
      () {
        expect(delegate.isSupported(const Locale('en')), isTrue);
        expect(delegate.isSupported(const Locale('en', 'US')), isTrue);
        expect(delegate.isSupported(const Locale('fr')), isFalse);
        expect(delegate.isSupported(const Locale('es', 'ES')), isFalse);
        expect(delegate.isSupported(const Locale('de')), isFalse);
      },
    );

    test(
      'load synchronously returns an instance of AbbreviatedMonth',
      () async {
        final result = await delegate.load(const Locale('en'));

        expect(result, isA<AbbreviatedMonth>());
        expect(result.datePickerMonth(1), 'Jan');
      },
    );

    test('shouldReload returns false', () {
      expect(delegate.shouldReload(delegate), isFalse);
      expect(
        delegate.shouldReload(
          DefaultCupertinoLocalizations.delegate,
        ),
        isFalse,
      );
    });
  });
}
