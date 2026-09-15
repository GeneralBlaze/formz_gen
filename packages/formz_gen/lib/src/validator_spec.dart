import 'package:formz_gen/src/naming.dart';

sealed class ValidatorSpec {
  const ValidatorSpec();

  String get errorMember;

  String check(String errorEnum);
}

final class NotEmptySpec extends ValidatorSpec {
  const NotEmptySpec();

  @override
  String get errorMember => 'empty';

  @override
  String check(String errorEnum) =>
      'if (value.isEmpty) return $errorEnum.empty;';
}

final class MinLengthSpec extends ValidatorSpec {
  const MinLengthSpec(this.length);

  final String length;

  @override
  String get errorMember => 'tooShort';

  @override
  String check(String errorEnum) =>
      'if (value.length < $length) return $errorEnum.tooShort;';
}

final class MaxLengthSpec extends ValidatorSpec {
  const MaxLengthSpec(this.length);

  final String length;

  @override
  String get errorMember => 'tooLong';

  @override
  String check(String errorEnum) =>
      'if (value.length > $length) return $errorEnum.tooLong;';
}

final class MatchesSpec extends ValidatorSpec {
  const MatchesSpec(this.pattern);

  final String pattern;

  @override
  String get errorMember => 'invalid';

  @override
  String check(String errorEnum) =>
      'if (!RegExp($pattern).hasMatch(value)) return $errorEnum.invalid;';
}

final class RangeSpec extends ValidatorSpec {
  const RangeSpec({required this.min, required this.max});

  final String min;
  final String max;

  @override
  String get errorMember => 'outOfRange';

  @override
  String check(String errorEnum) =>
      'if (value < $min || value > $max) return $errorEnum.outOfRange;';
}

final class ValidateSpec extends ValidatorSpec {
  const ValidateSpec(this.function);

  final String function;

  @override
  String get errorMember => lastSegment(function);

  @override
  String check(String errorEnum) =>
      'if (!$function(value)) return $errorEnum.$errorMember;';
}
