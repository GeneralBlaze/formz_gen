import 'package:test/test.dart';

import 'golden_helpers.dart';

void main() {
  reservedNames();
  roundTwo();
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

void reservedNames() {
  group('readForm rejects reserved names', () {
    test('a field named error', () async {
      final build = await buildSource(formSource('  String get error;'));
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('`error` is reserved'));
    });

    test('a field named other', () async {
      final build = await buildSource(formSource('  String get other;'));
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('`other` is reserved'));
    });

    test('a field named inputs', () async {
      final build = await buildSource(formSource('  String get inputs;'));
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('`inputs` is reserved'));
    });

    test('a Validate function named mismatch next to SameAs', () async {
      final build = await buildSource(
        formSource(
          '  String get a;\n'
          '  @SameAs(#a)\n  @Validate(mismatch)\n  String get b;',
        ),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('Two validators on `b` both produce `mismatch`.'),
      );
    });

    test('a Validate function named values', () async {
      final build = await buildSource(
        formSource('  @Validate(values)\n  String get a;'),
      );
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('`values` cannot be an enum member'));
    });
  });

  group('readForm checks validator types', () {
    test('NotEmpty on a non-String field', () async {
      final build = await buildSource(
        formSource('  @NotEmpty()\n  int get count;'),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('@NotEmpty requires a non-nullable String field'),
      );
    });

    test('Range on a String field', () async {
      final build = await buildSource(
        formSource('  @Range(min: 1, max: 2)\n  String get name;'),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('@Range requires a non-nullable num field'),
      );
    });

    test('Range with fractional bounds on an int field', () async {
      final build = await buildSource(
        formSource('  @Range(min: 0.5, max: 10)\n  int get count;'),
      );
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('@Range bounds on an int field'));
    });

    test('Validate with a function that does not return bool', () async {
      final build = await buildSource(
        formSource('  @Validate(shout)\n  String get name;'),
      );
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('must return bool'));
    });

    test(
      'Validate with a function whose parameter rejects the field',
      () async {
        final build = await buildSource(
          formSource('  @Validate(isEven)\n  String get name;'),
        );
        expect(build.output, isEmpty);
        expect(build.logs.join(), contains('must accept String'));
      },
    );
  });
}

void roundTwo() {
  group('readForm rejects built-in validators on nullable fields', () {
    test('NotEmpty on String?', () async {
      final build = await buildSource(
        formSource('  @NotEmpty()\n  String? get name;'),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('@NotEmpty requires a non-nullable String field'),
      );
    });

    test('Range on int?', () async {
      final build = await buildSource(
        formSource('  @Range(min: 1, max: 2)\n  int? get count;'),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('@Range requires a non-nullable num field'),
      );
    });
  });

  group('readForm rejects generated-name collisions', () {
    test('a field named identical', () async {
      final build = await buildSource(formSource('  String get identical;'));
      expect(build.output, isEmpty);
      expect(build.logs.join(), contains('`identical` is reserved'));
    });

    test("a field named like another field's error getter", () async {
      final build = await buildSource(
        formSource(
          '  String get a;\n'
          '  @SameAs(#a)\n  String get b;\n'
          '  String get bError;',
        ),
      );
      expect(build.output, isEmpty);
      expect(
        build.logs.join(),
        contains('`bError` collides with a generated member'),
      );
    });
  });
}
