import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formz_gen/builder.dart';

const examplePackage = 'formz_gen_example';

Future<String> generateFor(String fileName) async {
  final source = File('example/lib/$fileName.dart').readAsStringSync();
  return generateSource(source, fileName: fileName);
}

Future<String> generateSource(
  String source, {
  String fileName = 'form',
}) async {
  final build = await buildSource(source, fileName: fileName);
  return build.output;
}

Future<BuildOutcome> buildSource(
  String source, {
  String fileName = 'form',
}) async {
  final inputId = AssetId(examplePackage, 'lib/$fileName.dart');
  final outputId = AssetId(examplePackage, 'lib/$fileName.g.dart');
  final readerWriter = TestReaderWriter(rootPackage: examplePackage);
  await readerWriter.testing.loadIsolateSources();
  final logs = <String>[];
  final result = await testBuilder(
    formzBuilder(BuilderOptions.empty),
    {inputId.toString(): source},
    rootPackage: examplePackage,
    readerWriter: readerWriter,
    flattenOutput: true,
    onLog: (record) => logs.add(record.message),
  );
  final testing = result.readerWriter.testing;
  return BuildOutcome(
    output: testing.exists(outputId) ? testing.readString(outputId) : '',
    logs: logs,
  );
}

class BuildOutcome {
  const BuildOutcome({required this.output, required this.logs});

  final String output;
  final List<String> logs;
}

String expectedFor(String fileName) =>
    File('example/lib/$fileName.g.dart').readAsStringSync();

String formSource(String body, {bool events = false}) =>
    '''
import 'package:formz/formz.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';

part 'form.g.dart';

const pattern = r'^\\d+\$';

bool isEven(int value) => value.isEven;

class Rules {
  static bool noSpaces(String value) => !value.contains(' ');
}

@FormzForm(events: $events)
abstract class Form {
$body
}
''';
