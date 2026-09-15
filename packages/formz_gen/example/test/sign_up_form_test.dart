import 'package:formz_gen_example/sign_up_form.dart';
import 'package:test/test.dart';

void main() {
  group('SignUpFormState', () {
    test('starts pure and invalid', () {
      const state = SignUpFormState();
      expect(state.isPure, isTrue);
      expect(state.isValid, isFalse);
      expect(state.confirmPasswordDisplayError, isNull);
    });

    test('reports email errors in declaration order', () {
      expect(const Email.dirty().error, EmailError.empty);
      expect(const Email.dirty('nope').error, EmailError.invalid);
      expect(const Email.dirty('a@b.co').error, isNull);
    });

    test('rejects short passwords', () {
      expect(const Password.dirty('short').error, PasswordError.tooShort);
      expect(const Password.dirty('long enough').error, isNull);
    });

    test('checks confirmPassword against the whole state', () {
      const state = SignUpFormState(
        email: Email.dirty('a@b.co'),
        password: Password.dirty('password1'),
        confirmPassword: ConfirmPassword.dirty('password2'),
      );
      expect(state.confirmPasswordError, ConfirmPasswordError.mismatch);
      expect(state.confirmPasswordDisplayError, ConfirmPasswordError.mismatch);
      expect(state.isValid, isFalse);

      final fixed = state.copyWith(
        confirmPassword: const ConfirmPassword.dirty('password1'),
      );
      expect(fixed.confirmPasswordError, isNull);
      expect(fixed.isValid, isTrue);
    });

    test('is equal by value', () {
      expect(
        const SignUpFormState(email: Email.dirty('x')),
        const SignUpFormState(email: Email.dirty('x')),
      );
      expect(
        const SignUpFormState(email: Email.dirty('x')).hashCode,
        const SignUpFormState(email: Email.dirty('x')).hashCode,
      );
    });
  });
}
