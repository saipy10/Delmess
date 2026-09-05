import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/inbox/presentation/controllers/inbox_controller.dart';
import 'package:delmess/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:delmess/features/labels/data/label_repository.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MessageRepository messageRepo;
  late LabelRepository labelRepo;
  late SenderMetadataRepository senderRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    messageRepo = DriftMessageRepository(db);
    labelRepo = DriftLabelRepository(db);
    senderRepo = DriftSenderMetadataRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 5 InboxScreen Sections & Category Navigation Tests', () {
    testWidgets('renders PINNED and RECENT sections when pinned conversation exists', (tester) async {
      final now = DateTime.now();

      // Pinned conversation message
      final pinnedMsg = SmsMessage(
        id: 'msg_pinned',
        threadId: 'thread_pinned',
        sender: 'AD-HDFCBN-T',
        header: 'HDFCBN',
        brand: 'HDFC Bank',
        body: 'Your account was credited with INR 50,000',
        receivedAt: now,
        category: CategoryType.transactional,
        isPinned: true,
        isRead: false,
        createdAt: now,
        updatedAt: now,
      );

      // Unpinned / Recent conversation message
      final recentMsg = SmsMessage(
        id: 'msg_recent',
        threadId: 'thread_recent',
        sender: 'AD-AMAZON-P',
        header: 'AMAZON',
        brand: 'Amazon India',
        body: 'Great summer deals available now',
        receivedAt: now.subtract(const Duration(minutes: 10)),
        category: CategoryType.promotional,
        isPinned: false,
        isRead: true,
        createdAt: now,
        updatedAt: now,
      );

      await messageRepo.insertMessages([pinnedMsg, recentMsg]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driftMessageRepositoryProvider.overrideWithValue(messageRepo),
            driftLabelRepositoryProvider.overrideWithValue(labelRepo),
            driftSenderMetadataRepositoryProvider.overrideWithValue(senderRepo),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: InboxScreen(),
          ),
        ),
      );

      // Allow streams to settle
      await tester.pumpAndSettle();

      // Verify PINNED and RECENT section headers appear
      expect(find.text('PINNED'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);

      // Verify both conversations are displayed
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Amazon India'), findsOneWidget);

      // Clean up test widget tree & flush timers
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('renders tailored empty state when category filter has no messages', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driftMessageRepositoryProvider.overrideWithValue(messageRepo),
            driftLabelRepositoryProvider.overrideWithValue(labelRepo),
            driftSenderMetadataRepositoryProvider.overrideWithValue(senderRepo),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: InboxScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Empty inbox title
      expect(find.text('No messages yet'), findsOneWidget);

      // Tap "Promotional" category chip
      final promoChip = find.textContaining('Promotional');
      expect(promoChip, findsOneWidget);
      await tester.tap(promoChip);
      await tester.pumpAndSettle();

      // Verify tailored promotional empty state appears
      expect(find.text('No promotional messages'), findsOneWidget);
      expect(
        find.text('New promotional SMS, deals, and discounts will automatically appear here.'),
        findsOneWidget,
      );

      // Clean up test widget tree & flush timers
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
