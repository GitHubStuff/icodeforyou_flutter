const String _blue = '\x1B[34m';
const String _brightCyan = '\x1B[96m';
const String _brightRed = '\x1B[91m';
const String _cyan = '\x1B[36m';
const String _green = '\x1B[32m';
const String _grey = '\x1B[90m';
const String _magenta = '\x1B[35m';
const String _red = '\x1B[31m';
const String _yellow = '\x1B[33m';

enum LoggerLevel {
  all(0, '', _grey, false),
  trace(1000, '🔎 ', _grey, true),
  debug(2000, '🐞 ', _cyan, true),
  info(3000, 'ℹ️ ', _blue, false),
  refactor(4000, '🪛 ', _green, false),
  warning(5000, '⚠️ ', _yellow, false),
  crashlytics(6000, '📉 ', _magenta, true),
  error(7000, '❗️ ', _red, true),
  fatal(8000, '☠️ ', _brightRed, false),
  output(9000, '💡 ', _brightCyan, true);

  final int value;
  final String _icon;
  final String color;
  final bool fat;

  // ignore: sort_constructors_first
  const LoggerLevel(this.value, this._icon, this.color, this.fat);

  String get icon => _icon;

  bool operator <(LoggerLevel other) => value < other.value;
  bool operator <=(LoggerLevel other) => value <= other.value;
  bool operator >(LoggerLevel other) => value > other.value;
  bool operator >=(LoggerLevel other) => value >= other.value;
}
