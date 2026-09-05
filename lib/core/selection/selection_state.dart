/// Immutable state representing active selection across any list.
class SelectionState {
  final bool isSelectionMode;
  final Set<String> selectedIds;

  const SelectionState({
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  int get selectedCount => selectedIds.length;
  bool isSelected(String id) => selectedIds.contains(id);

  SelectionState copyWith({bool? isSelectionMode, Set<String>? selectedIds}) {
    return SelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectionState &&
          runtimeType == other.runtimeType &&
          isSelectionMode == other.isSelectionMode &&
          selectedIds.length == other.selectedIds.length &&
          selectedIds.containsAll(other.selectedIds);

  @override
  int get hashCode => isSelectionMode.hashCode ^ selectedIds.hashCode;
}
