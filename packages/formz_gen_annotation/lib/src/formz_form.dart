import 'package:meta/meta.dart';

@immutable
class FormzForm {
  const FormzForm({this.events = false});

  final bool events;
}
