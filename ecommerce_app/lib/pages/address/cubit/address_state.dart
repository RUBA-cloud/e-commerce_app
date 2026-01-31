import 'package:equatable/equatable.dart';

class AddressState extends Equatable {
  final bool loading;
  final bool success;
  final String? error;

  /// Selected map position
  final double? latitude;
  final double? longitude;

  const AddressState({
    this.loading = false,
    this.success = false,
    this.error,
    this.latitude,
    this.longitude,
  });

  factory AddressState.initial() => const AddressState();

  AddressState copyWith({
    bool? loading,
    bool? success,
    String? error,
    double? latitude,
    double? longitude,
  }) {
    return AddressState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [loading, success, error, latitude, longitude];
}
