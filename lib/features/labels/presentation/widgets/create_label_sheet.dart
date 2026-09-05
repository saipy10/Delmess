import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/widgets/app_buttons.dart';
import 'package:delmess/features/labels/presentation/controllers/labels_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet modal to create custom SMS labels.
class CreateLabelSheet extends ConsumerStatefulWidget {
  const CreateLabelSheet({super.key});

  @override
  ConsumerState<CreateLabelSheet> createState() => _CreateLabelSheetState();
}

class _CreateLabelSheetState extends ConsumerState<CreateLabelSheet> {
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFF3F51B5);
  IconData _selectedIcon = Icons.label_outline;

  static const List<Color> _availableColors = [
    Color(0xFF3F51B5), // Indigo
    Color(0xFF00897B), // Teal
    Color(0xFFE65100), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF1565C0), // Blue
    Color(0xFFD32F2F), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFF546E7A), // Slate
  ];

  static const List<IconData> _availableIcons = [
    Icons.label_outline,
    Icons.credit_card,
    Icons.restaurant,
    Icons.shopping_bag_outlined,
    Icons.receipt_long,
    Icons.flight,
    Icons.health_and_safety_outlined,
    Icons.home_work_outlined,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref
        .read(labelsControllerProvider.notifier)
        .addLabel(name: name, color: _selectedColor, icon: _selectedIcon);

    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Label "$name" created'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppDimensions.space20,
        right: AppDimensions.space20,
        top: AppDimensions.space20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Label',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Name input
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Label Name',
                hintText: 'e.g. Utilities, Bills, Family',
                prefixIcon: Icon(Icons.tag),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppDimensions.space20),

            // Color picker row
            Text(
              'Select Color',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Wrap(
              spacing: AppDimensions.space8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    radius: isSelected ? 18 : 14,
                    backgroundColor: color,
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Icon picker row
            Text(
              'Select Icon',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Wrap(
              spacing: AppDimensions.space8,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return IconButton.filledTonal(
                  icon: Icon(icon),
                  style: IconButton.styleFrom(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    foregroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _selectedIcon = icon),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Submit CTA
            PrimaryButton(
              text: 'Save Label',
              width: double.infinity,
              onPressed: _submit,
            ),
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }
}
