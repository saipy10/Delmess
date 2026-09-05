import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LabelAssignmentDialog extends ConsumerStatefulWidget {
  final List<String> messageIds;
  final Set<String> initialSelectedLabelIds;

  const LabelAssignmentDialog({
    super.key,
    required this.messageIds,
    this.initialSelectedLabelIds = const {},
  });

  @override
  ConsumerState<LabelAssignmentDialog> createState() =>
      _LabelAssignmentDialogState();
}

class _LabelAssignmentDialogState extends ConsumerState<LabelAssignmentDialog> {
  late Set<String> _selectedLabelIds;
  final TextEditingController _newLabelController = TextEditingController();
  bool _isCreatingLabel = false;

  @override
  void initState() {
    super.initState();
    _selectedLabelIds = Set<String>.from(widget.initialSelectedLabelIds);
  }

  @override
  void dispose() {
    _newLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelRepo = ref.watch(driftLabelRepositoryProvider);

    return StreamBuilder<List<LabelModel>>(
      stream: labelRepo.watchLabels(),
      builder: (context, snapshot) {
        final labels = snapshot.data ?? [];

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.label_outline),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  'Assign Labels (${widget.messageIds.length} SMS)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isCreatingLabel) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newLabelController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'New label name',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            final name = _newLabelController.text.trim();
                            if (name.isNotEmpty) {
                              final newLabel = await labelRepo.createLabel(
                                name: name,
                              );
                              setState(() {
                                _selectedLabelIds.add(newLabel.id);
                                _newLabelController.clear();
                                _isCreatingLabel = false;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isCreatingLabel = false;
                              _newLabelController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                  if (labels.isEmpty && !_isCreatingLabel)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.space16,
                      ),
                      child: Text(
                        'No labels created yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...labels.map((lbl) {
                      final isChecked = _selectedLabelIds.contains(lbl.id);
                      return CheckboxListTile(
                        value: isChecked,
                        dense: true,
                        title: Row(
                          children: [
                            Icon(lbl.icon, size: 20, color: lbl.color),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(child: Text(lbl.name)),
                          ],
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedLabelIds.add(lbl.id);
                            } else {
                              _selectedLabelIds.remove(lbl.id);
                            }
                          });
                        },
                      );
                    }),
                  if (!_isCreatingLabel)
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Label'),
                      onPressed: () => setState(() => _isCreatingLabel = true),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                // Apply label selection
                final allLabelIds = labels.map((l) => l.id).toList();
                final removedLabelIds = allLabelIds
                    .where((id) => !_selectedLabelIds.contains(id))
                    .toList();

                if (_selectedLabelIds.isNotEmpty) {
                  await labelRepo.assignLabels(
                    widget.messageIds,
                    _selectedLabelIds.toList(),
                  );
                }
                if (removedLabelIds.isNotEmpty) {
                  await labelRepo.removeLabels(
                    widget.messageIds,
                    removedLabelIds,
                  );
                }

                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
