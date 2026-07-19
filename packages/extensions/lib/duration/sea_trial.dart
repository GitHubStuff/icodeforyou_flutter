// A "sea-trial" for [UnitFormatter.doFormat]: 350 working cases.
//
// Heavy focus on the FIRST-TOKEN behavior — multi-token templates where only
// the first token is formatted and the remainder is returned untouched,
// leading/trailing `%%`, no-token passthrough, and chained passes that build a
// full display one unit at a time — alongside a full mash-up of padding,
// precision, separators, grouping, suppression, and plurality.
//
// Run with:  dart run example/sea_trial.dart
//
// Every `expect` was computed from a reference implementation of the spec, not
// from the Dart code under test. A failing puck means the Dart `UnitFormatter`
// diverged from the intended behavior — which is the point of the trial.

// No one will read this but me.
// ignore_for_file: avoid_print, prefer_single_quotes, public_member_api_docs

import 'package:extensions/duration/unit_formatter.dart';

/// A single formatting expectation: format `value` with `format` and check the
/// result against `expect`.
///
/// After [test] runs, [result] holds the formatter's actual output for
/// introspection on failure. [result] is write-once: call [test] exactly once
/// per puck.
class Puck {
  Puck({required this.value, required this.format, required this.expect});

  static const UnitFormatter _formatter = UnitFormatter();

  final int value;
  final String format;
  final String expect;

  /// The formatter's actual output. Populated by [test].
  late final String result;

  /// Formats [value] with [format], caches it in [result], and reports whether
  /// it matched [expect].
  bool test() {
    result = _formatter.doFormat(on: value, using: format);
    return result == expect;
  }
}

final List<Puck> pucks = <Puck>[
  Puck(value: 0, format: "%Y", expect: "0"),
  Puck(value: 1, format: "%Y", expect: "1"),
  Puck(value: 2, format: "%Y", expect: "2"),
  Puck(value: 17, format: "%Y", expect: "17"),
  Puck(value: 1000, format: "%Y", expect: "1000"),
  Puck(value: 12345, format: "%Y", expect: "12345"),
  Puck(value: 0, format: "%M", expect: "0"),
  Puck(value: 1, format: "%M", expect: "1"),
  Puck(value: 2, format: "%M", expect: "2"),
  Puck(value: 17, format: "%M", expect: "17"),
  Puck(value: 1000, format: "%M", expect: "1000"),
  Puck(value: 12345, format: "%M", expect: "12345"),
  Puck(value: 0, format: "%W", expect: "0"),
  Puck(value: 1, format: "%W", expect: "1"),
  Puck(value: 2, format: "%W", expect: "2"),
  Puck(value: 17, format: "%W", expect: "17"),
  Puck(value: 1000, format: "%W", expect: "1000"),
  Puck(value: 12345, format: "%W", expect: "12345"),
  Puck(value: 0, format: "%D", expect: "0"),
  Puck(value: 1, format: "%D", expect: "1"),
  Puck(value: 2, format: "%D", expect: "2"),
  Puck(value: 17, format: "%D", expect: "17"),
  Puck(value: 1000, format: "%D", expect: "1000"),
  Puck(value: 12345, format: "%D", expect: "12345"),
  Puck(value: 0, format: "%H", expect: "0"),
  Puck(value: 1, format: "%H", expect: "1"),
  Puck(value: 2, format: "%H", expect: "2"),
  Puck(value: 17, format: "%H", expect: "17"),
  Puck(value: 1000, format: "%H", expect: "1000"),
  Puck(value: 12345, format: "%H", expect: "12345"),
  Puck(value: 0, format: "%m", expect: "0"),
  Puck(value: 1, format: "%m", expect: "1"),
  Puck(value: 2, format: "%m", expect: "2"),
  Puck(value: 17, format: "%m", expect: "17"),
  Puck(value: 1000, format: "%m", expect: "1000"),
  Puck(value: 12345, format: "%m", expect: "12345"),
  Puck(value: 0, format: "%s", expect: "0"),
  Puck(value: 1, format: "%s", expect: "1"),
  Puck(value: 2, format: "%s", expect: "2"),
  Puck(value: 17, format: "%s", expect: "17"),
  Puck(value: 1000, format: "%s", expect: "1000"),
  Puck(value: 12345, format: "%s", expect: "12345"),
  Puck(value: 0, format: "%S", expect: "0"),
  Puck(value: 1, format: "%S", expect: "1"),
  Puck(value: 2, format: "%S", expect: "2"),
  Puck(value: 17, format: "%S", expect: "17"),
  Puck(value: 1000, format: "%S", expect: "1000"),
  Puck(value: 12345, format: "%S", expect: "12345"),
  Puck(value: 0, format: "%u", expect: "0"),
  Puck(value: 1, format: "%u", expect: "1"),
  Puck(value: 2, format: "%u", expect: "2"),
  Puck(value: 17, format: "%u", expect: "17"),
  Puck(value: 1000, format: "%u", expect: "1000"),
  Puck(value: 12345, format: "%u", expect: "12345"),
  Puck(value: 5, format: "%4D", expect: "   5"),
  Puck(value: 5, format: "%6D", expect: "     5"),
  Puck(value: 55, format: "%4W", expect: "  55"),
  Puck(value: 55, format: "%6W", expect: "    55"),
  Puck(value: 7, format: "%4H", expect: "   7"),
  Puck(value: 7, format: "%6H", expect: "     7"),
  Puck(value: 123, format: "%4m", expect: " 123"),
  Puck(value: 123, format: "%6m", expect: "   123"),
  Puck(value: 9, format: "%4Y", expect: "   9"),
  Puck(value: 9, format: "%6Y", expect: "     9"),
  Puck(value: 0, format: "%4s", expect: "   0"),
  Puck(value: 0, format: "%6s", expect: "     0"),
  Puck(value: 42, format: "%4M", expect: "  42"),
  Puck(value: 42, format: "%6M", expect: "    42"),
  Puck(value: 8, format: "%4S", expect: "   8"),
  Puck(value: 8, format: "%6S", expect: "     8"),
  Puck(value: 3, format: "%4u", expect: "   3"),
  Puck(value: 3, format: "%6u", expect: "     3"),
  Puck(value: 5, format: "%03D", expect: "005"),
  Puck(value: 55, format: "%04W", expect: "0055"),
  Puck(value: 7, format: "%02H", expect: "07"),
  Puck(value: 9, format: "%05Y", expect: "00009"),
  Puck(value: 0, format: "%02s", expect: "00"),
  Puck(value: 42, format: "%06M", expect: "000042"),
  Puck(value: 123, format: "%02m", expect: "123"),
  Puck(value: 8, format: "%04S", expect: "0008"),
  Puck(value: 1, format: "%03u", expect: "001"),
  Puck(value: 99, format: "%05D", expect: "00099"),
  Puck(value: 7, format: "%.3D", expect: "007"),
  Puck(value: 0, format: "%.2s", expect: "00"),
  Puck(value: 42, format: "%.4M", expect: "0042"),
  Puck(value: 5, format: "%.1Y", expect: "5"),
  Puck(value: 123, format: "%.5m", expect: "00123"),
  Puck(value: 9, format: "%.3H", expect: "009"),
  Puck(value: 1000, format: "%.2W", expect: "1000"),
  Puck(value: 8, format: "%.6S", expect: "000008"),
  Puck(value: 7, format: "%7.3D", expect: "    007"),
  Puck(value: 7, format: "%07.3D", expect: "    007"),
  Puck(value: 5, format: "%6.2Y", expect: "    05"),
  Puck(value: 5, format: "%06.2Y", expect: "    05"),
  Puck(value: 0, format: "%5.2s", expect: "   00"),
  Puck(value: 0, format: "%05.2s", expect: "   00"),
  Puck(value: 42, format: "%8.4M", expect: "    0042"),
  Puck(value: 42, format: "%08.4M", expect: "    0042"),
  Puck(value: 9, format: "%4.1H", expect: "   9"),
  Puck(value: 9, format: "%04.1H", expect: "   9"),
  Puck(value: 1000, format: "%_,W", expect: "1,000"),
  Puck(value: 12345, format: "%_.D", expect: "12.345"),
  Puck(value: 1000000, format: "%_^s", expect: "1^000^000"),
  Puck(value: 9000000000, format: "%_#u", expect: "9#000#000#000"),
  Puck(value: 999, format: "%__M", expect: "999"),
  Puck(value: 1234, format: "%_-H", expect: "1-234"),
  Puck(value: 100, format: "%_/Y", expect: "100"),
  Puck(value: 86400, format: "%_:m", expect: "86:400"),
  Puck(value: 0, format: "%_;S", expect: "0"),
  Puck(value: 55, format: "%_~W", expect: "55"),
  Puck(value: 1000, format: "%_,07W", expect: "001,000"),
  Puck(value: 1234, format: "%_.09D", expect: "00001.234"),
  Puck(value: 12345, format: "%_^09s", expect: "00012^345"),
  Puck(value: 100, format: "%_#08M", expect: "00000100"),
  Puck(value: 7, format: "%__05H", expect: "00007"),
  Puck(value: 0, format: "%_-05Y", expect: "00000"),
  Puck(value: 999, format: "%_/07m", expect: "0000999"),
  Puck(value: 1000000, format: "%_:012S", expect: "0001:000:000"),
  Puck(value: 55, format: "%_;06u", expect: "000055"),
  Puck(value: 86400, format: "%_~08D", expect: "0086~400"),
  Puck(value: 1000, format: "%_,g08W", expect: "00,001,000"),
  Puck(value: 1234, format: "%_.g08D", expect: "00.001.234"),
  Puck(value: 12345, format: "%_^g09s", expect: "000^012^345"),
  Puck(value: 100, format: "%_#g07M", expect: "0#000#100"),
  Puck(value: 7, format: "%__g06H", expect: "000_007"),
  Puck(value: 0, format: "%_-g06Y", expect: "000-000"),
  Puck(value: 999, format: "%_/g07m", expect: "0/000/999"),
  Puck(value: 1000000, format: "%_:g09S", expect: "001:000:000"),
  Puck(value: 55, format: "%_;g06u", expect: "000;055"),
  Puck(value: 86400, format: "%_~g09D", expect: "000~086~400"),
  Puck(value: 1000, format: "%_,.5W", expect: "01,000"),
  Puck(value: 12, format: "%_..6D", expect: "000.012"),
  Puck(value: 0, format: "%_^.3s", expect: "000"),
  Puck(value: 999, format: "%_#.4M", expect: "0#999"),
  Puck(value: 1234567, format: "%__.2H", expect: "1_234_567"),
  Puck(value: 0, format: "%*D", expect: ""),
  Puck(value: 5, format: "%*D", expect: "5"),
  Puck(value: 0, format: "%*W", expect: ""),
  Puck(value: 17, format: "%*W", expect: "17"),
  Puck(value: 0, format: "%*Y", expect: ""),
  Puck(value: 1000, format: "%*Y", expect: "1000"),
  Puck(value: 0, format: "%*s", expect: ""),
  Puck(value: 42, format: "%*s", expect: "42"),
  Puck(value: 0, format: "%*_,07W", expect: ""),
  Puck(value: 1000, format: "%*_,07W", expect: "001,000"),
  Puck(value: 0, format: "%*_,07D", expect: ""),
  Puck(value: 1234, format: "%*_,07D", expect: "001,234"),
  Puck(value: 0, format: "%*05H", expect: ""),
  Puck(value: 7, format: "%*05H", expect: "00007"),
  Puck(value: 0, format: "%*05M", expect: ""),
  Puck(value: 42, format: "%*05M", expect: "00042"),
  Puck(value: 0, format: "%t|year|years|Y", expect: "years"),
  Puck(value: 1, format: "%t|year|years|Y", expect: "year"),
  Puck(value: 2, format: "%t|year|years|Y", expect: "years"),
  Puck(value: 5, format: "%t|year|years|Y", expect: "years"),
  Puck(value: 0, format: "%t|day|days|D", expect: "days"),
  Puck(value: 1, format: "%t|day|days|D", expect: "day"),
  Puck(value: 2, format: "%t|day|days|D", expect: "days"),
  Puck(value: 1, format: "%t|is|are|W", expect: "is"),
  Puck(value: 2, format: "%t|is|are|W", expect: "are"),
  Puck(value: 0, format: "%*t|year|years|Y", expect: ""),
  Puck(value: 1, format: "%*t|year|years|Y", expect: "year"),
  Puck(value: 2, format: "%*t|year|years|Y", expect: "years"),
  Puck(value: 5, format: "%*t|year|years|Y", expect: "years"),
  Puck(value: 0, format: "%*t| minute| minutes|m", expect: ""),
  Puck(value: 1, format: "%*t| minute| minutes|m", expect: " minute"),
  Puck(value: 2, format: "%*t| minute| minutes|m", expect: " minutes"),
  Puck(value: 1, format: "%t|50%% off|deals|D", expect: "50% off"),
  Puck(value: 2, format: "%t|50%% off|deals|D", expect: "deals"),
  Puck(value: 1, format: "%t|a%|b|c%|d|Y", expect: "a|b"),
  Puck(value: 3, format: "%t|a%|b|c%|d|Y", expect: "c|d"),
  Puck(value: 1, format: "%t|100%%|all%%|W", expect: "100%"),
  Puck(value: 0, format: "%t|100%%|all%%|W", expect: "all%"),
  Puck(value: 8, format: "%2Y %t|one|many|S", expect: " 8 %t|one|many|S"),
  Puck(value: 8, format: "%Y %M %D", expect: "8 %M %D"),
  Puck(value: 3, format: "%Yy %Mmo %Dd", expect: "3y %Mmo %Dd"),
  Puck(
    value: 27,
    format: "%*D left, then %W and %t|x|y|H",
    expect: "27 left, then %W and %t|x|y|H",
  ),
  Puck(
    value: 0,
    format: "%*D left, then %W and %t|x|y|H",
    expect: " left, then %W and %t|x|y|H",
  ),
  Puck(
    value: 1000,
    format: "%_,W remaining of %D",
    expect: "1,000 remaining of %D",
  ),
  Puck(value: 5, format: "%t|item|items|D after %M", expect: "items after %M"),
  Puck(value: 1, format: "%t|item|items|D after %M", expect: "item after %M"),
  Puck(value: 42, format: "%05M then %_,W", expect: "00042 then %_,W"),
  Puck(value: 7, format: "%H:%m:%s", expect: "7:%m:%s"),
  Puck(value: 0, format: "%H:%m:%s", expect: "0:%m:%s"),
  Puck(value: 9, format: "%.3D / %.3W", expect: "009 / %.3W"),
  Puck(value: 12345, format: "%_^s + %_#u", expect: "12^345 + %_#u"),
  Puck(value: 2, format: "[%D][%W][%M]", expect: "[2][%W][%M]"),
  Puck(value: 100, format: "%_,g08Y :: %Z?", expect: "00,000,100 :: %Z?"),
  Puck(value: 55, format: "%W%D%M", expect: "55%D%M"),
  Puck(
    value: 3,
    format: "%*t|c|cs|D and %*t|d|ds|H",
    expect: "cs and %*t|d|ds|H",
  ),
  Puck(
    value: 0,
    format: "%*t|c|cs|D and %*t|d|ds|H",
    expect: " and %*t|d|ds|H",
  ),
  Puck(
    value: 86400,
    format: "%_:S | leftover %g0Q",
    expect: "86:400 | leftover %g0Q",
  ),
  Puck(value: 17, format: "%6D|%6W|%6H", expect: "    17|%6W|%6H"),
  Puck(
    value: 1,
    format: "%t| year| years|Y, %t| month| months|M",
    expect: " year, %t| month| months|M",
  ),
  Puck(
    value: 2,
    format: "%t| year| years|Y, %t| month| months|M",
    expect: " years, %t| month| months|M",
  ),
  Puck(
    value: 1234,
    format: "%_-D and counting... %_-W",
    expect: "1-234 and counting... %_-W",
  ),
  Puck(value: 8, format: "%03S start %W end", expect: "008 start %W end"),
  Puck(
    value: 0,
    format: "%*06W (empty) trailing %D",
    expect: " (empty) trailing %D",
  ),
  Puck(
    value: 9000000000,
    format: "%_,u then %_,u again",
    expect: "9,000,000,000 then %_,u again",
  ),
  Puck(
    value: 7,
    format: "first %D, ignore %5W, ignore %t|p|q|H",
    expect: "first 7, ignore %5W, ignore %t|p|q|H",
  ),
  Puck(
    value: 3,
    format: "100%% sure: %D and %W left",
    expect: "100% sure: 3 and %W left",
  ),
  Puck(value: 5, format: "%D items%%", expect: "5 items%%"),
  Puck(
    value: 12,
    format: "%%D is raw, %D is live, %W stays",
    expect: "%D is raw, 12 is live, %W stays",
  ),
  Puck(value: 2, format: "%%%D", expect: "%2"),
  Puck(value: 4, format: "%D%%", expect: "4%%"),
  Puck(value: 1, format: "a%%b %t|x|y|Y c%%d %W", expect: "a%b x c%%d %W"),
  Puck(
    value: 0,
    format: "%*D%% blank-or-pct then %M",
    expect: "%% blank-or-pct then %M",
  ),
  Puck(
    value: 99,
    format: "pre %% %_,W post %% %D",
    expect: "pre % 99 post %% %D",
  ),
  Puck(value: 5, format: "no tokens here", expect: "no tokens here"),
  Puck(value: 9, format: "100%% literal only", expect: "100% literal only"),
  Puck(
    value: 0,
    format: "%%D %%W %%H all escaped",
    expect: "%D %W %H all escaped",
  ),
  Puck(value: 3, format: "", expect: ""),
  Puck(value: 7, format: "just %% and %% again", expect: "just % and % again"),
  Puck(
    value: 42,
    format: "trailing percent pair %%",
    expect: "trailing percent pair %",
  ),
  Puck(value: 3, format: "%Yy %Mmo %Dd %Hh", expect: "3y %Mmo %Dd %Hh"),
  Puck(value: 2, format: "3y %Mmo %Dd %Hh", expect: "3y 2mo %Dd %Hh"),
  Puck(value: 5, format: "3y 2mo %Dd %Hh", expect: "3y 2mo 5d %Hh"),
  Puck(value: 9, format: "3y 2mo 5d %Hh", expect: "3y 2mo 5d 9h"),
  Puck(
    value: 1,
    format: "%t|year|years|Y, %t|month|months|M, %t|day|days|D",
    expect: "year, %t|month|months|M, %t|day|days|D",
  ),
  Puck(
    value: 2,
    format: "year, %t|month|months|M, %t|day|days|D",
    expect: "year, months, %t|day|days|D",
  ),
  Puck(
    value: 1,
    format: "year, months, %t|day|days|D",
    expect: "year, months, day",
  ),
  Puck(
    value: 1234,
    format: "%_,W weeks %_,D days %_,H hrs",
    expect: "1,234 weeks %_,D days %_,H hrs",
  ),
  Puck(
    value: 56789,
    format: "1,234 weeks %_,D days %_,H hrs",
    expect: "1,234 weeks 56,789 days %_,H hrs",
  ),
  Puck(
    value: 100,
    format: "1,234 weeks 56,789 days %_,H hrs",
    expect: "1,234 weeks 56,789 days 100 hrs",
  ),
  Puck(value: 7, format: "%02H:%02m:%02s", expect: "07:%02m:%02s"),
  Puck(value: 5, format: "07:%02m:%02s", expect: "07:05:%02s"),
  Puck(value: 9, format: "07:05:%02s", expect: "07:05:09"),
  Puck(
    value: 3,
    format: "%*t| day| days|D and %*t| hour| hours|H done",
    expect: " days and %*t| hour| hours|H done",
  ),
  Puck(
    value: 12,
    format: " days and %*t| hour| hours|H done",
    expect: " days and  hours done",
  ),
  Puck(value: 10, format: "[%D] [%W] [%M] [%Y]", expect: "[10] [%W] [%M] [%Y]"),
  Puck(value: 20, format: "[10] [%W] [%M] [%Y]", expect: "[10] [20] [%M] [%Y]"),
  Puck(value: 30, format: "[10] [20] [%M] [%Y]", expect: "[10] [20] [30] [%Y]"),
  Puck(value: 40, format: "[10] [20] [30] [%Y]", expect: "[10] [20] [30] [40]"),
  Puck(
    value: 1000000,
    format: "%_^s | %_^u | %_^S",
    expect: "1^000^000 | %_^u | %_^S",
  ),
  Puck(
    value: 9000000000,
    format: "1^000^000 | %_^u | %_^S",
    expect: "1^000^000 | 9^000^000^000 | %_^S",
  ),
  Puck(
    value: 250,
    format: "1^000^000 | 9^000^000^000 | %_^S",
    expect: "1^000^000 | 9^000^000^000 | 250",
  ),
  Puck(
    value: 1,
    format: "%t|one|many|D + %t|one|many|W + %t|one|many|M",
    expect: "one + %t|one|many|W + %t|one|many|M",
  ),
  Puck(
    value: 5,
    format: "one + %t|one|many|W + %t|one|many|M",
    expect: "one + many + %t|one|many|M",
  ),
  Puck(
    value: 1,
    format: "one + many + %t|one|many|M",
    expect: "one + many + one",
  ),
  Puck(value: 1234567, format: "%_,g012s", expect: "000,001,234,567"),
  Puck(value: 1234567, format: "%_,s", expect: "1,234,567"),
  Puck(value: 1234567, format: "%_,012s", expect: "0001,234,567"),
  Puck(value: 5, format: "%*_,05D", expect: "00005"),
  Puck(value: 0, format: "%*_,05D", expect: ""),
  Puck(value: 1, format: "%*t|sole|plural|u", expect: "sole"),
  Puck(value: 1000000000, format: "%_.u", expect: "1.000.000.000"),
  Puck(value: 1000000000, format: "%_.g015u", expect: "000.001.000.000.000"),
  Puck(value: 0, format: "%05.3W", expect: "  000"),
  Puck(value: 7, format: "%05.3W", expect: "  007"),
  Puck(value: 7, format: "%.0D", expect: "7"),
  Puck(value: 0, format: "%.0D", expect: "0"),
  Puck(value: 42, format: "%_~08M", expect: "00000042"),
  Puck(value: 42, format: "%_~g08M", expect: "00~000~042"),
  Puck(value: 9, format: "%9H", expect: "        9"),
  Puck(value: 9, format: "%09H", expect: "000000009"),
  Puck(value: 250, format: "%_,S", expect: "250"),
  Puck(value: 250, format: "%.5S", expect: "00250"),
  Puck(value: 250, format: "%_,.5S", expect: "00,250"),
  Puck(value: 333, format: "%t|a|b|D", expect: "b"),
  Puck(value: 1, format: "%t|a|b|D", expect: "a"),
  Puck(value: 0, format: "%t|a|b|D", expect: "b"),
  Puck(value: 88, format: "%*Y", expect: "88"),
  Puck(value: 0, format: "%*Y", expect: ""),
  Puck(value: 88, format: "%*_:06Y", expect: "000088"),
  Puck(value: 0, format: "%*_:06Y", expect: ""),
  Puck(
    value: 0,
    format: "%02Y >> %D >> %t|x|y|Y",
    expect: "00 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 1,
    format: "%03M >> %H >> %t|x|y|M",
    expect: "001 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 2,
    format: "%04W >> %m >> %t|x|y|W",
    expect: "0002 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 7,
    format: "%05D >> %s >> %t|x|y|D",
    expect: "00007 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 55,
    format: "%06H >> %S >> %t|x|y|H",
    expect: "000055 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 1000,
    format: "%07m >> %u >> %t|x|y|m",
    expect: "0001000 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 12345,
    format: "%02s >> %Y >> %t|x|y|s",
    expect: "12345 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 0,
    format: "%03S >> %M >> %t|x|y|S",
    expect: "000 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 1,
    format: "%04u >> %W >> %t|x|y|u",
    expect: "0001 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 2,
    format: "%05Y >> %D >> %t|x|y|Y",
    expect: "00002 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 7,
    format: "%06M >> %H >> %t|x|y|M",
    expect: "000007 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 55,
    format: "%07W >> %m >> %t|x|y|W",
    expect: "0000055 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 1000,
    format: "%02D >> %s >> %t|x|y|D",
    expect: "1000 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 12345,
    format: "%03H >> %S >> %t|x|y|H",
    expect: "12345 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 0,
    format: "%04m >> %u >> %t|x|y|m",
    expect: "0000 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 1,
    format: "%05s >> %Y >> %t|x|y|s",
    expect: "00001 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 2,
    format: "%06S >> %M >> %t|x|y|S",
    expect: "000002 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 7,
    format: "%07u >> %W >> %t|x|y|u",
    expect: "0000007 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 55,
    format: "%02Y >> %D >> %t|x|y|Y",
    expect: "55 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 1000,
    format: "%03M >> %H >> %t|x|y|M",
    expect: "1000 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 12345,
    format: "%04W >> %m >> %t|x|y|W",
    expect: "12345 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 0,
    format: "%05D >> %s >> %t|x|y|D",
    expect: "00000 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 1,
    format: "%06H >> %S >> %t|x|y|H",
    expect: "000001 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 2,
    format: "%07m >> %u >> %t|x|y|m",
    expect: "0000002 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 7,
    format: "%02s >> %Y >> %t|x|y|s",
    expect: "07 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 55,
    format: "%03S >> %M >> %t|x|y|S",
    expect: "055 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 1000,
    format: "%04u >> %W >> %t|x|y|u",
    expect: "1000 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 12345,
    format: "%05Y >> %D >> %t|x|y|Y",
    expect: "12345 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 0,
    format: "%06M >> %H >> %t|x|y|M",
    expect: "000000 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 1,
    format: "%07W >> %m >> %t|x|y|W",
    expect: "0000001 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 2,
    format: "%02D >> %s >> %t|x|y|D",
    expect: "02 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 7,
    format: "%03H >> %S >> %t|x|y|H",
    expect: "007 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 55,
    format: "%04m >> %u >> %t|x|y|m",
    expect: "0055 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 1000,
    format: "%05s >> %Y >> %t|x|y|s",
    expect: "01000 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 12345,
    format: "%06S >> %M >> %t|x|y|S",
    expect: "012345 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 0,
    format: "%07u >> %W >> %t|x|y|u",
    expect: "0000000 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 1,
    format: "%02Y >> %D >> %t|x|y|Y",
    expect: "01 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 2,
    format: "%03M >> %H >> %t|x|y|M",
    expect: "002 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 7,
    format: "%04W >> %m >> %t|x|y|W",
    expect: "0007 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 55,
    format: "%05D >> %s >> %t|x|y|D",
    expect: "00055 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 1000,
    format: "%06H >> %S >> %t|x|y|H",
    expect: "001000 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 12345,
    format: "%07m >> %u >> %t|x|y|m",
    expect: "0012345 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 0,
    format: "%02s >> %Y >> %t|x|y|s",
    expect: "00 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 1,
    format: "%03S >> %M >> %t|x|y|S",
    expect: "001 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 2,
    format: "%04u >> %W >> %t|x|y|u",
    expect: "0002 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 7,
    format: "%05Y >> %D >> %t|x|y|Y",
    expect: "00007 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 55,
    format: "%06M >> %H >> %t|x|y|M",
    expect: "000055 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 1000,
    format: "%07W >> %m >> %t|x|y|W",
    expect: "0001000 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 12345,
    format: "%02D >> %s >> %t|x|y|D",
    expect: "12345 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 0,
    format: "%03H >> %S >> %t|x|y|H",
    expect: "000 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 1,
    format: "%04m >> %u >> %t|x|y|m",
    expect: "0001 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 2,
    format: "%05s >> %Y >> %t|x|y|s",
    expect: "00002 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 7,
    format: "%06S >> %M >> %t|x|y|S",
    expect: "000007 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 55,
    format: "%07u >> %W >> %t|x|y|u",
    expect: "0000055 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 1000,
    format: "%02Y >> %D >> %t|x|y|Y",
    expect: "1000 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 12345,
    format: "%03M >> %H >> %t|x|y|M",
    expect: "12345 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 0,
    format: "%04W >> %m >> %t|x|y|W",
    expect: "0000 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 1,
    format: "%05D >> %s >> %t|x|y|D",
    expect: "00001 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 2,
    format: "%06H >> %S >> %t|x|y|H",
    expect: "000002 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 7,
    format: "%07m >> %u >> %t|x|y|m",
    expect: "0000007 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 55,
    format: "%02s >> %Y >> %t|x|y|s",
    expect: "55 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 1000,
    format: "%03S >> %M >> %t|x|y|S",
    expect: "1000 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 12345,
    format: "%04u >> %W >> %t|x|y|u",
    expect: "12345 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 0,
    format: "%05Y >> %D >> %t|x|y|Y",
    expect: "00000 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 1,
    format: "%06M >> %H >> %t|x|y|M",
    expect: "000001 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 2,
    format: "%07W >> %m >> %t|x|y|W",
    expect: "0000002 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 7,
    format: "%02D >> %s >> %t|x|y|D",
    expect: "07 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 55,
    format: "%03H >> %S >> %t|x|y|H",
    expect: "055 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 1000,
    format: "%04m >> %u >> %t|x|y|m",
    expect: "1000 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 12345,
    format: "%05s >> %Y >> %t|x|y|s",
    expect: "12345 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 0,
    format: "%06S >> %M >> %t|x|y|S",
    expect: "000000 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 1,
    format: "%07u >> %W >> %t|x|y|u",
    expect: "0000001 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 2,
    format: "%02Y >> %D >> %t|x|y|Y",
    expect: "02 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 7,
    format: "%03M >> %H >> %t|x|y|M",
    expect: "007 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 55,
    format: "%04W >> %m >> %t|x|y|W",
    expect: "0055 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 1000,
    format: "%05D >> %s >> %t|x|y|D",
    expect: "01000 >> %s >> %t|x|y|D",
  ),
  Puck(
    value: 12345,
    format: "%06H >> %S >> %t|x|y|H",
    expect: "012345 >> %S >> %t|x|y|H",
  ),
  Puck(
    value: 0,
    format: "%07m >> %u >> %t|x|y|m",
    expect: "0000000 >> %u >> %t|x|y|m",
  ),
  Puck(
    value: 1,
    format: "%02s >> %Y >> %t|x|y|s",
    expect: "01 >> %Y >> %t|x|y|s",
  ),
  Puck(
    value: 2,
    format: "%03S >> %M >> %t|x|y|S",
    expect: "002 >> %M >> %t|x|y|S",
  ),
  Puck(
    value: 7,
    format: "%04u >> %W >> %t|x|y|u",
    expect: "0007 >> %W >> %t|x|y|u",
  ),
  Puck(
    value: 55,
    format: "%05Y >> %D >> %t|x|y|Y",
    expect: "00055 >> %D >> %t|x|y|Y",
  ),
  Puck(
    value: 1000,
    format: "%06M >> %H >> %t|x|y|M",
    expect: "001000 >> %H >> %t|x|y|M",
  ),
  Puck(
    value: 12345,
    format: "%07W >> %m >> %t|x|y|W",
    expect: "0012345 >> %m >> %t|x|y|W",
  ),
  Puck(
    value: 0,
    format: "%02D >> %s >> %t|x|y|D",
    expect: "00 >> %s >> %t|x|y|D",
  ),
];

void main() {
  var passed = 0;
  final failures = <Puck>[];

  for (final puck in pucks) {
    if (puck.test()) {
      passed++;
    } else {
      failures.add(puck);
    }
  }

  print(
    'Sea-trial: ${pucks.length} pucks — $passed passed, '
    '${failures.length} failed.',
  );

  if (failures.isNotEmpty) {
    print('\nFailures:');
    for (final f in failures) {
      print('  value=${f.value}  format="${f.format}"');
      print('    expected: "${f.expect}"');
      print('    actual:   "${f.result}"');
    }
  }
}
