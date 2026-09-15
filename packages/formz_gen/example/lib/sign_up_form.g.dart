// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint

part of 'sign_up_form.dart';

// **************************************************************************
// FormzGenerator
// **************************************************************************

enum EmailError { empty, invalid }

class Email extends FormzInput<String, EmailError> {
  const Email.pure() : super.pure('');

  const Email.dirty([super.value = '']) : super.dirty();

  @override
  EmailError? validator(String value) {
    if (value.isEmpty) return EmailError.empty;
    if (!RegExp(emailPattern).hasMatch(value)) return EmailError.invalid;
    return null;
  }
}

enum PasswordError { tooShort }

class Password extends FormzInput<String, PasswordError> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordError? validator(String value) {
    if (value.length < 8) return PasswordError.tooShort;
    return null;
  }
}

enum ConfirmPasswordError { mismatch }

class ConfirmPassword extends FormzInput<String, ConfirmPasswordError> {
  const ConfirmPassword.pure() : super.pure('');

  const ConfirmPassword.dirty([super.value = '']) : super.dirty();

  @override
  ConfirmPasswordError? validator(String value) {
    return null;
  }
}

class SignUpFormState with FormzMixin {
  const SignUpFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
  });

  final Email email;

  final Password password;

  final ConfirmPassword confirmPassword;

  ConfirmPasswordError? get confirmPasswordError {
    final error = confirmPassword.error;
    if (error != null) return error;
    if (confirmPassword.value != password.value) {
      return ConfirmPasswordError.mismatch;
    }
    return null;
  }

  ConfirmPasswordError? get confirmPasswordDisplayError =>
      confirmPassword.isPure ? null : confirmPasswordError;

  @override
  bool get isValid => Formz.validate(inputs) && confirmPasswordError == null;

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    email,
    password,
    confirmPassword,
  ];

  SignUpFormState copyWith({
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
  }) {
    return SignUpFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignUpFormState &&
          other.email == email &&
          other.password == password &&
          other.confirmPassword == confirmPassword;

  @override
  int get hashCode => Object.hash(email, password, confirmPassword);
}
