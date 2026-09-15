final class NotEmpty {
  const NotEmpty();
}

final class MinLength {
  const MinLength(this.length);

  final int length;
}

final class MaxLength {
  const MaxLength(this.length);

  final int length;
}

final class Matches {
  const Matches(this.pattern);

  final String pattern;
}

final class Range {
  const Range({required this.min, required this.max});

  final num min;
  final num max;
}

final class SameAs {
  const SameAs(this.field);

  final Symbol field;
}

final class Validate {
  const Validate(this.validator);

  final Function validator;
}
