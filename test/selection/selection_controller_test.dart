import 'package:delmess/core/selection/selection_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Selection Controller & State Tests', () {
    test('initial state has selection mode disabled and 0 count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(selectionControllerProvider);
      expect(state.isSelectionMode, isFalse);
      expect(state.selectedIds, isEmpty);
      expect(state.selectedCount, 0);
    });

    test('enterSelection activates selection mode with item selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectionControllerProvider.notifier)
          .enterSelection('msg_1');
      final state = container.read(selectionControllerProvider);

      expect(state.isSelectionMode, isTrue);
      expect(state.selectedIds, {'msg_1'});
      expect(state.selectedCount, 1);
      expect(state.isSelected('msg_1'), isTrue);
      expect(state.isSelected('msg_2'), isFalse);
    });

    test('select adds multiple items and deselect removes item', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(selectionControllerProvider.notifier);
      notifier.enterSelection('msg_1');
      notifier.select('msg_2');
      notifier.select('msg_3');

      var state = container.read(selectionControllerProvider);
      expect(state.selectedCount, 3);
      expect(state.selectedIds, {'msg_1', 'msg_2', 'msg_3'});

      notifier.deselect('msg_2');
      state = container.read(selectionControllerProvider);
      expect(state.selectedCount, 2);
      expect(state.selectedIds, {'msg_1', 'msg_3'});
    });

    test('deselecting the final item automatically exits selection mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(selectionControllerProvider.notifier);
      notifier.enterSelection('msg_1');
      expect(
        container.read(selectionControllerProvider).isSelectionMode,
        isTrue,
      );

      notifier.deselect('msg_1');
      final state = container.read(selectionControllerProvider);
      expect(state.isSelectionMode, isFalse);
      expect(state.selectedCount, 0);
    });

    test('toggleSelection toggles individual items properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(selectionControllerProvider.notifier);
      // If not in selection mode, toggling enters selection mode
      notifier.toggleSelection('msg_1');
      expect(
        container.read(selectionControllerProvider).isSelected('msg_1'),
        isTrue,
      );

      notifier.toggleSelection('msg_2');
      expect(
        container.read(selectionControllerProvider).isSelected('msg_2'),
        isTrue,
      );

      // Toggle off msg_2
      notifier.toggleSelection('msg_2');
      expect(
        container.read(selectionControllerProvider).isSelected('msg_2'),
        isFalse,
      );
      expect(
        container.read(selectionControllerProvider).isSelected('msg_1'),
        isTrue,
      );
    });

    test('selectAll and clearSelection / exitSelection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(selectionControllerProvider.notifier);
      notifier.selectAll(['msg_1', 'msg_2', 'msg_3', 'msg_4']);

      var state = container.read(selectionControllerProvider);
      expect(state.isSelectionMode, isTrue);
      expect(state.selectedCount, 4);

      notifier.clearSelection();
      state = container.read(selectionControllerProvider);
      expect(state.isSelectionMode, isTrue);
      expect(state.selectedCount, 0);

      notifier.exitSelection();
      state = container.read(selectionControllerProvider);
      expect(state.isSelectionMode, isFalse);
      expect(state.selectedCount, 0);
    });
  });
}
