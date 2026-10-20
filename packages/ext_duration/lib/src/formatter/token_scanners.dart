// packages/ext_duration/lib/src/formatter/token_scanners.dart

const String _delimiter = '|';
const String _escape = '%';

/// Splits a printf-style [pattern] into tokens.
///
/// Scanning left to right:
/// * text outside a pair of `|` delimiters is a token,
/// * text inside a pair of `|` delimiters is its own token,
/// * the escape sequence `%|` yields the literal token `|`.
///
/// Empty tokens are discarded.
///
/// Throws a [FormatException] when a `|` has no matching `|`.
///
/// ```dart
/// tokenPatterns('start |%02h||:%3n|| total=%d| reported');
/// // ['start ', '%02h', ':%3n', ' total=%d', ' reported']
///
/// tokenPatterns('|Dog=%d,||Cat=%n|');
/// // ['Dog=%d,', 'Cat=%n']
/// ```
List<String> tokenPatterns(String pattern) =>
    _PatternTokenizer(pattern).tokenize();

/// Extracts the printf-style value specifiers from [pattern].
///
/// A specifier is `%`, followed by zero or more digits, terminated by a
/// single alphabetic character, e.g. `%d`, `%04h`, `%721m`. The escapes
/// `%%` and `%|` are ignored.
///
/// Throws a [FormatException] when a `%` is followed by anything other
/// than digits and a terminating letter.
///
/// ```dart
/// valuePatterns('start |%02h||:%3n|| total=%d| reported');
/// // ['%02h', '%3n', '%d']
/// ```
List<String> valuePatterns(String pattern) => _ValueScanner(pattern).scan();

/// Single-pass scanner that accumulates characters into tokens.
class _PatternTokenizer {
  _PatternTokenizer(this._pattern);

  static const int _noOpenDelimiter = -1;

  final String _pattern;
  final List<String> _tokens = <String>[];
  final StringBuffer _buffer = StringBuffer();

  int _openDelimiterIndex = _noOpenDelimiter;

  List<String> tokenize() {
    var index = 0;
    while (index < _pattern.length) {
      if (_isEscapedDelimiterAt(index)) {
        _emitLiteralDelimiter();
        index += 2;
      } else if (_pattern[index] == _delimiter) {
        _toggleDelimiter(index);
        index += 1;
      } else {
        _buffer.write(_pattern[index]);
        index += 1;
      }
    }
    _assertDelimitersBalanced();
    _flush();
    return List<String>.unmodifiable(_tokens);
  }

  bool _isEscapedDelimiterAt(int index) =>
      _pattern[index] == _escape &&
      index + 1 < _pattern.length &&
      _pattern[index + 1] == _delimiter;

  bool get _isInsideDelimiters => _openDelimiterIndex != _noOpenDelimiter;

  void _toggleDelimiter(int index) {
    _flush();
    _openDelimiterIndex = _isInsideDelimiters ? _noOpenDelimiter : index;
  }

  void _emitLiteralDelimiter() {
    _flush();
    _tokens.add(_delimiter);
  }

  void _flush() {
    if (_buffer.isEmpty) {
      return;
    }
    _tokens.add(_buffer.toString());
    _buffer.clear();
  }

  void _assertDelimitersBalanced() {
    if (!_isInsideDelimiters) {
      return;
    }
    throw FormatException(
      'Unmatched "$_delimiter" delimiter',
      _pattern,
      _openDelimiterIndex,
    );
  }
}

/// Single-pass scanner that collects `%` value specifiers.
class _ValueScanner {
  _ValueScanner(this._pattern);

  static const int _digitZero = 0x30;
  static const int _digitNine = 0x39;
  static const int _upperA = 0x41;
  static const int _upperZ = 0x5A;
  static const int _lowerA = 0x61;
  static const int _lowerZ = 0x7A;

  final String _pattern;
  final List<String> _values = <String>[];

  List<String> scan() {
    var index = 0;
    while (index < _pattern.length) {
      index = _pattern[index] == _escape ? _consumeEscapeAt(index) : index + 1;
    }
    return List<String>.unmodifiable(_values);
  }

  /// Consumes whatever starts at the `%` at [start] and returns the index
  /// just past it.
  int _consumeEscapeAt(int start) {
    if (_isLiteralEscapeAt(start)) {
      return start + 2;
    }
    return _consumeSpecifierAt(start);
  }

  bool _isLiteralEscapeAt(int start) {
    final int next = start + 1;
    if (next >= _pattern.length) {
      return false;
    }
    return _pattern[next] == _escape || _pattern[next] == _delimiter;
  }

  int _consumeSpecifierAt(int start) {
    final int terminatorIndex = _skipDigitsFrom(start + 1);
    _assertAlphabeticTerminator(start, terminatorIndex);
    final int end = terminatorIndex + 1;
    _values.add(_pattern.substring(start, end));
    return end;
  }

  int _skipDigitsFrom(int index) {
    var cursor = index;
    while (cursor < _pattern.length && _isDigitAt(cursor)) {
      cursor += 1;
    }
    return cursor;
  }

  bool _isDigitAt(int index) =>
      _isInRange(_pattern.codeUnitAt(index), _digitZero, _digitNine);

  bool _isAlphabeticAt(int index) {
    final int codeUnit = _pattern.codeUnitAt(index);
    return _isInRange(codeUnit, _upperA, _upperZ) ||
        _isInRange(codeUnit, _lowerA, _lowerZ);
  }

  bool _isInRange(int value, int low, int high) =>
      value >= low && value <= high;

  void _assertAlphabeticTerminator(int start, int terminatorIndex) {
    final bool isTerminated =
        terminatorIndex < _pattern.length && _isAlphabeticAt(terminatorIndex);
    if (isTerminated) {
      return;
    }
    throw FormatException(
      'Expected digits followed by a letter after "$_escape"',
      _pattern,
      start,
    );
  }
}
