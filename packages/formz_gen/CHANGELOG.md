## 0.1.0

- Initial release: generates `FormzInput` subclasses, error enums and a `FormzMixin` state class from a `@FormzForm` abstract class.
- Built-in validators: `NotEmpty`, `MinLength`, `MaxLength`, `Matches`, `Range`, `Validate`.
- Cross-field validation via `@SameAs`, evaluated against the whole form state.
- Field-changed events and an `apply` reducer behind `@FormzForm(events: true)`.
