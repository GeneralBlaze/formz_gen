import 'package:formz/formz.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';

part 'sign_up_form.g.dart';

const emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';

@FormzForm()
abstract class SignUpForm {
  @NotEmpty()
  @Matches(emailPattern)
  String get email;

  @MinLength(8)
  String get password;

  @SameAs(#password)
  String get confirmPassword;
}
