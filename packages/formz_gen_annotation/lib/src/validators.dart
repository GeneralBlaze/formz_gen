import 'package:meta/meta.dart';

@immutable
class NotEmpty {
  const NotEmpty();
}

@immutable
class MinLength {
  const MinLength(this.length);

  final int length;
}

@immutable
class MaxLength {
  const MaxLength(this.length);

  final int length;
}

@immutable
class Matches {
  const Matches(this.pattern);

  final String pattern;
}

@immutable
class Range {
  const Range({required this.min, required this.max});

  final num min;
  final num max;
}

@immutable
class SameAs {
  const SameAs(this.field);

  final Symbol field;
}

@immutable
class Validate {
  const Validate(this.validator);

  final Function validator;
}
