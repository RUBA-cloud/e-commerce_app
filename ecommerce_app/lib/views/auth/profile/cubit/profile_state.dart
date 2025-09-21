part of 'profile_cubit.dart';

enum ProfileStatus { idle, loading, success, error }

class ProfileState {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String street;

  /// If user already has an uploaded avatar (HTTP URL, Firebase Storage URL, etc.)
  final String? imageUrl;

  /// Newly picked image bytes (for preview + upload). Takes precedence over imageUrl if not null.
  final Uint8List? imageBytes;

  final ProfileStatus status;
  final String error;

  const ProfileState({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.street,
    this.imageUrl,
    this.imageBytes,
    this.status = ProfileStatus.idle,
    this.error = '',
  });

  factory ProfileState.initial() => const ProfileState(
    name: '',
    email: '',
    phone: '',
    address: '',
    street: '',
    imageUrl: null,
    imageBytes: null,
    status: ProfileStatus.idle,
    error: '',
  );

  ProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? street,
    String? imageUrl,
    Uint8List? imageBytes,
    ProfileStatus? status,
    String? error,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      street: street ?? this.street,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  List<Object?> get props => [
    name,
    email,
    phone,
    address,
    street,
    imageUrl,
    imageBytes,
    status,
    error,
  ];
}
