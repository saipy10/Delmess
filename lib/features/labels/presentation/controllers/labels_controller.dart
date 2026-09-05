import 'dart:async';

import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/labels/data/label_repository.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LabelsState {
  final List<LabelModel> labels;
  final bool isLoading;

  const LabelsState({this.labels = const [], this.isLoading = false});

  LabelsState copyWith({List<LabelModel>? labels, bool? isLoading}) {
    return LabelsState(
      labels: labels ?? this.labels,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LabelsNotifier extends Notifier<LabelsState> {
  StreamSubscription<List<LabelModel>>? _labelsSub;
  LabelRepository get _repo => ref.read(driftLabelRepositoryProvider);

  @override
  LabelsState build() {
    ref.onDispose(() => _labelsSub?.cancel());
    _labelsSub = _repo.watchLabels().listen((list) {
      state = state.copyWith(labels: list, isLoading: false);
    });
    return const LabelsState(isLoading: true);
  }

  Future<void> addLabel({
    required String name,
    required Color color,
    IconData icon = Icons.label_outline,
  }) async {
    await _repo.createLabel(
      name: name,
      colorValue: color.toARGB32(),
      iconCode: icon.codePoint,
    );
  }

  Future<void> renameLabel(String id, String newName) async {
    await _repo.renameLabel(id, newName);
  }

  Future<void> deleteLabel(String id) async {
    await _repo.deleteLabel(id);
  }
}

final labelsControllerProvider = NotifierProvider<LabelsNotifier, LabelsState>(
  () => LabelsNotifier(),
);
