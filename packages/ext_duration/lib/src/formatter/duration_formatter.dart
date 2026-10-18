// packages/ext_duration/lib/src/formatter/duration_formatter.dart

/// `sprintf`-style formatting for [Duration].
///
/// A pattern is a string containing literal text and *conversion specifiers*
/// of the form `%[flags][width]conversion`.
///
/// ### Conversions
///
/// | Conversion | Meaning                                         |
/// |------------|-------------------------------------------------|
/// | `d`        | whole days                                      |
/// | `h`        | hours within the day (0–23)                     |
/// | `H`        | total hours                                     |
/// | `m`        | minutes within the hour (0–59)                  |
/// | `M`        | total minutes                                   |
/// | `s`        | seconds within the minute (0–59)                |
/// | `S`        | total seconds                                   |
/// | `l`        | milliseconds within the second (0–999)          |
/// | `L`        | total milliseconds                              |
/// | `u`        | microseconds within the millisecond (0–999)     |
/// | `U`        | total microseconds                              |
/// | `n`        | `-` if the duration is negative, otherwise `''` |
/// | `%`        | a literal percent sign                          |
///
/// All numeric conversions use the absolute value of the duration; use `%n`
/// to emit the sign where you want it.
///
/// ### Flags
///
/// | Flag | Meaning                                          |
/// |------|--------------------------------------------------|
/// | `0`  | pad with zeros instead of spaces                 |
/// | `-`  | left-justify within the field width              |
///
/// ### Width
///
/// An optional decimal minimum field width, e.g. `%02h`, `%5S`, `%-3d`.
///
/// ### Examples
///
/// ```dart
/// const d = Duration(hours: 26, minutes: 5, seconds: 9, milliseconds: 42);
///
/// d.format('%02H:%02m:%02s');        // 26:05:09
/// d.format('%d day(s) %02h:%02m');   // 1 day(s) 02:05
/// d.format('%S.%03l s');             // 93909.042 s
/// d.format('%n%M min');              // 1565 min
/// (-d).format('%n%M min');           // -1565 min
/// d.format('100%%');                 // 100%
/// ```
library;

/// Formats a [Duration] according to a pre-parsed pattern.
///
/// Parsing happens once in the constructor, so prefer keeping an instance
/// around when formatting many durations with the same pattern.
class DurationFormatter {
  /// Creates a formatter for [pattern].
  ///
  /// Throws a [FormatException] if [pattern] contains an unknown or
  /// incomplete conversion specifier.
  DurationFormatter(this.pattern) : _tokens = _Parser(pattern).parse();

  /// The pattern this formatter was built from.
  final String pattern;

  final List<_Token> _tokens;

  /// Formats [duration] using [pattern].
  String format(Duration duration) {
    final buffer = StringBuffer();
    for (final token in _tokens) {
      token.writeTo(buffer, duration);
    }
    return buffer.toString();
  }
}

// ---------------------------------------------------------------------------
// Tokens
// ---------------------------------------------------------------------------

sealed class _Token {
  const _Token();

  void writeTo(StringBuffer buffer, Duration duration);
}

final class _LiteralToken implements _Token {
  const _LiteralToken(this.text);

  final String text;

  @override
  void writeTo(StringBuffer buffer, Duration duration) => buffer.write(text);
}

final class _FieldToken implements _Token {
  const _FieldToken({
    required this.conversion,
    required this.width,
    required this.zeroPad,
    required this.leftAlign,
  });

  final _Conversion conversion;
  final int width;
  final bool zeroPad;
  final bool leftAlign;

  @override
  void writeTo(StringBuffer buffer, Duration duration) {
    final value = conversion.extract(duration);
    if (leftAlign) {
      buffer.write(value.padRight(width));
    } else {
      buffer.write(value.padLeft(width, zeroPad ? '0' : ' '));
    }
  }
}

// ---------------------------------------------------------------------------
// Conversions
// ---------------------------------------------------------------------------

enum _Conversion {
  days('d'),
  hoursOfDay('h'),
  totalHours('H'),
  minutesOfHour('m'),
  totalMinutes('M'),
  secondsOfMinute('s'),
  totalSeconds('S'),
  millisOfSecond('l'),
  totalMillis('L'),
  microsOfMilli('u'),
  totalMicros('U'),
  sign('n'),
  percent('%');

  const _Conversion(this.symbol);

  final String symbol;

  static _Conversion? fromSymbol(String symbol) {
    for (final conversion in values) {
      if (conversion.symbol == symbol) return conversion;
    }
    return null;
  }

  String extract(Duration duration) {
    final abs = duration.abs();
    return switch (this) {
      days => '${abs.inDays}',
      hoursOfDay => '${abs.inHours % Duration.hoursPerDay}',
      totalHours => '${abs.inHours}',
      minutesOfHour => '${abs.inMinutes % Duration.minutesPerHour}',
      totalMinutes => '${abs.inMinutes}',
      secondsOfMinute => '${abs.inSeconds % Duration.secondsPerMinute}',
      totalSeconds => '${abs.inSeconds}',
      millisOfSecond =>
        '${abs.inMilliseconds % Duration.millisecondsPerSecond}',
      totalMillis => '${abs.inMilliseconds}',
      microsOfMilli =>
        '${abs.inMicroseconds % Duration.microsecondsPerMillisecond}',
      totalMicros => '${abs.inMicroseconds}',
      sign => duration.isNegative ? '-' : '',
      percent => '%',
    };
  }
}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------

final class _Parser {
  _Parser(this._pattern);

  static const _percent = 0x25; // '%'
  static const _minus = 0x2D; // '-'
  static const _zero = 0x30; // '0'
  static const _nine = 0x39; // '9'

  final String _pattern;
  int _index = 0;

  List<_Token> parse() {
    final tokens = <_Token>[];
    final literal = StringBuffer();

    while (_index < _pattern.length) {
      final char = _pattern.codeUnitAt(_index);
      if (char != _percent) {
        literal.writeCharCode(char);
        _index++;
        continue;
      }

      if (literal.isNotEmpty) {
        tokens.add(_LiteralToken(literal.toString()));
        literal.clear();
      }
      tokens.add(_parseField());
    }

    if (literal.isNotEmpty) {
      tokens.add(_LiteralToken(literal.toString()));
    }
    return tokens;
  }

  _FieldToken _parseField() {
    final start = _index;
    _index++; // consume '%'

    var leftAlign = false;
    var zeroPad = false;

    // Flags.
    while (_index < _pattern.length) {
      final char = _pattern.codeUnitAt(_index);
      if (char == _minus) {
        leftAlign = true;
      } else if (char == _zero) {
        zeroPad = true;
      } else {
        break;
      }
      _index++;
    }

    // Width.
    var width = 0;
    while (_index < _pattern.length) {
      final char = _pattern.codeUnitAt(_index);
      if (char < _zero || char > _nine) break;
      width = width * 10 + (char - _zero);
      _index++;
    }

    // Conversion.
    if (_index >= _pattern.length) {
      throw FormatException(
        'Incomplete conversion specifier',
        _pattern,
        start,
      );
    }
    final symbol = _pattern[_index];
    final conversion = _Conversion.fromSymbol(symbol);
    if (conversion == null) {
      throw FormatException(
        'Unknown conversion specifier "%$symbol"',
        _pattern,
        start,
      );
    }
    _index++;

    return _FieldToken(
      conversion: conversion,
      width: width,
      zeroPad: zeroPad,
      leftAlign: leftAlign,
    );
  }
}
