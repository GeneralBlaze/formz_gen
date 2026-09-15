# formz_gen_annotation

Annotations for [formz_gen](https://pub.dev/packages/formz_gen), the `build_runner` generator for [formz](https://pub.dev/packages/formz). Pure Dart, no dependencies.

```yaml
dependencies:
  formz: ^0.8.1
  formz_gen_annotation: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  formz_gen: ^0.1.0
```

```dart
import 'package:formz/formz.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';

part 'sign_up_form.g.dart';

const emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';

bool isNotReserved(String value) => value != 'admin';

@FormzForm(events: true)
abstract class SignUpForm {
  @NotEmpty()
  @Matches(emailPattern)
  String get email;

  @MinLength(8)
  @MaxLength(64)
  @Validate(isNotReserved)
  String get password;

  @SameAs(#password)
  String get confirmPassword;

  @Range(min: 13, max: 120)
  int get age;
}
```

Then `dart run build_runner build`. The generated `sign_up_form.g.dart` holds `Email`, `Password`, `ConfirmPassword` and `Age` inputs, their error enums, `SignUpFormState`, and (with `events: true`) `SignUpFormEvent` plus `SignUpFormState.apply`. What each annotation generates, the error member it produces and the build-time checks are documented in the [formz_gen README](https://pub.dev/packages/formz_gen).
