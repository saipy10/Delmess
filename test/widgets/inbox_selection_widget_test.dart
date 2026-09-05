import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/theme/app_theme.dart';
import 'package:delmess/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Inbox displays database messages and handles long-press selection mode',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftMessageRepository(db);

      final now = DateTime(2026, 9, 1, 12, 0, 0);

      // Seed test messages
      await repo.insertMessages([
        SmsMessage(
          id: 'msg_1',
          threadId: 'conv_hdfc',
          sender: 'AD-HDFCBK-T',
          header: 'HDFCBK',
          brand: 'HDFC Bank',
          body: 'Your OTP is 482921 for transaction.',
          receivedAt: now,
          category: CategoryType.transactional,
          isStarred: true,
          isPinned: true,
          createdAt: now,
          updatedAt: now,
        ),
        SmsMessage(
          id: 'msg_2',
          threadId: 'conv_swiggy',
          sender: 'JD-SWIGGY-S',
          header: 'SWIGGY',
          brand: 'Swiggy',
          body: 'Your food is arriving in 10 mins.',
          receivedAt: now.subtract(const Duration(minutes: 5)),
          category: CategoryType.service,
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            driftMessageRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const InboxScreen(),
          ),
        ),
      );

      // Initial pump & settle
      await tester.pumpAndSettle();

      // Verify messages appear on screen
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Swiggy'), findsOneWidget);
      expect(find.text('DelMess'), findsOneWidget);

      // Long press on HDFC Bank tile to enter selection mode
      await tester.longPress(find.text('HDFC Bank'));
      await tester.pumpAndSettle();

      // Verify Selection App Bar appeared
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Tap on Swiggy tile to select it in selection mode
      await tester.tap(find.text('Swiggy'));
      await tester.pumpAndSettle();

      expect(find.text('2 selected'), findsOneWidget);

      // Tap Exit button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Normal AppBar restored
      expect(find.text('DelMess'), findsOneWidget);
      expect(find.text('2 selected'), findsNothing);

      // Clean up test widget tree & flush timers
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await db.close();
    },
  );
}
