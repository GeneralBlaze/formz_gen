import 'package:formz_gen/src/form_spec.dart';
import 'package:formz_gen/src/naming.dart';

String writeEvents(FormSpec form) {
  final base = form.eventName;
  final buffer = StringBuffer()
    ..writeln('sealed class $base {')
    ..writeln('  const $base();')
    ..writeln('}');
  for (final f in form.fields) {
    final event = '${form.name}${pascalCase(f.name)}Changed';
    buffer
      ..writeln()
      ..writeln('final class $event extends $base {')
      ..writeln('  const $event(this.value);')
      ..writeln()
      ..writeln('  final ${f.type} value;')
      ..writeln('}');
  }
  return buffer.toString();
}
