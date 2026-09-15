import 'package:formz_gen/src/naming.dart';
import 'package:formz_gen/src/validator_spec.dart';

class FormSpec {
  const FormSpec({
    required this.name,
    required this.events,
    required this.fields,
  });

  final String name;
  final bool events;
  final List<FieldSpec> fields;

  String get stateName => '${name}State';

  String get eventName => '${name}Event';

  bool get hasCrossFieldChecks => fields.any((f) => f.sameAs.isNotEmpty);
}

class FieldSpec {
  const FieldSpec({
    required this.name,
    required this.type,
    required this.pureValue,
    required this.validators,
    required this.sameAs,
  });

  final String name;
  final String type;
  final String pureValue;
  final List<ValidatorSpec> validators;
  final List<String> sameAs;

  String get inputName => pascalCase(name);

  String get errorEnum => '${inputName}Error';

  bool get hasErrors => validators.isNotEmpty || sameAs.isNotEmpty;

  String get errorType => hasErrors ? errorEnum : 'Never';

  List<String> get errorMembers => [
    ...validators.map((v) => v.errorMember),
    if (sameAs.isNotEmpty) 'mismatch',
  ];
}
