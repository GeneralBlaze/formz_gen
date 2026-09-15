import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:formz_gen/src/event_writer.dart';
import 'package:formz_gen/src/form_reader.dart';
import 'package:formz_gen/src/input_writer.dart';
import 'package:formz_gen/src/state_writer.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';
import 'package:source_gen/source_gen.dart';

class FormzGenerator extends GeneratorForAnnotation<FormzForm> {
  const FormzGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final form = readForm(element, annotation);
    return [
      ...form.fields.map(writeInput),
      writeState(form),
      if (form.events) writeEvents(form),
    ].join('\n');
  }
}
