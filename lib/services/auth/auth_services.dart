import 'package:flutterapp/services/auth/auth_provider.dart';
import 'package:flutterapp/services/auth/auth_user.dart';
import 'package:flutterapp/services/auth/firebase_auth_provider.dart';

class AuthServices implements AuthProvider {
  final AuthProvider provider;
  const AuthServices(this.provider);

  factory AuthServices.firebase() => AuthServices(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) =>
      provider.login(
        email: email,
        password: password,
      );

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String email}) =>
      provider.sendPasswordReset(email: email);
}
