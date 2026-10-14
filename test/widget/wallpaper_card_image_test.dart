import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/presentation/widgets/deck/wallpaper_card.dart';

void main() {
  const sampleWallpaper = Wallpaper(
    id: 'test_card_1',
    title: 'Cyberpunk Skyline 2099',
    author: 'Neo Artist',
    sourceName: 'wallhaven.cc',
    thumbUrl: 'https://example.com/thumbnails/cyberpunk.jpg',
    fullUrl: 'https://example.com/wallpapers/cyberpunk_4k.jpg',
    resolution: '3840x2160',
    aspectRatio: '16:9',
    category: 'Cyberpunk',
    dominantColors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFF10B981)],
  );

  Widget buildTestCard({Wallpaper wallpaper = sampleWallpaper}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 600,
            child: WallpaperCard(wallpaper: wallpaper),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'WallpaperCard builds with CachedNetworkImage targeting fullUrl and memCacheWidth 1920',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestCard());

      final fullImageFinder = find.byWidgetPredicate(
        (w) => w is CachedNetworkImage && w.imageUrl == sampleWallpaper.fullUrl,
      );
      expect(fullImageFinder, findsOneWidget);

      final cachedImage = tester.widget<CachedNetworkImage>(fullImageFinder);
      expect(cachedImage.imageUrl, equals(sampleWallpaper.fullUrl));
      expect(cachedImage.memCacheWidth, equals(1920));
      expect(cachedImage.fit, equals(BoxFit.cover));
      expect(cachedImage.filterQuality, equals(FilterQuality.medium));
      expect(
        cachedImage.fadeInDuration,
        equals(const Duration(milliseconds: 250)),
      );
    },
  );

  testWidgets(
    'WallpaperCard wraps card image with RepaintBoundary for 60 FPS scrolling',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestCard());

      final fullImageFinder = find.byWidgetPredicate(
        (w) => w is CachedNetworkImage && w.imageUrl == sampleWallpaper.fullUrl,
      );
      expect(fullImageFinder, findsOneWidget);

      final repaintBoundaryFinder = find.descendant(
        of: find.byType(WallpaperCard),
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaryFinder, findsOneWidget);

      final repaintBoundary = tester.widget<RepaintBoundary>(
        repaintBoundaryFinder,
      );
      expect(repaintBoundary.child, equals(tester.widget(fullImageFinder)));
    },
  );

  testWidgets(
    'WallpaperCard renders progressive placeholder CachedNetworkImage targeting thumbUrl with memCacheWidth 800',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestCard());

      final fullImageFinder = find.byWidgetPredicate(
        (w) => w is CachedNetworkImage && w.imageUrl == sampleWallpaper.fullUrl,
      );
      expect(fullImageFinder, findsOneWidget);

      final thumbImageFinder = find.byWidgetPredicate(
        (w) =>
            w is CachedNetworkImage && w.imageUrl == sampleWallpaper.thumbUrl,
      );
      expect(thumbImageFinder, findsOneWidget);

      // Verify thumb image is nested inside full image as placeholder
      expect(
        find.descendant(of: fullImageFinder, matching: thumbImageFinder),
        findsOneWidget,
      );

      final thumbImage = tester.widget<CachedNetworkImage>(thumbImageFinder);
      expect(thumbImage.imageUrl, equals(sampleWallpaper.thumbUrl));
      expect(thumbImage.memCacheWidth, equals(800));
      expect(thumbImage.fit, equals(BoxFit.cover));
      expect(thumbImage.filterQuality, equals(FilterQuality.low));
    },
  );

  testWidgets(
    'WallpaperCard placeholder builder constructs nested placeholder and error states',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestCard());

      final fullImage = tester.widget<CachedNetworkImage>(
        find.byWidgetPredicate(
          (w) =>
              w is CachedNetworkImage && w.imageUrl == sampleWallpaper.fullUrl,
        ),
      );
      expect(fullImage.placeholder, isNotNull);

      // Programmatically invoke placeholder builder
      final placeholderWidget = fullImage.placeholder!(
        tester.element(find.byType(WallpaperCard)),
        sampleWallpaper.fullUrl,
      );
      expect(placeholderWidget, isA<CachedNetworkImage>());

      final thumbImage = placeholderWidget as CachedNetworkImage;
      expect(thumbImage.imageUrl, equals(sampleWallpaper.thumbUrl));
      expect(thumbImage.memCacheWidth, equals(800));

      // Test innermost placeholder container
      expect(thumbImage.placeholder, isNotNull);
      final thumbPlaceholder = thumbImage.placeholder!(
        tester.element(find.byType(WallpaperCard)),
        sampleWallpaper.thumbUrl,
      );
      expect(thumbPlaceholder, isA<Container>());

      // Test innermost error container
      expect(thumbImage.errorWidget, isNotNull);
      final thumbError = thumbImage.errorWidget!(
        tester.element(find.byType(WallpaperCard)),
        sampleWallpaper.thumbUrl,
        'image error',
      );
      expect(thumbError, isA<Container>());
    },
  );

  testWidgets('WallpaperCard errorWidget falls back to thumbnail image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestCard());

    final fullImage = tester.widget<CachedNetworkImage>(
      find.byWidgetPredicate(
        (w) => w is CachedNetworkImage && w.imageUrl == sampleWallpaper.fullUrl,
      ),
    );
    expect(fullImage.errorWidget, isNotNull);

    final errorFallback = fullImage.errorWidget!(
      tester.element(find.byType(WallpaperCard)),
      sampleWallpaper.fullUrl,
      'network error',
    );

    expect(errorFallback, isA<CachedNetworkImage>());
    final fallbackThumb = errorFallback as CachedNetworkImage;
    expect(fallbackThumb.imageUrl, equals(sampleWallpaper.thumbUrl));
    expect(fallbackThumb.fit, equals(BoxFit.cover));
    expect(fallbackThumb.filterQuality, equals(FilterQuality.low));
  });

  testWidgets(
    'WallpaperCard displays resolution badge, source badge, title, author, and color dots',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestCard());

      expect(find.text(sampleWallpaper.title), findsOneWidget);
      expect(find.text(sampleWallpaper.author), findsOneWidget);
      expect(find.text(sampleWallpaper.resolution), findsOneWidget);
      expect(find.text(sampleWallpaper.sourceName), findsOneWidget);
      expect(find.byIcon(Icons.high_quality_rounded), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    },
  );
}
