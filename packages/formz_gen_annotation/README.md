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

Exports `FormzForm`, `NotEmpty`, `MinLength`, `MaxLength`, `Matches`, `Range`, `SameAs` and `Validate`. What each one generates, the error member it produces and the build-time checks are documented in the [formz_gen README](https://pub.dev/packages/formz_gen).
