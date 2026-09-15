import 'package:formz_gen/src/form_spec.dart';

String writeInput(FieldSpec field) {
  final buffer = StringBuffer();
  if (field.hasErrors) {
    buffer
      ..writeln('enum ${field.errorEnum} { ${field.errorMembers.join(', ')} }')
      ..writeln();
  }
  final input = field.inputName;
  final errorType = field.errorType;
  buffer
    ..writeln('class $input extends FormzInput<${field.type}, $errorType> {')
    ..writeln('  const $input.pure() : super.pure(${field.pureValue});')
    ..writeln()
    ..writeln(_dirtyConstructor(field))
    ..writeln()
    ..writeln('  @override')
    ..writeln('  $errorType? validator(${field.type} value) {');
  for (final validator in field.validators) {
    buffer.writeln('    ${validator.check(field.errorEnum)}');
  }
  buffer
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('}');
  return buffer.toString();
}

String _dirtyConstructor(FieldSpec field) {
  final input = field.inputName;
  if (field.pureValue == 'null') {
    return '  const $input.dirty([super.value]) : super.dirty();';
  }
  return '  const $input.dirty([super.value = ${field.pureValue}]) '
      ': super.dirty();';
}
