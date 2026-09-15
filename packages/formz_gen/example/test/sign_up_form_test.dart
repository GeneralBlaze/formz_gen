import 'package:formz_gen_example/sign_up_form.dart';
import 'package:test/test.dart';

String runtimeValue() => String.fromCharCode(120);

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

    test('surfaces a mismatch when password changes after confirmation', () {
      final confirmed = const SignUpFormState().copyWith(
        password: const Password.dirty('password1'),
        confirmPassword: const ConfirmPassword.dirty('password1'),
      );
      expect(confirmed.confirmPasswordError, isNull);

      final changed = confirmed.copyWith(
        password: const Password.dirty('password2'),
      );
      expect(changed.confirmPasswordError, ConfirmPasswordError.mismatch);
      expect(
        changed.confirmPasswordDisplayError,
        ConfirmPasswordError.mismatch,
      );
    });

    test('is equal by value, not identity', () {
      final a = SignUpFormState(email: Email.dirty(runtimeValue()));
      final b = SignUpFormState(email: Email.dirty(runtimeValue()));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(a.copyWith(email: const Email.dirty('y')))));
    });

    test('copyWith without arguments returns an equal state', () {
      final state = SignUpFormState(email: Email.dirty(runtimeValue()));
      expect(state.copyWith(), equals(state));
    });
  });
}
