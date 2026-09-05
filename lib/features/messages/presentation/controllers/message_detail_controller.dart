import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider to observe a specific conversation by ID reactively.
final conversationDetailProvider =
    StreamProvider.family<SmsConversation?, String>((ref, id) {
      final repo = ref.watch(driftMessageRepositoryProvider);
      return repo.watchConversation(id);
    });

/// Future provider for fallback/direct fetching
final conversationDetailFutureProvider =
    FutureProvider.family<SmsConversation?, String>((ref, id) async {
      final repo = ref.read(driftMessageRepositoryProvider);
      return repo.getConversationById(id);
    });
