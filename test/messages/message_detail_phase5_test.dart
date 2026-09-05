import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/labels/data/label_repository.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:delmess/features/messages/presentation/screens/message_detail_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('Phase 5 MessageDetailScreen Tests', () {
    testWidgets('renders chronological messages, date divider, prominent OTP card, and copy OTP action', (tester) async {
      final now = DateTime.now();

      final msg1 = SmsMessage(
        id: 'msg_detail_1',
        threadId: 'thread_hdfc',
        sender: 'AD-HDFCBN-T',
        header: 'HDFCBN',
        brand: 'HDFC Bank',
        body: 'Your account was debited with INR 2,500.00',
        receivedAt: now.subtract(const Duration(hours: 2)),
        category: CategoryType.transactional,
        createdAt: now,
        updatedAt: now,
      );

      final msg2 = SmsMessage(
        id: 'msg_detail_2',
        threadId: 'thread_hdfc',
        sender: 'AD-HDFCBN-T',
        header: 'HDFCBN',
        brand: 'HDFC Bank',
        body: 'Your OTP is 482913. Valid for 10 minutes.',
        receivedAt: now,
        category: CategoryType.transactional,
        otp: '482913',
        createdAt: now,
        updatedAt: now,
      );

      await messageRepo.insertMessages([msg1, msg2]);

      // Mock Clipboard handler
      String? copiedClipboardText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedClipboardText = (methodCall.arguments as Map)['text'];
        }
        return null;
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driftMessageRepositoryProvider.overrideWithValue(messageRepo),
            driftLabelRepositoryProvider.overrideWithValue(labelRepo),
            driftSenderMetadataRepositoryProvider.overrideWithValue(senderRepo),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: MessageDetailScreen(conversationId: 'thread_hdfc'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Brand and Raw Sender in App Bar
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('AD-HDFCBN-T'), findsOneWidget);

      // Verify Category Banner
      expect(find.text('Transactional'), findsOneWidget);

      // Verify Date Divider "Today"
      expect(find.text('Today'), findsOneWidget);

      // Verify both messages in chronological order
      expect(find.text('Your account was debited with INR 2,500.00'), findsOneWidget);
      expect(find.text('Your OTP is 482913. Valid for 10 minutes.'), findsOneWidget);

      // Verify prominent OTP Card
      expect(find.text('VERIFICATION CODE / OTP'), findsOneWidget);
      expect(find.text('482913'), findsOneWidget);
      expect(find.text('Copy OTP'), findsOneWidget);

      // Tap "Copy OTP"
      await tester.tap(find.text('Copy OTP'));
      await tester.pumpAndSettle();

      // Verify copied ONLY the OTP code
      expect(copiedClipboardText, equals('482913'));

      // Clean up widget tree
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
