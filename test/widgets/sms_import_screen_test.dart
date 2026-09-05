import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/inbox/presentation/screens/sms_import_screen.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sms_data_source.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsImportScreen Widget Tests', () {
    late AppDatabase db;
    late DriftMessageRepository repo;
    late FakeSmsDataSource fakeDataSource;
    late FakeSmsPermissionService fakePermissionService;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftMessageRepository(db);
      fakeDataSource = FakeSmsDataSource();
      fakePermissionService = FakeSmsPermissionService(
        initialState: SmsPermissionState.granted,
      );
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('renders import progress and transitions to completion', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            driftMessageRepositoryProvider.overrideWithValue(repo),
            smsDataSourceProvider.overrideWithValue(fakeDataSource),
            smsPermissionServiceProvider.overrideWithValue(
              fakePermissionService,
            ),
          ],
          child: const MaterialApp(home: SmsImportScreen()),
        ),
      );

      // Initial pump triggers post frame callback and sync
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Your messages are ready'), findsOneWidget);
      expect(find.text('Open Inbox'), findsOneWidget);
      expect(find.text('Successfully organized 3 messages.'), findsOneWidget);
    });
  });
}
