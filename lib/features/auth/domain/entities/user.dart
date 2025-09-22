import 'package:equatable/equatable.dart';

enum UserType { guest, registered }

enum AuthProvider { phone, google, guest }

class User extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final UserType userType;
  final AuthProvider authProvider;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const User({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    required this.userType,
    required this.authProvider,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  bool get isGuest => userType == UserType.guest;
  bool get isRegistered => userType == UserType.registered;
  
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null) return email!.split('@').first;
    if (phone != null) return phone!;
    return 'Guest User';
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    UserType? userType,
    AuthProvider? authProvider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        photoUrl,
        userType,
        authProvider,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        isPhoneVerified,
      ];
}