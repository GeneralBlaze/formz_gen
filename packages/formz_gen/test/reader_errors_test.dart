import 'package:test/test.dart';

import 'golden_helpers.dart';

void main() {
  group('readForm rejects', () {
    test('a concrete class', () async {
      final build = await buildSource('''
import 'package:formz_gen_annotation/formz_gen_annotation.dart';

part 'form.g.dart';

@FormzForm()
class Form {}
''');
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('@FormzForm can only annotate an abstract class.'),
      );
    });

    test('an unknown @SameAs target', () async {
      final build = await buildSource(
        formSource('  @SameAs(#missing)\n  String get confirm;'),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('@SameAs(#missing) on `confirm` references an unknown field.'),
      );
    });

    test('an unsupported field type', () async {
      final build = await buildSource(formSource('  DateTime get when;'));
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('Unsupported field type `DateTime`.'),
      );
    });

    test('two validators that share an error member', () async {
      final build = await buildSource(
        formSource("  @Matches(pattern)\n  @Matches(r'x')\n  String get name;"),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('Two validators on `name` both produce `invalid`.'),
      );
    });
  });

  group('readForm ignores', () {
    test('static getters and unrelated annotations', () async {
      final out = await generateSource(
        formSource('''
  static String get label => 'x';

  @Deprecated('old')
  @NotEmpty()
  String get name;
'''),
      );
      expect(out, isNot(contains('Label')));
      expect(out, contains('enum NameError { empty }'));
    });
  });
}
