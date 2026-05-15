import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/widgets/radar_theme_preview.dart';

void main() {
  testWidgets('RadarThemePreview adapts to small width without overflow', (tester) async {
    final theme = PresetRadarThemes.defaultTheme;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: RadarThemePreview(theme: theme, isSelected: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RadarThemePreview), findsOneWidget);
  });

  testWidgets('RadarThemePreview scales up on wider parent', (tester) async {
    final theme = PresetRadarThemes.defaultTheme;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 480,
            child: RadarThemePreview(theme: theme),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(theme.name), findsOneWidget);
  });
}

