import 'package:delmess/core/constants/app_strings.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/database/database_seed_service.dart';
import 'package:delmess/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DelMessApp startup test - renders inbox successfully', (
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

    // Verify app title or app strings present
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Verify navigation tabs
    expect(find.text(AppStrings.navInbox), findsOneWidget);
    expect(find.text(AppStrings.navSearch), findsOneWidget);
    expect(find.text(AppStrings.navLabels), findsOneWidget);
    expect(find.text(AppStrings.navSettings), findsOneWidget);

    // Verify seeded conversations rendered
    expect(find.text('HDFC Bank'), findsWidgets);
  });
}
