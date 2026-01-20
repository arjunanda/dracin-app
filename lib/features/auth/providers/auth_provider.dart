import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading, initial }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(apiClientProvider);
  return AuthService(dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final storage = SecureStorage();
  return AuthNotifier(authService, storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SecureStorage _storage;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  AuthNotifier(this._authService, this._storage) : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _storage.getToken();
    if (token != null) {
      try {
        final user = await _authService.getMe();
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } catch (e) {
        await _storage.deleteToken();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Could not get ID Token from Google',
        );
        return;
      }

      final apiRes = await _authService.loginWithGoogle(idToken: idToken);
      final token = apiRes.data?['token'];
      if (token == null) {
        throw Exception(apiRes.message);
      }
      await _storage.saveToken(token);
      final user = await _authService.getMe();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.deleteToken();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}
