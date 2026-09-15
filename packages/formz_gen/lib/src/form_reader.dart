import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:formz_gen/src/annotation_args.dart';
import 'package:formz_gen/src/form_spec.dart';
import 'package:formz_gen/src/validator_spec.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';
import 'package:source_gen/source_gen.dart';

const _package = 'formz_gen_annotation';
const _notEmpty = TypeChecker.typeNamed(NotEmpty, inPackage: _package);
const _minLength = TypeChecker.typeNamed(MinLength, inPackage: _package);
const _maxLength = TypeChecker.typeNamed(MaxLength, inPackage: _package);
const _matches = TypeChecker.typeNamed(Matches, inPackage: _package);
const _range = TypeChecker.typeNamed(Range, inPackage: _package);
const _sameAs = TypeChecker.typeNamed(SameAs, inPackage: _package);
const _validate = TypeChecker.typeNamed(Validate, inPackage: _package);

const _pureValues = {
  'String': "''",
  'int': '0',
  'double': '0.0',
  'num': '0',
  'bool': 'false',
};

FormSpec readForm(Element element, ConstantReader annotation) {
  if (element is! ClassElement || !element.isAbstract) {
    throw InvalidGenerationSourceError(
      '@FormzForm can only annotate an abstract class.',
      element: element,
    );
  }
  final fields = [
    for (final getter in element.getters)
      if (!getter.isStatic) _readField(getter),
  ];
  final names = fields.map((f) => f.name).toSet();
  for (final field in fields) {
    for (final target in field.sameAs) {
      if (!names.contains(target)) {
        throw InvalidGenerationSourceError(
          '@SameAs(#$target) on `${field.name}` references an unknown field.',
          element: element,
        );
      }
    }
  }
  return FormSpec(
    name: element.name!,
    events: annotation.read('events').boolValue,
    fields: fields,
  );
}

FieldSpec _readField(GetterElement getter) {
  final type = getter.returnType;
  final typeName = type.getDisplayString();
  final pureValue = _pureValueFor(type, typeName, getter);
  final validators = <ValidatorSpec>[];
  final sameAs = <String>[];
  for (final meta in getter.metadata.annotations) {
    final value = meta.computeConstantValue();
    final valueType = value?.type;
    if (value == null || valueType == null) continue;
    if (_sameAs.isExactlyType(valueType)) {
      sameAs.add(value.getField('field')!.toSymbolValue()!);
      continue;
    }
    final args = AnnotationArgs.parse(meta.toSource());
    final spec = _validatorFor(valueType, args);
    if (spec != null) validators.add(spec);
  }
  _rejectDuplicateMembers(getter, validators);
  return FieldSpec(
    name: getter.name!,
    type: typeName,
    pureValue: pureValue,
    validators: validators,
    sameAs: sameAs,
  );
}

ValidatorSpec? _validatorFor(DartType type, AnnotationArgs args) {
  if (_notEmpty.isExactlyType(type)) return const NotEmptySpec();
  if (_minLength.isExactlyType(type)) return MinLengthSpec(args.positional[0]);
  if (_maxLength.isExactlyType(type)) return MaxLengthSpec(args.positional[0]);
  if (_matches.isExactlyType(type)) return MatchesSpec(args.positional[0]);
  if (_range.isExactlyType(type)) {
    return RangeSpec(min: args.named['min']!, max: args.named['max']!);
  }
  if (_validate.isExactlyType(type)) return ValidateSpec(args.positional[0]);
  return null;
}

String _pureValueFor(DartType type, String typeName, GetterElement getter) {
  if (type.nullabilitySuffix == NullabilitySuffix.question) return 'null';
  final pureValue = _pureValues[typeName];
  if (pureValue == null) {
    throw InvalidGenerationSourceError(
      'Unsupported field type `$typeName`. '
      'Use String, int, double, num, bool or a nullable version of them.',
      element: getter,
    );
  }
  return pureValue;
}

void _rejectDuplicateMembers(
  GetterElement getter,
  List<ValidatorSpec> validators,
) {
  final seen = <String>{};
  for (final validator in validators) {
    if (!seen.add(validator.errorMember)) {
      throw InvalidGenerationSourceError(
        'Two validators on `${getter.name}` both produce '
        '`${validator.errorMember}`.',
        element: getter,
      );
    }
  }
}
