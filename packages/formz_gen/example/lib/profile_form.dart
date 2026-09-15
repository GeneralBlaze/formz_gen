import 'package:formz/formz.dart';
import 'package:formz_gen_annotation/formz_gen_annotation.dart';

part 'profile_form.g.dart';

const handlePattern = r'^[a-z0-9_]+$';

bool isNotReserved(String value) => value != 'admin' && value != 'root';

@FormzForm(events: true)
abstract class ProfileForm {
  @NotEmpty()
  @MaxLength(40)
  String get displayName;

  @NotEmpty()
  @Matches(handlePattern)
  @Validate(isNotReserved)
  String get handle;

  @Range(min: 13, max: 120)
  int get age;

  @MaxLength(160)
  String get bio;
}
