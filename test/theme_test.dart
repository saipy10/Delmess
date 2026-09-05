import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delmess/core/theme/theme_provider.dart';
import 'package:delmess/main.dart';

void main() {
  testWidgets('Theme switching test - toggles light and dark modes', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DelMessApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Default mode is system
    expect(container.read(themeProvider), equals(ThemeMode.system));

    // Switch to dark mode
    container.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(container.read(themeProvider), equals(ThemeMode.dark));

    // Switch to light mode
    container.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(container.read(themeProvider), equals(ThemeMode.light));

    // Toggle theme
    container.read(themeProvider.notifier).toggleTheme();
    await tester.pumpAndSettle();
    expect(container.read(themeProvider), equals(ThemeMode.dark));
  });
}
