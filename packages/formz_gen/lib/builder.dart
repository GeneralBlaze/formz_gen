import 'package:build/build.dart';
import 'package:formz_gen/src/formz_generator.dart';
import 'package:source_gen/source_gen.dart';

const _header = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
''';

Builder formzBuilder(BuilderOptions options) =>
    PartBuilder([const FormzGenerator()], '.g.dart', header: _header);
