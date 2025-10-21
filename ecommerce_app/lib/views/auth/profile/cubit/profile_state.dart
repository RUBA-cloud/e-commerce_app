// lib/views/auth/profile/cubit/profile_cubit.dart
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

enum ProfileStatus { idle, loading }

class ProfileState extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String street;

  final Uint8List? imageBytes; // picked but not uploaded
  final String? imageUrl; // existing avatar url

  final ProfileStatus status;
  final String error;

  const ProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.street = '',
    this.imageBytes,
    this.imageUrl,
    this.status = ProfileStatus.idle,
    this.error = '',
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? street,
    Uint8List? imageBytes, // pass null explicitly to clear
    String? imageUrl, // pass '' to clear
    ProfileStatus? status,
    String? error,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      street: street ?? this.street,
      imageBytes: imageBytes == null ? null : imageBytes,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        address,
        street,
        imageBytes,
        imageUrl,
        status,
        error
      ];
}
