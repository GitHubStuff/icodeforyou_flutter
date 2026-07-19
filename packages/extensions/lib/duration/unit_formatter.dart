/// {@template unit_formatter_library}
/// A tiny formatting DSL for rendering a single duration unit value.
///
/// The formatter takes one non-negative [int] and a template string, formats
/// the FIRST `%...q` token against that value, and returns the formatted prefix
/// followed by the remainder of the template untouched. Text before the token
/// is copied verbatim (with `%%` -> `%`); everything after the token is returned
/// raw, so a caller can feed the tail back in with the next value to render a
/// multi-unit display one token at a time.
/// {@endtemplate}
library;

// Reserved structural characters.
const String _kPercent = '%';
const String _kPipe = '|';

// Token flags / markers.
const String _kSuppress = '*';
const String _kSeparatorFlag = '_';
const String _kGroupedFlag = 'g';
const String _kZeroPadFlag = '0';
const String _kPrecisionDot = '.';
const String _kPluralityMarker = 't';

// Recognized unit letters. The letter is presentation sugar only: the formatter
// never inspects which unit it is.
const Set<String> _kUnitLetters = <String>{
  'Y', // years
  'M', // months
  'W', // weeks
  'D', // days
  'H', // hours
  'm', // minutes
  's', // seconds
  'S', // milliseconds
  'u', // microseconds
};

const int _kGroupSize = 3;
const int _kZeroCodeUnit = 0x30;
const int _kNineCodeUnit = 0x39;

/// A parsed plurality token: which arm to emit for singular vs. plural.
class _Plurality {
  const _Plurality(this.singular, this.plural);

  final String singular;
  final String plural;
}

/// The fully parsed presentation flags of a single `%...q` token.
class _TokenSpec {
  const _TokenSpec({
    required this.suppress,
    required this.separator,
    required this.grouped,
    required this.zeroPad,
    required this.width,
    required this.precision,
    required this.plurality,
  });

  /// `*` — render `''` when the value is `0`.
  final bool suppress;

  /// `_c` — the thousands separator character, or `null` for none.
  final String? separator;

  /// `g` — whether zero-pad fill participates in grouping. Defaults to `false`
  /// (ungrouped pad); the value's own digits are always grouped when a
  /// [separator] is present.
  final bool grouped;

  /// `0` — left-pad with zeros (ignored when [precision] is set, per C).
  final bool zeroPad;

  /// `n` — minimum field width.
  final int? width;

  /// `.m` — minimum number of digits (zero-filled).
  final int? precision;

  /// `t|singular|plural|q` — the plurality arms, or `null` for a numeric token.
  final _Plurality? plurality;
}

/// {@template unit_formatter}
/// Formats a single integer value into a display string using a compact,
/// `printf`/`sprintf`-inspired DSL.
///
/// One call formats one value into the first `%...q` token found in the
/// template, then returns the formatted prefix plus the rest of the template
/// untouched. A multi-unit display (e.g. `3y 2mo 5d`) is built by calling again
/// on the returned tail with the next value, until no token remains. The
/// formatter renders — it never computes; deciding the per-unit values is the
/// caller's responsibility.
///
/// ## Grammar
///
/// Everything between `%` and the trailing unit letter is optional presentation
/// sugar:
///
/// ```text
/// % [*] [_c] [g] [0] [n[.m]] ( q | t|singular|plural|q )
/// ```
///
/// - `*` — suppress: emit `''` when the value is `0`.
/// - `_c` — group thousands using literal character `c` (e.g. `_,` -> `1,000`,
///   `_^` -> `1^000`). `c` may be any single character.
/// - `g` — group the zero-pad fill too (an edge case). Without it the value is
///   still grouped, but padding zeros are not — this ungrouped pad is the
///   default. With `g`, width counts digits; without it, width counts
///   characters.
/// - `0` — pad with leading zeros instead of spaces.
/// - `n` — minimum field width; `.m` — minimum digit count (zero-filled).
/// - `q` — a unit letter (`Y M W D H m s S u`), ignored except for validation.
/// - `t|singular|plural|q` — plurality: emit `singular` when the value is `1`,
///   otherwise `plural`. Inside the arms, `%%` -> `%` and `%|` -> `|` are the
///   only valid escapes.
///
/// ## Sign
///
/// [doFormat] expects a **non-negative** value. In debug builds a negative value
/// trips an assertion; in release builds the value is coerced with [int.abs].
/// The sign is *dropped*, never rendered — directionality (before / now / after)
/// is the caller's concern, expressed with a `t` token or surrounding literal
/// text.
///
/// ## C fallback
///
/// Where the grammar is silent, behavior follows C's `printf`. In particular,
/// specifying `.m` precision suppresses the `0` flag (width is space-padded).
/// {@endtemplate}
class UnitFormatter {
  /// {@macro unit_formatter}
  const UnitFormatter();

  /// {@template unit_formatter_do_format}
  /// Formats [on] into the first `%...q` token found in [using], then appends
  /// the remainder of [using] untouched.
  ///
  /// Text before the token is copied verbatim, with `%%` -> `%`. Everything from
  /// the end of the formatted token onward is returned raw — including any `%%`
  /// and any further tokens — so the result can be fed back in with the next
  /// value to render successive units.
  ///
  /// ```dart
  /// const f = UnitFormatter();
  /// f.doFormat(on: 8, using: '%2Y %t|one|many|S'); // ' 8 %t|one|many|S'
  /// f.doFormat(on: 17, using: 'Day count = %D');    // 'Day count = 17'
  /// f.doFormat(on: 1000, using: '%_,g08W');         // '00,001,000'
  /// f.doFormat(on: 0, using: '%*t|year|years|Y');   // ''
  /// ```
  ///
  /// If [using] contains no token, it is returned with its `%%` escapes
  /// resolved and nothing else changed.
  /// {@endtemplate}
  String doFormat({required int on, required String using}) {
    assert(
      on >= 0,
      'UnitFormatter.doFormat expects a non-negative value; sign and direction '
      'are the caller\'s responsibility. Got $on.',
    );
    final value = on.abs();

    final out = StringBuffer();
    var i = 0;

    while (i < using.length) {
      final ch = using[i];

      if (ch != _kPercent) {
        out.write(ch);
        i++;
        continue;
      }

      // A '%' in the prefix: either an escaped '%%' or the start of the token.
      final next = i + 1 < using.length ? using[i + 1] : null;
      if (next == _kPercent) {
        out.write(_kPercent);
        i += 2;
        continue;
      }

      // First real token: render it, then hand back the rest untouched.
      final parsed = _parseToken(using, i + 1);
      out
        ..write(_render(parsed.spec, value))
        ..write(using.substring(parsed.next));
      return out.toString();
    }

    // No token: the whole string was prefix (with '%%' already resolved).
    return out.toString();
  }
}

/// Parses one token beginning just after its leading `%` (at [start]).
({_TokenSpec spec, int next}) _parseToken(String s, int start) {
  final len = s.length;
  var i = start;

  String? at(int idx) => idx < len ? s[idx] : null;

  var suppress = false;
  if (at(i) == _kSuppress) {
    suppress = true;
    i++;
  }

  String? separator;
  if (at(i) == _kSeparatorFlag) {
    final c = at(i + 1);
    assert(c != null, 'Separator flag "_" must be followed by a character in: $s');
    separator = c;
    i += 2;
  }

  var grouped = false;
  if (at(i) == _kGroupedFlag) {
    grouped = true;
    i++;
  }

  var zeroPad = false;
  if (at(i) == _kZeroPadFlag) {
    zeroPad = true;
    i++;
  }

  final widthDigits = StringBuffer();
  while (i < len && _isDigit(s[i])) {
    widthDigits.write(s[i]);
    i++;
  }
  final width = widthDigits.isEmpty ? null : int.parse(widthDigits.toString());

  int? precision;
  if (at(i) == _kPrecisionDot) {
    i++;
    final precisionDigits = StringBuffer();
    while (i < len && _isDigit(s[i])) {
      precisionDigits.write(s[i]);
      i++;
    }
    assert(
      precisionDigits.isNotEmpty,
      'Precision "." must be followed by digits in: $s',
    );
    precision = precisionDigits.isEmpty ? 0 : int.parse(precisionDigits.toString());
  }

  final terminator = at(i);
  assert(
    terminator != null,
    'Format token is missing its unit / plurality terminator in: $s',
  );

  if (terminator == _kPluralityMarker) {
    i++; // consume 't'
    final arms = _parsePluralityArms(s, i);
    return (
      spec: _TokenSpec(
        suppress: suppress,
        separator: separator,
        grouped: grouped,
        zeroPad: zeroPad,
        width: width,
        precision: precision,
        plurality: arms.plurality,
      ),
      next: arms.next,
    );
  }

  assert(
    _kUnitLetters.contains(terminator),
    'Unknown unit letter "$terminator"; expected one of $_kUnitLetters in: $s',
  );
  i++; // consume the unit letter

  return (
    spec: _TokenSpec(
      suppress: suppress,
      separator: separator,
      grouped: grouped,
      zeroPad: zeroPad,
      width: width,
      precision: precision,
      plurality: null,
    ),
    next: i,
  );
}

/// Parses `|singular|plural|q` beginning at the first `|` (at [start]).
({_Plurality plurality, int next}) _parsePluralityArms(String s, int start) {
  final len = s.length;
  var i = start;

  assert(
    i < len && s[i] == _kPipe,
    'Plurality "t" must be followed by "|" in: $s',
  );
  i++; // opening '|'

  final singular = _readArm(s, i);
  i = singular.next;
  assert(i < len && s[i] == _kPipe, 'Plurality is missing its second "|" in: $s');
  i++; // middle '|'

  final plural = _readArm(s, i);
  i = plural.next;
  assert(i < len && s[i] == _kPipe, 'Plurality is missing its closing "|" in: $s');
  i++; // closing '|'

  final driver = i < len ? s[i] : null;
  assert(
    driver != null && _kUnitLetters.contains(driver),
    'Plurality must end with a driving unit letter in: $s',
  );
  i++; // driving unit letter

  return (plurality: _Plurality(singular.text, plural.text), next: i);
}

/// Reads one plurality arm up to the next unescaped `|`.
///
/// Inside an arm only `%%` -> `%` and `%|` -> `|` are valid escapes.
({String text, int next}) _readArm(String s, int start) {
  final len = s.length;
  var i = start;
  final buffer = StringBuffer();

  while (i < len) {
    final c = s[i];

    if (c == _kPercent) {
      final n = i + 1 < len ? s[i + 1] : null;
      if (n == _kPercent) {
        buffer.write(_kPercent);
        i += 2;
        continue;
      }
      if (n == _kPipe) {
        buffer.write(_kPipe);
        i += 2;
        continue;
      }
      assert(
        false,
        'Inside plurality arms only %% and %| are valid escapes; got "%$n" in: $s',
      );
      // Release fallback: treat the stray '%' as a literal.
      buffer.write(_kPercent);
      i++;
      continue;
    }

    if (c == _kPipe) break; // unescaped pipe ends the arm
    buffer.write(c);
    i++;
  }

  return (text: buffer.toString(), next: i);
}

/// Renders a parsed token against [value].
String _render(_TokenSpec spec, int value) {
  if (spec.suppress && value == 0) return '';

  final plurality = spec.plurality;
  if (plurality != null) {
    return value == 1 ? plurality.singular : plurality.plural;
  }

  return _renderNumber(spec, value);
}

/// Renders the numeric branch: precision, grouping, then width padding.
String _renderNumber(_TokenSpec spec, int value) {
  var digits = value.toString();
  if (spec.precision != null) {
    digits = digits.padLeft(spec.precision!, '0');
  }

  // C: an explicit precision suppresses the zero-pad flag.
  final usesZeroPad = spec.zeroPad && spec.precision == null;
  final sep = spec.separator;
  final width = spec.width;

  if (sep == null) {
    if (width == null) return digits;
    return digits.padLeft(width, usesZeroPad ? '0' : ' ');
  }

  if (usesZeroPad) {
    if (spec.grouped) {
      // Grouped pad: width counts digits — pad, then group.
      final padded = width == null ? digits : digits.padLeft(width, '0');
      return _group(padded, sep);
    }
    // Ungrouped pad (default): group the value, then prepend ungrouped zeros
    // to reach the width (counted in characters).
    final groupedValue = _group(digits, sep);
    return width == null ? groupedValue : groupedValue.padLeft(width, '0');
  }

  // Space padding (or none): group, then pad with spaces to the width.
  final groupedValue = _group(digits, sep);
  return width == null ? groupedValue : groupedValue.padLeft(width, ' ');
}

/// Inserts [sep] every [_kGroupSize] digits from the right of [digits].
String _group(String digits, String sep) {
  final buffer = StringBuffer();
  final n = digits.length;
  for (var i = 0; i < n; i++) {
    if (i != 0 && (n - i) % _kGroupSize == 0) buffer.write(sep);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

bool _isDigit(String c) {
  final u = c.codeUnitAt(0);
  return u >= _kZeroCodeUnit && u <= _kNineCodeUnit;
}
