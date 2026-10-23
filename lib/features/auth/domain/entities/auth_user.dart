import 'package:equatable/equatable.dart';

/// The signed-in account, without any Firebase types.
class AuthUser extends Equatable {
  const AuthUser({required this.uid, this.email});

  final String uid;
  final String? email;

  @override
  List<Object?> get props => [uid, email];
}
