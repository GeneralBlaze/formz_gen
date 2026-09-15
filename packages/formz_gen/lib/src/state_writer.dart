import 'package:formz_gen/src/form_spec.dart';
import 'package:formz_gen/src/naming.dart';

String writeState(FormSpec form) {
  final state = form.stateName;
  final fields = form.fields;
  final buffer = StringBuffer()
    ..writeln('class $state with FormzMixin {')
    ..writeln('  const $state({');
  for (final f in fields) {
    buffer.writeln('    this.${f.name} = const ${f.inputName}.pure(),');
  }
  buffer.writeln('  });');
  for (final f in fields) {
    buffer
      ..writeln()
      ..writeln('  final ${f.inputName} ${f.name};');
  }
  for (final f in fields.where((f) => f.sameAs.isNotEmpty)) {
    buffer
      ..writeln()
      ..write(_crossFieldGetters(f));
  }
  if (form.hasCrossFieldChecks) {
    buffer
      ..writeln()
      ..writeln('  @override')
      ..writeln('  bool get isValid => ${_isValidBody(form)};');
  }
  buffer
    ..writeln()
    ..writeln('  @override')
    ..writeln(
      '  List<FormzInput<dynamic, dynamic>> get inputs => '
      '[${fields.map((f) => f.name).join(', ')}];',
    )
    ..writeln()
    ..write(_copyWith(form));
  if (form.events) {
    buffer
      ..writeln()
      ..write(_apply(form));
  }
  buffer
    ..writeln()
    ..write(_equality(form))
    ..writeln('}');
  return buffer.toString();
}

String _crossFieldGetters(FieldSpec f) {
  final buffer = StringBuffer()
    ..writeln('  ${f.errorEnum}? get ${f.name}Error {')
    ..writeln('    final error = ${f.name}.error;')
    ..writeln('    if (error != null) return error;');
  for (final target in f.sameAs) {
    buffer
      ..writeln('    if (${f.name}.value != $target.value) {')
      ..writeln('      return ${f.errorEnum}.mismatch;')
      ..writeln('    }');
  }
  buffer
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln()
    ..writeln(
      '  ${f.errorEnum}? get ${f.name}DisplayError => '
      '${f.name}.isPure ? null : ${f.name}Error;',
    );
  return buffer.toString();
}

String _isValidBody(FormSpec form) {
  final checks = form.fields
      .where((f) => f.sameAs.isNotEmpty)
      .map((f) => '${f.name}Error == null');
  return ['Formz.validate(inputs)', ...checks].join(' && ');
}

String _copyWith(FormSpec form) {
  final buffer = StringBuffer()..writeln('  ${form.stateName} copyWith({');
  for (final f in form.fields) {
    buffer.writeln('    ${f.inputName}? ${f.name},');
  }
  buffer
    ..writeln('  }) {')
    ..writeln('    return ${form.stateName}(');
  for (final f in form.fields) {
    buffer.writeln('      ${f.name}: ${f.name} ?? this.${f.name},');
  }
  buffer
    ..writeln('    );')
    ..writeln('  }');
  return buffer.toString();
}

String _apply(FormSpec form) {
  final buffer = StringBuffer()
    ..writeln('  ${form.stateName} apply(${form.eventName} event) {')
    ..writeln('    return switch (event) {');
  for (final f in form.fields) {
    final event = '${form.name}${pascalCase(f.name)}Changed';
    buffer.writeln(
      '      $event(:final value) => '
      'copyWith(${f.name}: ${f.inputName}.dirty(value)),',
    );
  }
  buffer
    ..writeln('    };')
    ..writeln('  }');
  return buffer.toString();
}

String _equality(FormSpec form) {
  final names = form.fields.map((f) => f.name);
  final comparisons = names.map((n) => 'other.$n == $n').join(' && ');
  return '''
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${form.stateName} && $comparisons;

  @override
  int get hashCode => Object.hash(${names.join(', ')});
''';
}
