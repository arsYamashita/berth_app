import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
part 'login_controller.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default("") String email,
    @Default("") String password,
  }) = _LoginState;
}

final loginProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>(
        (ref) => LoginController());

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState());

  void inputEmail(String email) {
    state = state.copyWith(email: email);
  }

  void inputPassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<String> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: state.email, password: state.password);
          
      return "ログインしました";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }
}
