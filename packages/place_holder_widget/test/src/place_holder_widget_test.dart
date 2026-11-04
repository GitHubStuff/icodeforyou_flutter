// packages/place_holder_widget/test/src/place_holder_widget_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:place_holder_widget/place_holder_widget.dart';

void main() {
  const placeholderAsset = 'assets/placeholder512x512.png';
  const decodeSize = 256;

  /// Pumps [widget] inside a minimal, Material-free tree so the test
  /// exercises only what `PlaceHolderWidget` itself depends on.
  Future<void> pumpPlaceHolder(WidgetTester tester, Widget widget) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    );
  }

  group('PlaceHolderWidget', () {
    testWidgets('can be instantiated as a const widget', (tester) async {
      await pumpPlaceHolder(tester, const PlaceholderWidget());

      expect(find.byType(PlaceholderWidget), findsOneWidget);
    });

    testWidgets('forwards key to the widget', (tester) async {
      // A runtime key makes this a non-const construction, which records
      // an LCOV hit on the const constructor line.
      final key = UniqueKey();

      await pumpPlaceHolder(tester, PlaceholderWidget(key: key));

      expect(find.byKey(key), findsOneWidget);
      expect(tester.widget(find.byKey(key)), isA<PlaceholderWidget>());
    });

    testWidgets('renders the image centered in its parent', (tester) async {
      await pumpPlaceHolder(tester, const PlaceholderWidget());

      final center = find.descendant(
        of: find.byType(PlaceholderWidget),
        matching: find.byType(Center),
      );
      expect(center, findsOneWidget);

      final image = find.descendant(
        of: center,
        matching: find.byType(Image),
      );
      expect(image, findsOneWidget);
    });

    testWidgets('scales the image with BoxFit.contain', (tester) async {
      await pumpPlaceHolder(tester, const PlaceholderWidget());

      final image = tester.widget<Image>(find.byType(Image));

      expect(image.fit, BoxFit.contain);
    });

    testWidgets('loads the bundled placeholder asset', (tester) async {
      await pumpPlaceHolder(tester, const PlaceholderWidget());

      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image;

      // cacheWidth / cacheHeight wrap the AssetImage in a ResizeImage.
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<AssetImage>());

      final asset = resize.imageProvider as AssetImage;
      expect(asset.assetName, placeholderAsset);
      expect(asset.package, isNull);
    });

    testWidgets('caps the decode size at 256x256 pixels', (tester) async {
      await pumpPlaceHolder(tester, const PlaceholderWidget());

      final image = tester.widget<Image>(find.byType(Image));
      final resize = image.image as ResizeImage;

      expect(resize.width, decodeSize);
      expect(resize.height, decodeSize);
    });
  });
}
