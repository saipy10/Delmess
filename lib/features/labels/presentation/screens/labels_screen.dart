import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/widgets/app_cards.dart';
import 'package:delmess/core/widgets/empty_state_view.dart';
import 'package:delmess/features/labels/presentation/controllers/labels_controller.dart';
import 'package:delmess/features/labels/presentation/widgets/create_label_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Labels overview screen.
class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final labelsState = ref.watch(labelsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Labels')),
      body: labelsState.labels.isEmpty
          ? EmptyStateView(
              icon: Icons.label_outline,
              title: 'No Custom Labels',
              message:
                  'Create custom labels to tag and organize specific message types.',
              actionLabel: 'Create Label',
              onAction: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => const CreateLabelSheet(),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.space16),
              itemCount: labelsState.labels.length,
              itemBuilder: (context, index) {
                final label = labelsState.labels[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                  child: AppCard(
                    onTap: () {
                      context.push('/labels/${label.id}');
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: label.color.withValues(alpha: 0.15),
                          child: Icon(label.icon, color: label.color),
                        ),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${label.messageCount} conversations',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'labels_create_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => const CreateLabelSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Label'),
      ),
    );
  }
}
