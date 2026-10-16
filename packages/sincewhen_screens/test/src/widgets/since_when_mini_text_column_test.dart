// packages/sincewhen_screens/test/src/widgets/since_when_mini_text_column_test.dart

import 'package:custom_widgets/custom_widgets.dart' show ExpandingTextField;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart';
import 'package:sincewhen_screens/src/widgets/since_when_mini_text_column.dart';

void main() {
  group('SinceWhenMiniTextColumn', () {
    test('static hint constants have expected values', () {
      expect(SinceWhenMiniTextColumn.contentHint, equals('Content (required)'));
      expect(SinceWhenMiniTextColumn.tldrHint, equals('tl;dr'));
      expect(SinceWhenMiniTextColumn.metaDataHint, equals('Metadata'));
    });

    testWidgets(
      'renders all fields, gaps, and scroll view with proper configuration',
      (tester) async {
        final contentController = TextEditingController(
          text: 'Initial content',
        );
        final tldrController = TextEditingController(text: 'Initial tldr');
        final metaDataController = TextEditingController(
          text: 'Initial metadata',
        );
        final contentFocusNode = FocusNode();

        addTearDown(() {
          contentController.dispose();
          tldrController.dispose();
          metaDataController.dispose();
          contentFocusNode.dispose();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SinceWhenMiniTextColumn(
                contentController: contentController,
                tldrController: tldrController,
                metaDataController: metaDataController,
                contentFocusNode: contentFocusNode,
                onContentChanged: (_) {},
                onTldrChanged: (_) {},
                onMetaDataChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(SingleChildScrollView), findsOneWidget);

        final textFields = tester
            .widgetList<ExpandingTextField>(find.byType(ExpandingTextField))
            .toList();
        expect(textFields.length, equals(3));

        // 1. Content field configuration
        final contentField = textFields[0];
        expect(contentField.controller, equals(contentController));
        expect(contentField.focusNode, equals(contentFocusNode));
        expect(
          contentField.hintText,
          equals(SinceWhenMiniTextColumn.contentHint),
        );
        expect(
          contentField.minLines,
          equals(SinceWhenMiniDimensions.contentMinLines),
        );
        expect(
          contentField.maxLines,
          equals(SinceWhenMiniDimensions.contentMaxLines),
        );

        // 2. TLDR field configuration
        final tldrField = textFields[1];
        expect(tldrField.controller, equals(tldrController));
        expect(tldrField.focusNode, isNull);
        expect(tldrField.hintText, equals(SinceWhenMiniTextColumn.tldrHint));
        expect(
          tldrField.minLines,
          equals(SinceWhenMiniDimensions.optionalFieldMinLines),
        );
        expect(
          tldrField.maxLines,
          equals(SinceWhenMiniDimensions.optionalFieldMaxLines),
        );

        // 3. Metadata field configuration
        final metaDataField = textFields[2];
        expect(metaDataField.controller, equals(metaDataController));
        expect(metaDataField.focusNode, isNull);
        expect(
          metaDataField.hintText,
          equals(SinceWhenMiniTextColumn.metaDataHint),
        );
        expect(
          metaDataField.minLines,
          equals(SinceWhenMiniDimensions.optionalFieldMinLines),
        );
        expect(
          metaDataField.maxLines,
          equals(SinceWhenMiniDimensions.optionalFieldMaxLines),
        );

        // Verify gaps between fields
        final gaps = tester.widgetList<Gap>(find.byType(Gap)).toList();
        expect(gaps.length, equals(2));
        expect(
          gaps[0].mainAxisExtent,
          equals(SinceWhenMiniDimensions.textFieldGap),
        );
        expect(
          gaps[1].mainAxisExtent,
          equals(SinceWhenMiniDimensions.textFieldGap),
        );
      },
    );

    testWidgets('triggers callbacks on field input', (tester) async {
      final contentController = TextEditingController();
      final tldrController = TextEditingController();
      final metaDataController = TextEditingController();
      final contentFocusNode = FocusNode();

      String? contentChange;
      String? tldrChange;
      String? metaDataChange;

      addTearDown(() {
        contentController.dispose();
        tldrController.dispose();
        metaDataController.dispose();
        contentFocusNode.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SinceWhenMiniTextColumn(
              contentController: contentController,
              tldrController: tldrController,
              metaDataController: metaDataController,
              contentFocusNode: contentFocusNode,
              onContentChanged: (value) => contentChange = value,
              onTldrChanged: (value) => tldrChange = value,
              onMetaDataChanged: (value) => metaDataChange = value,
            ),
          ),
        ),
      );

      final textFields = tester
          .widgetList<ExpandingTextField>(find.byType(ExpandingTextField))
          .toList();

      textFields[0].onChanged('Typed content');
      expect(contentChange, equals('Typed content'));

      textFields[1].onChanged('Typed tldr');
      expect(tldrChange, equals('Typed tldr'));

      textFields[2].onChanged('Typed metadata');
      expect(metaDataChange, equals('Typed metadata'));
    });
  });
}
