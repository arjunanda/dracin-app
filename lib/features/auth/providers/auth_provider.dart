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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '917313223480-ee7mo3q4nn5goj8k13ldfrn4udorgbp5.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );

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
      print('AUTH_DEBUG: Starting signIn()');
      // Force sign out first to ensure a fresh account selection pop-up
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print(
          'AUTH_DEBUG: googleUser is NULL (User cancelled or configuration error)',
        );
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      print('AUTH_DEBUG: User authenticated: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print('AUTH_DEBUG: idToken is NULL');
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Could not get ID Token from Google',
        );
        return;
      }

      print('AUTH_DEBUG: Sending idToken to backend: auth/google/login');
      final apiRes = await _authService.loginWithGoogle(idToken: idToken);
      print('AUTH_DEBUG: Backend Response: ${apiRes.data}');

      final token = apiRes.data?['token'];
      if (token == null) {
        print('AUTH_DEBUG: App token is NULL in backend response');
        throw Exception(apiRes.message);
      }

      await _storage.saveToken(token);
      final user = await _authService.getMe();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      print('AUTH_DEBUG: Login Successful');
    } catch (e) {
      print('AUTH_DEBUG ERROR: $e');
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
