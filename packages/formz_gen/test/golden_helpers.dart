import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formz_gen/builder.dart';

const examplePackage = 'formz_gen_example';

Future<String> generateFor(String fileName) async {
  final source = File('example/lib/$fileName.dart').readAsStringSync();
  return generateSource(source, fileName: fileName);
}

Future<String> generateSource(String source, {String? fileName}) async {
  final build = await buildSource(source, fileName: fileName);
  return build.output;
}

int _builds = 0;
Future<TestReaderWriter>? _sharedReaderWriter;

Future<TestReaderWriter> _loadedReaderWriter() =>
    _sharedReaderWriter ??= () async {
      final readerWriter = TestReaderWriter(rootPackage: examplePackage);
      await readerWriter.testing.loadIsolateSources();
      return readerWriter;
    }();

Future<BuildOutcome> buildSource(String source, {String? fileName}) async {
  final name = fileName ?? 'form_${_builds++}';
  final inputId = AssetId(examplePackage, 'lib/$name.dart');
  final outputId = AssetId(examplePackage, 'lib/$name.g.dart');
  final logs = <String>[];
  final result = await testBuilder(
    formzBuilder(BuilderOptions.empty),
    {inputId.toString(): source.replaceAll("'form.g.dart'", "'$name.g.dart'")},
    rootPackage: examplePackage,
    readerWriter: await _loadedReaderWriter(),
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

bool mismatch(String value) => true;

bool values(String value) => true;

String shout(String value) => value.toUpperCase();

class Rules {
  static bool noSpaces(String value) => !value.contains(' ');
}

@FormzForm(events: $events)
abstract class Form {
$body
}
''';
