import 'package:flutterapp/services/auth/auth_provider.dart';
import 'package:flutterapp/services/auth/auth_user.dart';

void main() {}

class MocAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => throw UnimplementedError();

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }
}
