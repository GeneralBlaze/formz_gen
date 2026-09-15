# formz_gen

Code generation for [formz](https://pub.dev/packages/formz). Annotate one abstract class and `build_runner` writes the `FormzInput` subclasses, the error enums, the `FormzMixin` state with `copyWith` and value equality, the cross-field checks, and (opt-in) the field-changed events with a reducer you hand straight to your bloc.

## Why not write it by hand

You can. Every generated line below is plain `formz` code you could type yourself, and the first form you write that way takes ten minutes. The problem is that the cost is per field, not per form: every field is an enum, a class, two constructors, a validator, a state field, a `copyWith` parameter, an equality clause, an event class and a handler. A four-field profile screen is 150 lines of that; an eighteen-field onboarding flow is closer to 700, and every one of them has to be kept in sync by hand when a field is renamed or a rule changes. You already run `build_runner` for `freezed` and `json_serializable`, so the marginal cost of one more builder is a line in `pubspec.yaml`. What you get back is a form whose entire definition fits on one screen.

## Before and after

Measured on [`example/lib/profile_form.dart`](packages/formz_gen/example/lib/profile_form.dart), a four-field profile form with events enabled.

**After — 17 lines you write.** The whole form definition:

```dart
@FormzForm(events: true)
abstract class ProfileForm {
  @NotEmpty()
  @MaxLength(40)
  String get displayName;

  @NotEmpty()
  @Matches(handlePattern)
  @Validate(isNotReserved)
  String get handle;

  @Range(min: 13, max: 120)
  int get age;

  @MaxLength(160)
  String get bio;
}
```

**Before — 150 lines you no longer write.** This is [`example/lib/profile_form.g.dart`](packages/formz_gen/example/lib/profile_form.g.dart) verbatim, minus the header. One field of it:

```dart
enum HandleError { empty, invalid, isNotReserved }

class Handle extends FormzInput<String, HandleError> {
  const Handle.pure() : super.pure('');

  const Handle.dirty([super.value = '']) : super.dirty();

  @override
  HandleError? validator(String value) {
    if (value.isEmpty) return HandleError.empty;
    if (!RegExp(handlePattern).hasMatch(value)) return HandleError.invalid;
    if (!isNotReserved(value)) return HandleError.isNotReserved;
    return null;
  }
}

final class ProfileFormHandleChanged extends ProfileFormEvent {
  const ProfileFormHandleChanged(this.value);

  final String value;
}
```

plus the `handle` field, `copyWith` parameter, equality clause and `apply` arm inside `ProfileFormState`. Multiply by four fields and add the state class itself and you are at 150. The three-field [`sign_up_form.dart`](packages/formz_gen/example/lib/sign_up_form.dart) without events is 12 lines in, 100 lines out.

| Form | Lines you write | Lines generated |
| --- | ---: | ---: |
| `ProfileForm` (4 fields, events) | 17 | 150 |
| `SignUpForm` (3 fields, cross-field) | 12 | 100 |

## Install

```yaml
dependencies:
  formz: ^0.8.1
  formz_gen_annotation: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  formz_gen: ^0.1.0
```

```sh
dart run build_runner build
```

Add `part 'profile_form.g.dart';` to the file that holds the annotated class.

## What gets generated

For `@FormzForm() abstract class ProfileForm` with a getter `String get handle`:

| Generated | Name |
| --- | --- |
| Error enum, one member per validator in declaration order | `HandleError` |
| `FormzInput<String, HandleError>` with `pure()` and `dirty([value])` | `Handle` |
| State `with FormzMixin`, `copyWith`, `==`, `hashCode`, `inputs` | `ProfileFormState` |
| Cross-field getters (only for fields with `@SameAs`) | `confirmPasswordError`, `confirmPasswordDisplayError` |
| Events and reducer (only with `events: true`) | `ProfileFormEvent`, `ProfileFormHandleChanged`, `ProfileFormState.apply` |

Field types: `String`, `int`, `double`, `num`, `bool`, or a nullable version of them. Pure defaults are `''`, `0`, `0.0`, `0`, `false` and `null`.

## Validators

| Annotation | Error member | Generated check |
| --- | --- | --- |
| `@NotEmpty()` | `empty` | `value.isEmpty` |
| `@MinLength(8)` | `tooShort` | `value.length < 8` |
| `@MaxLength(40)` | `tooLong` | `value.length > 40` |
| `@Matches(pattern)` | `invalid` | `!RegExp(pattern).hasMatch(value)` |
| `@Range(min: 13, max: 120)` | `outOfRange` | `value < 13 \|\| value > 120` |
| `@Validate(fn)` | `fn` | `!fn(value)` |
| `@SameAs(#password)` | `mismatch` | `confirmPassword.value != password.value` |

Arguments are copied into the generated code as written, so `@Matches(handlePattern)` references your constant instead of inlining it.

`@Validate` takes a top-level function or a static method with the signature `bool Function(T value)`; the error member is named after it. Two validators on one field that produce the same error member (two `@Matches`, for example) are rejected at build time.

## Cross-field validation

`formz` validators only see their own value, so `@SameAs` is evaluated on the state, where the whole form is visible:

```dart
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
```

generates on `SignUpFormState`:

```dart
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
```

Field-level validators on the same field run first. `isValid`, `isNotValid` and `displayError` semantics stay exactly as `formz` defines them.

## Events and bloc wiring

With `@FormzForm(events: true)` the generator adds a sealed event per field and an `apply` reducer on the state:

```dart
ProfileFormState apply(ProfileFormEvent event) {
  return switch (event) {
    ProfileFormDisplayNameChanged(:final value) => copyWith(
      displayName: DisplayName.dirty(value),
    ),
    ...
  };
}
```

`formz_gen` has no dependency on `bloc`; the wiring is one handler:

```dart
sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileFieldChanged extends ProfileEvent {
  const ProfileFieldChanged(this.event);

  final ProfileFormEvent event;
}

final class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileFieldChanged>(
      (e, emit) => emit(state.copyWith(form: state.form.apply(e.event))),
    );
    on<ProfileSubmitted>(_onSubmitted);
  }
}
```

and in the widget:

```dart
TextField(
  onChanged: (v) => bloc.add(ProfileFieldChanged(ProfileFormHandleChanged(v))),
  decoration: InputDecoration(errorText: state.form.handle.displayError?.name),
)
```

Compose `ProfileFormState` into your own bloc state next to `FormzSubmissionStatus`; the generated state deliberately carries only the fields.

## Scope

State layer only. No widgets, no async validation, no list or dynamic fields. Field types are limited to the scalar set above.
