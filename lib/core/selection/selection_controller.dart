import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'selection_state.dart';

class SelectionNotifier extends Notifier<SelectionState> {
  @override
  SelectionState build() => const SelectionState();

  void enterSelection(String id) {
    state = SelectionState(isSelectionMode: true, selectedIds: {id});
  }

  void select(String id) {
    if (!state.isSelectionMode) {
      enterSelection(id);
      return;
    }
    state = state.copyWith(selectedIds: {...state.selectedIds, id});
  }

  void deselect(String id) {
    final updated = Set<String>.from(state.selectedIds)..remove(id);
    if (updated.isEmpty) {
      exitSelection();
    } else {
      state = state.copyWith(selectedIds: updated);
    }
  }

  void toggleSelection(String id) {
    if (!state.isSelectionMode) {
      enterSelection(id);
      return;
    }

    if (state.selectedIds.contains(id)) {
      deselect(id);
    } else {
      select(id);
    }
  }

  void selectAll(List<String> allIds) {
    if (allIds.isEmpty) return;
    state = SelectionState(
      isSelectionMode: true,
      selectedIds: Set<String>.from(allIds),
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  void exitSelection() {
    state = const SelectionState(isSelectionMode: false, selectedIds: {});
  }
}

final selectionControllerProvider =
    NotifierProvider<SelectionNotifier, SelectionState>(
      () => SelectionNotifier(),
    );
