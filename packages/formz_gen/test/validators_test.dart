import 'package:test/test.dart';

import 'golden_helpers.dart';

void main() {
  group('generated validator bodies', () {
    test('NotEmpty', () async {
      final out = await generateSource(
        formSource('  @NotEmpty()\n  String get name;'),
      );
      expect(out, contains('enum NameError { empty }'));
      expect(out, contains('if (value.isEmpty) return NameError.empty;'));
    });

    test('MinLength keeps the argument source', () async {
      final out = await generateSource(
        formSource('  @MinLength(3)\n  String get name;'),
      );
      expect(out, contains('enum NameError { tooShort }'));
      expect(out, contains('if (value.length < 3) return NameError.tooShort;'));
    });

    test('MaxLength', () async {
      final out = await generateSource(
        formSource('  @MaxLength(10)\n  String get name;'),
      );
      expect(out, contains('enum NameError { tooLong }'));
      expect(out, contains('if (value.length > 10) return NameError.tooLong;'));
    });

    test('Matches references the pattern by name', () async {
      final out = await generateSource(
        formSource('  @Matches(pattern)\n  String get name;'),
      );
      expect(out, contains('enum NameError { invalid }'));
      expect(
        out,
        contains(
          'if (!RegExp(pattern).hasMatch(value)) return NameError.invalid;',
        ),
      );
    });

    test('Matches accepts an inline literal', () async {
      final out = await generateSource(
        formSource("  @Matches(r'^a+\$')\n  String get name;"),
      );
      expect(out, contains(r"RegExp(r'^a+$')"));
    });

    test('Range on int', () async {
      final out = await generateSource(
        formSource('  @Range(min: 1, max: 5)\n  int get count;'),
      );
      expect(out, contains('class Count extends FormzInput<int, CountError>'));
      expect(out, contains('const Count.pure() : super.pure(0);'));
      expect(
        out,
        contains('if (value < 1 || value > 5) return CountError.outOfRange;'),
      );
    });

    test('Range on double uses a double default', () async {
      final out = await generateSource(
        formSource('  @Range(min: 0.5, max: 1.5)\n  double get ratio;'),
      );
      expect(out, contains('const Ratio.pure() : super.pure(0.0);'));
      expect(out, contains('const Ratio.dirty([super.value = 0.0])'));
    });

    test('Validate with a top-level function', () async {
      final out = await generateSource(
        formSource('  @Validate(isEven)\n  int get count;'),
      );
      expect(out, contains('enum CountError { isEven }'));
      expect(out, contains('if (!isEven(value)) return CountError.isEven;'));
    });

    test('Validate with a static field names the member after it', () async {
      final out = await generateSource(
        formSource('  @Validate(Rules.noSpaces)\n  String get name;'),
      );
      expect(out, contains('enum NameError { noSpaces }'));
      expect(
        out,
        contains('if (!Rules.noSpaces(value)) return NameError.noSpaces;'),
      );
    });

    test('validators run in declaration order', () async {
      final out = await generateSource(
        formSource(
          '  @MaxLength(10)\n'
          '  @NotEmpty()\n'
          '  @MinLength(2)\n'
          '  String get name;',
        ),
      );
      expect(out, contains('enum NameError { tooLong, empty, tooShort }'));
      final body = out.substring(out.indexOf('validator(String value)'));
      expect(
        body.indexOf('tooLong'),
        lessThan(body.indexOf('empty')),
      );
      expect(body.indexOf('empty'), lessThan(body.indexOf('tooShort')));
    });

    test('a field without validators uses Never as its error type', () async {
      final out = await generateSource(formSource('  String get note;'));
      expect(out, contains('class Note extends FormzInput<String, Never>'));
      expect(out, isNot(contains('enum NoteError')));
      expect(out, contains('Never? validator(String value)'));
    });

    test('nullable fields default to null', () async {
      final out = await generateSource(formSource('  String? get nickname;'));
      expect(out, contains('const Nickname.pure() : super.pure(null);'));
      expect(
        out,
        contains('const Nickname.dirty([super.value]) : super.dirty();'),
      );
    });

    test('bool fields default to false', () async {
      final out = await generateSource(formSource('  bool get agreed;'));
      expect(out, contains('const Agreed.pure() : super.pure(false);'));
    });
  });

  group('cross-field validation', () {
    const body = '''
  @NotEmpty()
  String get password;

  @NotEmpty()
  @SameAs(#password)
  String get confirm;
''';

    test('field-level errors win over the cross-field check', () async {
      final out = await generateSource(formSource(body));
      expect(out, contains('enum ConfirmError { empty, mismatch }'));
      expect(out, contains('final error = confirm.error;'));
      expect(out, contains('if (error != null) return error;'));
      expect(out, contains('if (confirm.value != password.value) {'));
      expect(out, contains('return ConfirmError.mismatch;'));
    });

    test('isValid folds the cross-field check into FormzMixin', () async {
      final out = await generateSource(formSource(body));
      expect(
        out,
        contains(
          'bool get isValid => Formz.validate(inputs) && confirmError == null;',
        ),
      );
      expect(
        out,
        contains(
          'ConfirmError? get confirmDisplayError => '
          'confirm.isPure ? null : confirmError;',
        ),
      );
    });

    test('forms without cross-field checks do not override isValid', () async {
      final out = await generateSource(formSource('  String get note;'));
      expect(out, isNot(contains('bool get isValid')));
    });
  });

  group('events', () {
    test('are omitted by default', () async {
      final out = await generateSource(formSource('  String get note;'));
      expect(out, isNot(contains('FormEvent')));
      expect(out, isNot(contains('apply(')));
    });

    test('emit a sealed hierarchy and an apply reducer', () async {
      final out = await generateSource(
        formSource('  String get note;\n  int get count;', events: true),
      );
      expect(out, contains('sealed class FormEvent {'));
      expect(out, contains('final class FormNoteChanged extends FormEvent {'));
      expect(out, contains('final class FormCountChanged extends FormEvent {'));
      expect(out, contains('final int value;'));
      expect(out, contains('FormState apply(FormEvent event) {'));
      expect(
        out,
        contains(
          'FormNoteChanged(:final value) => copyWith(note: Note.dirty(value)),',
        ),
      );
    });
  });
}
