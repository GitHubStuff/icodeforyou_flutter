// packages/sqlite_viewer/test/src/widgets/display_query_widget_width_test.dart
//
// Regression test for the render-vs-measurement column-width bug.
//
// The bug: column widths were computed by `TextPainter` against the bare
// `TextStyle` passed to the widget, but cells render through a `Text`
// widget that merges that style with the ambient `DefaultTextStyle` and
// scales it with `MediaQuery.textScalerOf`. The measured width came back
// narrower than the rendered glyphs, so cells truncated inside their
// allotted box even when the values were short.
//
// The fix: measurement matches the render path — merged style, ambient
// text scaler, ambient text direction. This file asserts the invariant.
//
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/widgets/display_query_widget.dart';

void main() {
  group('DisplayQueryWidget column-width regression', () {
    testWidgets(
      'cell container is at least as wide as the rendered cell text',
      (tester) async {
        // android_metadata-shaped data: short header, short value, but
        // the rendered Roboto glyphs are wider than the bare-style
        // TextPainter measurement used to suggest.
        const columns = ['locale'];
        const rows = [
          {'locale': 'en_US'},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: DisplayQueryWidget(
                  columns: columns,
                  rows: rows,
                  evenRowStyle: TextStyle(color: Colors.black),
                  oddRowStyle: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cellTextFinder = find.text('en_US');
        expect(cellTextFinder, findsOneWidget);

        // Width of the rendered Text widget's box.
        final renderedTextSize = tester.getSize(cellTextFinder);

        // The cell's container is the nearest ancestor Container with a
        // fixed width — the one DisplayQueryWidget builds in
        // `_buildDataCell`. We compare its inner width (minus padding)
        // to the rendered text width.
        final cellContainerSize = tester.getSize(
          find
              .ancestor(
                of: cellTextFinder,
                matching: find.byType(Container),
              )
              .first,
        );

        const horizontalPadding = 12.0 * 2; // default cellPadding L+R
        final cellInnerWidth = cellContainerSize.width - horizontalPadding;

        expect(
          cellInnerWidth,
          greaterThanOrEqualTo(renderedTextSize.width),
          reason:
              'Cell inner width ($cellInnerWidth) must be at least as '
              'wide as rendered text (${renderedTextSize.width}) so '
              'content does not truncate.',
        );
      },
    );

    testWidgets(
      'header cell is at least as wide as the rendered header text',
      (tester) async {
        const columns = ['locale'];
        const rows = [
          {'locale': 'en_US'},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: DisplayQueryWidget(
                  columns: columns,
                  rows: rows,
                  evenRowStyle: TextStyle(color: Colors.black),
                  oddRowStyle: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final headerTextFinder = find.text('locale');
        expect(headerTextFinder, findsOneWidget);

        final renderedHeaderSize = tester.getSize(headerTextFinder);
        final headerContainerSize = tester.getSize(
          find
              .ancestor(
                of: headerTextFinder,
                matching: find.byType(Container),
              )
              .first,
        );

        const horizontalPadding = 12.0 * 2;
        final headerInnerWidth =
            headerContainerSize.width - horizontalPadding;

        expect(
          headerInnerWidth,
          greaterThanOrEqualTo(renderedHeaderSize.width),
          reason:
              'Header inner width ($headerInnerWidth) must be at least '
              'as wide as rendered header text '
              '(${renderedHeaderSize.width}).',
        );
      },
    );

    testWidgets(
      'header and first data cell share the same column width',
      (tester) async {
        const columns = ['locale'];
        const rows = [
          {'locale': 'en_US'},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: DisplayQueryWidget(
                  columns: columns,
                  rows: rows,
                  evenRowStyle: TextStyle(color: Colors.black),
                  oddRowStyle: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final headerContainer = tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('locale'),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .width;

        final cellContainer = tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('en_US'),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .width;

        expect(
          cellContainer,
          equals(headerContainer),
          reason:
              'Header column width must equal data cell column width so '
              'the columns line up.',
        );
      },
    );

    testWidgets(
      'larger text scaler still produces aligned columns',
      (tester) async {
        // textScaler=1.5 magnifies glyphs by 50%. Pre-fix measurement
        // ignored the scaler, so cells truncated severely under large
        // accessibility text. Post-fix, the scaler participates in the
        // width calc.
        const columns = ['locale'];
        const rows = [
          {'locale': 'en_US'},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: Scaffold(
                body: SizedBox(
                  width: 800,
                  height: 400,
                  child: DisplayQueryWidget(
                    columns: columns,
                    rows: rows,
                    evenRowStyle: TextStyle(color: Colors.black),
                    oddRowStyle: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cellTextFinder = find.text('en_US');
        final renderedTextSize = tester.getSize(cellTextFinder);
        final cellContainerSize = tester.getSize(
          find
              .ancestor(
                of: cellTextFinder,
                matching: find.byType(Container),
              )
              .first,
        );

        const horizontalPadding = 12.0 * 2;
        final cellInnerWidth = cellContainerSize.width - horizontalPadding;

        expect(
          cellInnerWidth,
          greaterThanOrEqualTo(renderedTextSize.width),
          reason:
              'Under textScaler 1.5, cell inner width ($cellInnerWidth) '
              'must still be at least as wide as rendered text '
              '(${renderedTextSize.width}).',
        );
      },
    );
  });
}
