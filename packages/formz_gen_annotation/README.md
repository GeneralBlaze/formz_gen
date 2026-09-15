# formz_gen_annotation

Annotations for [formz_gen](https://pub.dev/packages/formz_gen), the `build_runner` generator for [formz](https://pub.dev/packages/formz).

```yaml
dependencies:
  formz_gen_annotation: ^0.1.0

dev_dependencies:
  formz_gen: ^0.1.0
```

| Annotation | Purpose |
| --- | --- |
| `@FormzForm({bool events = false})` | Marks an abstract class as a form definition |
| `@NotEmpty()` | `value.isEmpty` → `empty` |
| `@MinLength(n)` | `value.length < n` → `tooShort` |
| `@MaxLength(n)` | `value.length > n` → `tooLong` |
| `@Matches(pattern)` | `!RegExp(pattern).hasMatch(value)` → `invalid` |
| `@Range(min: a, max: b)` | `value < a \|\| value > b` → `outOfRange` |
| `@Validate(fn)` | `!fn(value)` → member named after `fn` |
| `@SameAs(#other)` | `value != other.value`, evaluated on the form state → `mismatch` |

See the `formz_gen` README for the generated output and bloc wiring.
