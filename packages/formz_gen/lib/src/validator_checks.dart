import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:formz_gen/src/form_spec.dart';
import 'package:formz_gen/src/validator_spec.dart';
import 'package:source_gen/source_gen.dart';

const _reservedEnumMembers = {
  'values',
  'index',
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
};

void checkValidatorAgainstField(
  ValidatorSpec spec,
  DartObject value,
  GetterElement getter,
) {
  final type = getter.returnType;
  switch (spec) {
    case NotEmptySpec():
      _requireString(type, '@NotEmpty', getter);
    case MinLengthSpec():
      _requireString(type, '@MinLength', getter);
    case MaxLengthSpec():
      _requireString(type, '@MaxLength', getter);
    case MatchesSpec():
      _requireString(type, '@Matches', getter);
    case RangeSpec():
      _checkRange(type, value, getter);
    case ValidateSpec():
      _checkValidate(type, value, getter);
  }
}

void rejectInvalidErrorMembers(FieldSpec field, GetterElement getter) {
  final seen = <String>{};
  for (final member in field.errorMembers) {
    if (_reservedEnumMembers.contains(member)) {
      throw InvalidGenerationSourceError(
        '`$member` cannot be an enum member; rename the validator on '
        '`${field.name}`.',
        element: getter,
      );
    }
    if (!seen.add(member)) {
      throw InvalidGenerationSourceError(
        'Two validators on `${field.name}` both produce `$member`.',
        element: getter,
      );
    }
  }
}

void _requireString(DartType type, String annotation, GetterElement getter) {
  if (type.isDartCoreString && !_isNullable(type)) return;
  throw InvalidGenerationSourceError(
    '$annotation requires a non-nullable String field.',
    element: getter,
  );
}

bool _isNullable(DartType type) =>
    type.nullabilitySuffix == NullabilitySuffix.question;

void _checkRange(DartType type, DartObject value, GetterElement getter) {
  final isNum =
      type.isDartCoreInt || type.isDartCoreDouble || type.isDartCoreNum;
  if (!isNum || _isNullable(type)) {
    throw InvalidGenerationSourceError(
      '@Range requires a non-nullable num field.',
      element: getter,
    );
  }
  if (!type.isDartCoreInt) return;
  final min = value.getField('min')!;
  final max = value.getField('max')!;
  if (min.toIntValue() == null || max.toIntValue() == null) {
    throw InvalidGenerationSourceError(
      '@Range bounds on an int field must be integers.',
      element: getter,
    );
  }
}

void _checkValidate(DartType type, DartObject value, GetterElement getter) {
  final function = value.getField('validator')?.toFunctionValue();
  if (function == null) {
    throw InvalidGenerationSourceError(
      '@Validate must reference a top-level function or static method.',
      element: getter,
    );
  }
  if (!function.returnType.isDartCoreBool) {
    throw InvalidGenerationSourceError(
      '@Validate function `${function.name}` must return bool.',
      element: getter,
    );
  }
  final parameters = function.formalParameters;
  final typeSystem = getter.library.typeSystem;
  final accepts =
      parameters.length == 1 &&
      parameters.single.isPositional &&
      typeSystem.isAssignableTo(type, parameters.single.type);
  if (!accepts) {
    throw InvalidGenerationSourceError(
      '@Validate function `${function.name}` must accept '
      '${type.getDisplayString()} as its only parameter.',
      element: getter,
    );
  }
}
