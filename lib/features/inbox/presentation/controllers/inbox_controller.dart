import 'dart:async';

import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/classification/domain/message_classification_service.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InboxFolder { inbox, starred, pinned, archived, deleted }

class InboxState {
  final List<SmsConversation> conversations;
  final CategoryType? selectedCategory; // null = All
  final InboxFolder currentFolder;
  final bool isLoading;
  final String? errorMessage;
  final Map<CategoryType, int> categoryCounts;
  final Map<CategoryType, int> categoryUnreadCounts;
  final FolderCounts folderCounts;

  const InboxState({
    this.conversations = const [],
    this.selectedCategory,
    this.currentFolder = InboxFolder.inbox,
    this.isLoading = false,
    this.errorMessage,
    this.categoryCounts = const {},
    this.categoryUnreadCounts = const {},
    this.folderCounts = const FolderCounts(),
  });

  InboxState copyWith({
    List<SmsConversation>? conversations,
    CategoryType? Function()? selectedCategory,
    InboxFolder? currentFolder,
    bool? isLoading,
    String? errorMessage,
    Map<CategoryType, int>? categoryCounts,
    Map<CategoryType, int>? categoryUnreadCounts,
    FolderCounts? folderCounts,
  }) {
    return InboxState(
      conversations: conversations ?? this.conversations,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      currentFolder: currentFolder ?? this.currentFolder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      categoryUnreadCounts: categoryUnreadCounts ?? this.categoryUnreadCounts,
      folderCounts: folderCounts ?? this.folderCounts,
    );
  }

  /// Filtered list based on current folder and category filter.
  List<SmsConversation> get filteredConversations {
    return conversations.where((conv) {
      if (selectedCategory != null && conv.category != selectedCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  int getCountForCategory(CategoryType category) {
    return categoryCounts[category] ?? 0;
  }

  int getUnreadCountForCategory(CategoryType category) {
    return categoryUnreadCounts[category] ?? 0;
  }

  int get totalActiveCount => folderCounts.totalInbox;
  int get starredCount => folderCounts.starred;
  int get pinnedCount => folderCounts.pinned;
  int get archivedCount => folderCounts.archived;
  int get deletedCount => folderCounts.deleted;
}

class InboxNotifier extends Notifier<InboxState> {
  StreamSubscription<List<SmsConversation>>? _conversationsSub;
  StreamSubscription<Map<CategoryType, int>>? _categoryCountsSub;
  StreamSubscription<Map<CategoryType, int>>? _categoryUnreadCountsSub;
  StreamSubscription<FolderCounts>? _folderCountsSub;

  MessageRepository get _repo => ref.read(driftMessageRepositoryProvider);

  @override
  InboxState build() {
    ref.onDispose(() {
      _conversationsSub?.cancel();
      _categoryCountsSub?.cancel();
      _categoryUnreadCountsSub?.cancel();
      _folderCountsSub?.cancel();
    });

    _listenToCounts();
    _listenToConversations(null);

    // Asynchronously check and reclassify any existing messages under new rules
    Future.microtask(() async {
      try {
        await ref
            .read(messageClassificationServiceProvider)
            .reclassifyIfNeeded();
      } catch (_) {}
    });

    return const InboxState(isLoading: false);
  }

  void _listenToCounts() {
    _categoryCountsSub?.cancel();
    _categoryCountsSub = _repo.watchCategoryCounts().listen((counts) {
      state = state.copyWith(categoryCounts: counts);
    });

    _categoryUnreadCountsSub?.cancel();
    _categoryUnreadCountsSub = _repo.watchCategoryUnreadCounts().listen((
      unreads,
    ) {
      state = state.copyWith(categoryUnreadCounts: unreads);
    });

    _folderCountsSub?.cancel();
    _folderCountsSub = _repo.watchFolderCounts().listen((folderCounts) {
      state = state.copyWith(folderCounts: folderCounts);
    });
  }

  void _listenToConversations(CategoryType? category) {
    _conversationsSub?.cancel();
    _conversationsSub = _repo
        .watchInboxConversations(category: category)
        .listen(
          (convs) {
            state = state.copyWith(conversations: convs, isLoading: false);
          },
          onError: (err) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to load messages: $err',
            );
          },
        );
  }

  void selectCategory(CategoryType? category) {
    state = state.copyWith(selectedCategory: () => category);
    _listenToConversations(category);
  }

  void setFolder(InboxFolder folder) {
    state = state.copyWith(currentFolder: folder);
  }

  Future<void> toggleStar(String conversationId) async {
    final conv = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => SmsConversation(
        id: conversationId,
        sender: '',
        senderDisplayName: '',
        category: CategoryType.other,
        messages: const [],
      ),
    );
    if (conv.isStarred) {
      await _repo.unstar(conversationId);
    } else {
      await _repo.star(conversationId);
    }
  }

  Future<void> togglePin(String conversationId) async {
    final conv = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => SmsConversation(
        id: conversationId,
        sender: '',
        senderDisplayName: '',
        category: CategoryType.other,
        messages: const [],
      ),
    );
    if (conv.isPinned) {
      await _repo.unpin(conversationId);
    } else {
      await _repo.pin(conversationId);
    }
  }

  Future<void> toggleArchive(String conversationId) async {
    final conv = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => SmsConversation(
        id: conversationId,
        sender: '',
        senderDisplayName: '',
        category: CategoryType.other,
        messages: const [],
      ),
    );
    if (conv.isArchived) {
      await _repo.unarchive(conversationId);
    } else {
      await _repo.archive(conversationId);
    }
  }

  Future<void> moveToTrash(String conversationId) async {
    await _repo.softDelete(conversationId);
  }

  Future<void> restoreFromTrash(String conversationId) async {
    await _repo.restore(conversationId);
  }

  Future<void> markConversationAsRead(String conversationId) async {
    await _repo.markRead(conversationId);
  }
}

final inboxControllerProvider = NotifierProvider<InboxNotifier, InboxState>(
  () => InboxNotifier(),
);
