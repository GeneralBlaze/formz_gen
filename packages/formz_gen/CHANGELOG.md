## 0.1.0

- Initial release: generates `FormzInput` subclasses, error enums and a `FormzMixin` state class from a `@FormzForm` abstract class.
- Built-in validators: `NotEmpty`, `MinLength`, `MaxLength`, `Matches`, `Range`, `Validate`.
- Cross-field validation via `@SameAs`, evaluated against the whole form state.
- Field-changed events and an `apply` reducer behind `@FormzForm(events: true)`.
- Getters inherited from superclasses (with type arguments substituted) and mixins are included.
- Build-time checks: validator/field type compatibility, `@Validate` signature, reserved field names, nullable fields with built-in validators, duplicate or reserved enum members.
