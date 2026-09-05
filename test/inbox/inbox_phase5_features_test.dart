import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/inbox/presentation/widgets/conversation_tile.dart';
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

  group('Phase 5 MessageRepository Single-Message Granular Operations', () {
    test('starMessage and unstarMessage updates only the target message', () async {
      final now = DateTime.now();
      final msg1 = SmsMessage(
        id: 'msg_1',
        threadId: 'thread_1',
        sender: 'AD-HDFCBN-T',
        header: 'HDFCBN',
        body: 'OTP is 123456',
        receivedAt: now,
        category: CategoryType.transactional,
        createdAt: now,
        updatedAt: now,
        isStarred: false,
      );
      final msg2 = SmsMessage(
        id: 'msg_2',
        threadId: 'thread_1',
        sender: 'AD-HDFCBN-T',
        header: 'HDFCBN',
        body: 'Your account was debited',
        receivedAt: now.add(const Duration(minutes: 1)),
        category: CategoryType.transactional,
        createdAt: now,
        updatedAt: now,
        isStarred: false,
      );

      await messageRepo.insertMessages([msg1, msg2]);

      // Star only msg_1
      await messageRepo.starMessage('msg_1');
      final fetched1 = await messageRepo.getMessageById('msg_1');
      final fetched2 = await messageRepo.getMessageById('msg_2');

      expect(fetched1?.isStarred, isTrue);
      expect(fetched2?.isStarred, isFalse);

      // Unstar msg_1
      await messageRepo.unstarMessage('msg_1');
      final unstarred1 = await messageRepo.getMessageById('msg_1');
      expect(unstarred1?.isStarred, isFalse);
    });

    test('deleteMessage soft deletes only the target message', () async {
      final now = DateTime.now();
      final msg1 = SmsMessage(
        id: 'msg_del_1',
        threadId: 'thread_del',
        sender: 'AD-SWIGGY',
        header: 'SWIGGY',
        body: 'Order placed',
        receivedAt: now,
        category: CategoryType.service,
        createdAt: now,
        updatedAt: now,
      );
      final msg2 = SmsMessage(
        id: 'msg_del_2',
        threadId: 'thread_del',
        sender: 'AD-SWIGGY',
        header: 'SWIGGY',
        body: 'Order delivered',
        receivedAt: now.add(const Duration(minutes: 5)),
        category: CategoryType.service,
        createdAt: now,
        updatedAt: now,
      );

      await messageRepo.insertMessages([msg1, msg2]);

      await messageRepo.deleteMessage('msg_del_1');
      final fetched1 = await messageRepo.getMessageById('msg_del_1');
      final fetched2 = await messageRepo.getMessageById('msg_del_2');

      expect(fetched1?.isDeleted, isTrue);
      expect(fetched2?.isDeleted, isFalse);
    });

    test('watchConversation streams conversation reactively', () async {
      final now = DateTime.now();
      final msg = SmsMessage(
        id: 'msg_watch_1',
        threadId: 'thread_watch',
        sender: 'AD-AMAZON-P',
        header: 'AMAZON',
        body: 'Great deals today',
        receivedAt: now,
        category: CategoryType.promotional,
        createdAt: now,
        updatedAt: now,
      );

      await messageRepo.insertMessage(msg);

      final stream = messageRepo.watchConversation('thread_watch');
      final firstConv = await stream.first;
      expect(firstConv, isNotNull);
      expect(firstConv?.sender, equals('AD-AMAZON-P'));
      expect(firstConv?.category, equals(CategoryType.promotional));
    });
  });

  group('Phase 5 ConversationTile Widget Tests', () {
    testWidgets('renders unread indicator dot and message count badge when multiple messages exist', (tester) async {
      final now = DateTime.now();
      final msg1 = SmsMessage(
        id: 'm1',
        threadId: 't1',
        sender: 'AD-HDFCBK-T',
        header: 'HDFCBK',
        body: 'Your OTP is 482913. Valid for 10 minutes.',
        receivedAt: now,
        category: CategoryType.transactional,
        isRead: false,
        createdAt: now,
        updatedAt: now,
      );
      final msg2 = SmsMessage(
        id: 'm2',
        threadId: 't1',
        sender: 'AD-HDFCBK-T',
        header: 'HDFCBK',
        body: 'Previous transaction of Rs 500',
        receivedAt: now.subtract(const Duration(hours: 1)),
        category: CategoryType.transactional,
        isRead: true,
        createdAt: now,
        updatedAt: now,
      );

      final conversation = SmsConversation(
        id: 't1',
        sender: 'AD-HDFCBK-T',
        senderDisplayName: 'HDFC Bank',
        category: CategoryType.transactional,
        messages: [msg1, msg2],
        isPinned: true,
        isStarred: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driftMessageRepositoryProvider.overrideWithValue(messageRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConversationTile(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify sender display name
      expect(find.text('HDFC Bank'), findsOneWidget);

      // Verify message count badge "2"
      expect(find.text('2'), findsOneWidget);

      // Verify OTP chip "OTP: 482913"
      expect(find.text('OTP: 482913'), findsOneWidget);

      // Verify category badge "Transactional"
      expect(find.text('Transactional'), findsOneWidget);

      // Verify pinned icon
      expect(find.byIcon(Icons.push_pin), findsOneWidget);

      // Verify starred icon
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('supports swipe right gesture to trigger mark read/unread', (tester) async {
      final now = DateTime.now();
      final msg = SmsMessage(
        id: 'm_read',
        threadId: 't_read',
        sender: 'AD-SWIGGY',
        header: 'SWIGGY',
        body: 'Your food is arriving',
        receivedAt: now,
        category: CategoryType.service,
        isRead: false,
        createdAt: now,
        updatedAt: now,
      );

      final conversation = SmsConversation(
        id: 't_read',
        sender: 'AD-SWIGGY',
        senderDisplayName: 'Swiggy',
        category: CategoryType.service,
        messages: [msg],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driftMessageRepositoryProvider.overrideWithValue(messageRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConversationTile(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify Dismissible exists
      expect(find.byType(Dismissible), findsOneWidget);

      // Fling right on the Dismissible
      await tester.fling(find.byType(Dismissible), const Offset(500, 0), 1000);
      await tester.pumpAndSettle();

      // Verify SnackBar appears with undo
      expect(find.text('Marked as read'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
    });
  });
}
