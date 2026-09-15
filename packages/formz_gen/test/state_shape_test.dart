import 'package:test/test.dart';

import 'golden_helpers.dart';

void main() {
  group('generated state', () {
    test('hashes a single field with Object.hashAll', () async {
      final out = await generateSource(formSource('  String get note;'));
      expect(out, contains('int get hashCode => Object.hashAll([note]);'));
      expect(out, contains('other is FormState && other.note == note;'));
    });

    test('hashes more than twenty fields', () async {
      final body = List.generate(21, (i) => '  String get f$i;').join('\n');
      final out = await generateSource(formSource(body));
      expect(out, contains('Object.hashAll(['));
      expect(out, contains('f20,'));
    });

    test('copyWith and inputs cover every field in order', () async {
      final out = await generateSource(
        formSource('  String get first;\n  int get second;'),
      );
      expect(
        out,
        contains('FormState copyWith({First? first, Second? second})'),
      );
      expect(out, contains('first: first ?? this.first'));
      expect(out, contains('second: second ?? this.second'));
      expect(out, contains('get inputs => [first, second];'));
    });

    test('equality compares every field', () async {
      final out = await generateSource(
        formSource('  String get first;\n  int get second;'),
      );
      expect(
        out,
        contains(
          'other is FormState && other.first == first && '
          'other.second == second;',
        ),
      );
    });

    test('inherits getters from a superclass and mixins', () async {
      final out = await generateSource('''
import 'package:formz/formz.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';

part 'form.g.dart';

abstract class Base {
  @NotEmpty()
  String get name;
}

mixin Extra {
  int get count;
}

@FormzForm()
abstract class Form extends Base with Extra {
  String get note;
}
''');
      expect(out, contains('get inputs => [name, count, note];'));
      expect(out, contains('enum NameError { empty }'));
    });
  });
}
