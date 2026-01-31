// lib/views/filterPage/cubit/filter_state.dart
import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/models/filter_model.dart';

enum FiltersStatus {
  initial,
  loading,
  loaded,
  applying,
  error,
}

class FiltersState extends Equatable {
  final FilterModel model;
  final FiltersStatus status;
  final String? error;

  const FiltersState({
    required this.model,
    this.status = FiltersStatus.initial,
    this.error,
  });

  factory FiltersState.initial() => FiltersState(
        model: FilterModel.initial(),
        status: FiltersStatus.initial,
        error: null,
      );

  FiltersState copyWith({
    FilterModel? model,
    FiltersStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return FiltersState(
      model: model ?? this.model,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        model,
        status,
        error ?? '',
      ];
}
