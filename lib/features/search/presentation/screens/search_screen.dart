import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/widgets/app_chips.dart';
import 'package:delmess/core/widgets/empty_state_view.dart';
import 'package:delmess/features/inbox/presentation/widgets/conversation_tile.dart';
import 'package:delmess/features/search/presentation/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Search screen with instant live filtering and category toggles.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by sender, OTP, keyword...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchControllerProvider.notifier).setQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            ref.read(searchControllerProvider.notifier).setQuery(val);
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
              ),
              children: [
                // Has OTP Chip
                AppFilterChip(
                  label: 'Has OTP',
                  isSelected: searchState.hasOtpOnly,
                  icon: Icons.key_outlined,
                  onSelected: (_) {
                    ref.read(searchControllerProvider.notifier).toggleOtpOnly();
                  },
                ),
                const SizedBox(width: AppDimensions.space8),

                // Category Chips
                ...CategoryType.values.map((cat) {
                  final isSelected = searchState.categoryFilter == cat;
                  final accentColor = cat.getColor(context);
                  final bgColor = cat.getBackgroundColor(context);

                  return Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.space8),
                    child: AppFilterChip(
                      label: cat.displayName,
                      isSelected: isSelected,
                      icon: cat.icon,
                      activeColor: bgColor,
                      activeTextColor: accentColor,
                      onSelected: (_) {
                        ref
                            .read(searchControllerProvider.notifier)
                            .setCategoryFilter(isSelected ? null : cat);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results list or Empty State
          Expanded(
            child: searchResults.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No Matching Messages',
                    message: searchState.query.isNotEmpty
                        ? 'No SMS found matching "${searchState.query}".'
                        : 'Try searching for a bank name, OTP, or brand.',
                    actionLabel:
                        (searchState.query.isNotEmpty ||
                            searchState.categoryFilter != null ||
                            searchState.hasOtpOnly)
                        ? 'Clear Filters'
                        : null,
                    onAction: () {
                      _searchController.clear();
                      ref
                          .read(searchControllerProvider.notifier)
                          .clearFilters();
                    },
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final conversation = searchResults[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () {
                          context.push('/messages/${conversation.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
