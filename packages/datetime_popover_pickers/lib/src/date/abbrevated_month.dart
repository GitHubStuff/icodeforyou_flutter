// packages/mypickdf/lib/src/abbreviated_month_cupertino_localizations.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

/// [CupertinoLocalizations] that renders date-picker months as three-letter
/// abbreviations (`Jan` … `Dec`) instead of full names.
///
/// Scope it to a single picker with [Localizations.override]:
///
/// ```dart
/// Localizations.override(
///   context: context,
///   delegates: const [AbbreviatedMonthCupertinoLocalizations.delegate],
///   child: CupertinoDatePicker(...),
/// )
/// ```
class AbbreviatedMonth extends DefaultCupertinoLocalizations {
  /// Creates an [AbbreviatedMonth()].
  const AbbreviatedMonth();

  /// Delegate that installs this localization for English locales.
  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _AbbreviatedMonthCupertinoLocalizationsDelegate();

  static const List<String> _abbreviatedMonths = [
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

  @override
  String datePickerMonth(int monthIndex) => _abbreviatedMonths[monthIndex - 1];

  @override
  String datePickerStandaloneMonth(int monthIndex) =>
      _abbreviatedMonths[monthIndex - 1];
}

class _AbbreviatedMonthCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AbbreviatedMonthCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const AbbreviatedMonth(),
      );

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<CupertinoLocalizations> old,
  ) => false;
}
