import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/inbox/presentation/controllers/inbox_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchState {
  final String query;
  final CategoryType? categoryFilter;
  final bool hasOtpOnly;

  const SearchState({
    this.query = '',
    this.categoryFilter,
    this.hasOtpOnly = false,
  });

  SearchState copyWith({
    String? query,
    CategoryType? Function()? categoryFilter,
    bool? hasOtpOnly,
  }) {
    return SearchState(
      query: query ?? this.query,
      categoryFilter: categoryFilter != null
          ? categoryFilter()
          : this.categoryFilter,
      hasOtpOnly: hasOtpOnly ?? this.hasOtpOnly,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    return const SearchState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategoryFilter(CategoryType? category) {
    state = state.copyWith(categoryFilter: () => category);
  }

  void toggleOtpOnly() {
    state = state.copyWith(hasOtpOnly: !state.hasOtpOnly);
  }

  void clearFilters() {
    state = const SearchState();
  }
}

final searchControllerProvider = NotifierProvider<SearchNotifier, SearchState>(
  () => SearchNotifier(),
);

final searchResultsProvider = Provider<List<SmsConversation>>((ref) {
  final inboxState = ref.watch(inboxControllerProvider);
  final searchState = ref.watch(searchControllerProvider);

  final query = searchState.query.trim().toLowerCase();
  final category = searchState.categoryFilter;
  final hasOtp = searchState.hasOtpOnly;

  return inboxState.conversations.where((SmsConversation conv) {
    if (conv.isDeleted) return false;

    // Filter by category
    if (category != null && conv.category != category) {
      return false;
    }

    // Filter by OTP presence
    if (hasOtp && conv.latestOtp == null) {
      return false;
    }

    // Query text match
    if (query.isNotEmpty) {
      final matchesSender =
          conv.sender.toLowerCase().contains(query) ||
          conv.senderDisplayName.toLowerCase().contains(query);
      final matchesBody = conv.messages.any(
        (m) => m.body.toLowerCase().contains(query),
      );
      final matchesOtp = conv.latestOtp?.toLowerCase().contains(query) ?? false;
      return matchesSender || matchesBody || matchesOtp;
    }

    return true;
  }).toList();
});
