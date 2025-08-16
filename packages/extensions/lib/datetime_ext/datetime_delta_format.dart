// datetime_delta_format.dart - CLEAN CODE VERSION

import 'package:extensions/datetime_ext/datetime_delta.dart' show DateTimeDelta;

extension DateTimeDeltaFormatX on DateTimeDelta {
  /// Default pattern:
  /// years (2-digit, only if >0), months (only if >0 or higher shown, in parens),
  /// days (always), then h:m:s with cascade gating and separators when printed.
  String format([
    String fmt = r'$*{[YY]} $*{(M>)} ${D} $*{hh>}:${*mm>}:$*{ss>}',
  ]) {
    final formatter = _DateTimeDeltaFormatter(this);
    return formatter.format(fmt);
  }
}

class _DateTimeDeltaFormatter {
  final DateTimeDelta _delta;
  final Map<String, int> _values;
  final List<String> _unitsOrder = const [
    'Y',
    'M',
    'D',
    'h',
    'm',
    's',
    'S',
    'u',
  ];

  _DateTimeDeltaFormatter(this._delta)
    : _values = {
        'Y': _delta.years ?? 0,
        'M': _delta.months ?? 0,
        'D': _delta.days ?? 0,
        'h': _delta.hours ?? 0,
        'm': _delta.minutes ?? 0,
        's': _delta.seconds ?? 0,
        'S': _delta.milliseconds ?? 0,
        'u': _delta.microseconds ?? 0,
      };

  String format(String fmt) {
    final parser = _FormatParser(fmt);
    final segments = parser.parse();
    final renderer = _SegmentRenderer(_values, _unitsOrder);

    final result = segments
        .map((segment) => renderer.render(segment))
        .where((text) => text.isNotEmpty)
        .join('')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return _addSignIfNeeded(result);
  }

  String _addSignIfNeeded(String result) {
    if (!_delta.isFuture && result.isNotEmpty) {
      return '-$result';
    }
    return result;
  }
}

class _FormatParser {
  final String _format;
  int _index = 0;

  _FormatParser(this._format);

  List<_FormatSegment> parse() {
    final segments = <_FormatSegment>[];

    while (_hasMoreCharacters()) {
      if (_currentChar() == r'$') {
        final segment = _parseSegment();
        if (segment != null) {
          segments.add(segment);
        } else {
          segments.add(_FormatSegment.literal(r'$'));
          _advance();
        }
      } else {
        final literal = _parseLiteral();
        if (literal.isNotEmpty) {
          segments.add(_FormatSegment.literal(literal));
        }
      }
    }

    return segments;
  }

  _FormatSegment? _parseSegment() {
    if (!_tryParseSegmentStart()) {
      return null;
    }

    bool isStarGated = _peekChar(1) == '*';
    final braceIndex = isStarGated ? 2 : 1;

    if (_peekChar(braceIndex) != '{') {
      return null;
    }

    final startIndex = _index + braceIndex + 1;
    final endIndex = _findClosingBrace(startIndex);

    if (endIndex == -1) {
      return null;
    }

    var content = _format.substring(startIndex, endIndex);

    // Handle ${*...} pattern
    final hasInternalStar = content.startsWith('*');
    if (hasInternalStar) {
      content = content.substring(1);
      isStarGated = true;
    }

    _index = endIndex + 1;

    return _createSegmentFromContent(content, isStarGated);
  }

  bool _tryParseSegmentStart() {
    return _currentChar() == r'$' && _hasMoreCharacters();
  }

  _FormatSegment _createSegmentFromContent(String content, bool isStarGated) {
    final cascadeIndex = content.indexOf('>');
    final hasCascade = cascadeIndex >= 0;

    final unitContent = hasCascade
        ? content.substring(0, cascadeIndex)
        : content;
    final suffix = hasCascade ? content.substring(cascadeIndex + 1) : '';

    final unitParse = _parseUnitContent(unitContent);

    return _FormatSegment.unit(
      symbol: unitParse.symbol,
      prefix: unitParse.prefix,
      width: unitParse.width,
      trailing: unitParse.trailing,
      suffix: suffix,
      isStarGated: isStarGated,
      hasCascade: hasCascade,
    );
  }

  _UnitParse _parseUnitContent(String content) {
    final bracketMatch = RegExp(
      r'^(.*?)\[([YMDhmsSu]+)\](.*)$',
    ).firstMatch(content);
    if (bracketMatch != null) {
      return _UnitParse(
        prefix: '${bracketMatch.group(1)!}[',
        symbol: bracketMatch.group(2)![0],
        width: bracketMatch.group(2)!.length,
        trailing: ']${bracketMatch.group(3)!}',
      );
    }

    final unitMatch = RegExp(r'(.*?)([YMDhmsSu]+)(.*)').firstMatch(content);
    if (unitMatch != null) {
      return _UnitParse(
        prefix: unitMatch.group(1)!,
        symbol: unitMatch.group(2)![0],
        width: unitMatch.group(2)!.length,
        trailing: unitMatch.group(3)!,
      );
    }

    // Fallback for invalid content
    return _UnitParse(prefix: '', symbol: 'D', width: 1, trailing: '');
  }

  String _parseLiteral() {
    final start = _index;
    while (_hasMoreCharacters() && _currentChar() != r'$') {
      _advance();
    }
    return _format.substring(start, _index);
  }

  int _findClosingBrace(int startIndex) {
    return _format.indexOf('}', startIndex);
  }

  bool _hasMoreCharacters() => _index < _format.length;
  String _currentChar() => _format[_index];
  String? _peekChar(int offset) =>
      (_index + offset < _format.length) ? _format[_index + offset] : null;
  void _advance() => _index++;
}

class _SegmentRenderer {
  final Map<String, int> _values;
  final List<String> _unitsOrder;

  _SegmentRenderer(this._values, this._unitsOrder);

  String render(_FormatSegment segment) {
    if (segment.isLiteral) {
      return segment.content;
    }

    if (!_shouldRenderSegment(segment)) {
      return '';
    }

    final value = _values[segment.symbol] ?? 0;
    final formattedValue = _formatValue(value, segment.width);

    return '${segment.prefix}$formattedValue${segment.trailing}${segment.suffix}';
  }

  bool _shouldRenderSegment(_FormatSegment segment) {
    final value = _values[segment.symbol] ?? 0;

    if (segment.hasCascade) {
      return value > 0 || _hasHigherNonZeroValue(segment.symbol);
    }

    if (segment.isStarGated) {
      return value > 0;
    }

    return true; // Unconditional
  }

  bool _hasHigherNonZeroValue(String symbol) {
    final symbolIndex = _unitsOrder.indexOf(symbol);
    if (symbolIndex <= 0) return false;

    for (int i = 0; i < symbolIndex; i++) {
      if ((_values[_unitsOrder[i]] ?? 0) > 0) {
        return true;
      }
    }

    return false;
  }

  String _formatValue(int value, int width) {
    if (width <= 1) return value.toString();
    return value.toString().padLeft(width, '0');
  }
}

class _FormatSegment {
  final bool isLiteral;
  final String content;
  final String symbol;
  final String prefix;
  final int width;
  final String trailing;
  final String suffix;
  final bool isStarGated;
  final bool hasCascade;

  const _FormatSegment._({
    required this.isLiteral,
    required this.content,
    required this.symbol,
    required this.prefix,
    required this.width,
    required this.trailing,
    required this.suffix,
    required this.isStarGated,
    required this.hasCascade,
  });

  factory _FormatSegment.literal(String content) {
    return _FormatSegment._(
      isLiteral: true,
      content: content,
      symbol: '',
      prefix: '',
      width: 0,
      trailing: '',
      suffix: '',
      isStarGated: false,
      hasCascade: false,
    );
  }

  factory _FormatSegment.unit({
    required String symbol,
    required String prefix,
    required int width,
    required String trailing,
    required String suffix,
    required bool isStarGated,
    required bool hasCascade,
  }) {
    return _FormatSegment._(
      isLiteral: false,
      content: '',
      symbol: symbol,
      prefix: prefix,
      width: width,
      trailing: trailing,
      suffix: suffix,
      isStarGated: isStarGated,
      hasCascade: hasCascade,
    );
  }
}

class _UnitParse {
  final String prefix;
  final String symbol;
  final int width;
  final String trailing;

  const _UnitParse({
    required this.prefix,
    required this.symbol,
    required this.width,
    required this.trailing,
  });
}
