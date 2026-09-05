import 'package:delmess/core/constants/app_strings.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/database/database_seed_service.dart';
import 'package:delmess/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigation test - switches between bottom bar destinations', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final seeder = DatabaseSeedService(
      messageRepo: container.read(driftMessageRepositoryProvider),
      labelRepo: container.read(driftLabelRepositoryProvider),
      senderRepo: container.read(driftSenderMetadataRepositoryProvider),
      db: container.read(appDatabaseProvider),
    );
    await seeder.resetAndSeed();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DelMessApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initially on Inbox
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Navigate to Search tab
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Search by sender, OTP, keyword...'), findsOneWidget);

    // Navigate to Labels tab
    await tester.tap(find.byIcon(Icons.label_outline));
    await tester.pumpAndSettle();
    expect(find.text('Banking'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.settingsGeneral), findsOneWidget);
    expect(find.text(AppStrings.settingsOrganization), findsOneWidget);
    expect(find.text(AppStrings.settingsPrivacy), findsOneWidget);
    expect(find.text(AppStrings.settingsAppearance), findsOneWidget);

    // Navigate to Settings Appearance subpage
    await tester.tap(find.text(AppStrings.settingsAppearance));
    await tester.pumpAndSettle();
    expect(find.text('System Default'), findsOneWidget);
    expect(find.text('Light Mode'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });
}
