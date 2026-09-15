import 'package:formz_gen_example/profile_form.dart';
import 'package:test/test.dart';

void main() {
  group('ProfileFormState', () {
    test('applies field-changed events as dirty inputs', () {
      final state = const ProfileFormState()
          .apply(const ProfileFormDisplayNameChanged('Ada'))
          .apply(const ProfileFormHandleChanged('ada_l'))
          .apply(const ProfileFormAgeChanged(36))
          .apply(const ProfileFormBioChanged('Analytical engines.'));
      expect(state.isDirty, isTrue);
      expect(state.isValid, isTrue);
    });

    test('runs the custom validator after the built-ins', () {
      expect(const Handle.dirty('admin').error, HandleError.isNotReserved);
      expect(const Handle.dirty('Admin').error, HandleError.invalid);
      expect(const Handle.dirty().error, HandleError.empty);
    });

    test('checks numeric ranges', () {
      expect(const Age.dirty(12).error, AgeError.outOfRange);
      expect(const Age.dirty(121).error, AgeError.outOfRange);
      expect(const Age.dirty(13).error, isNull);
    });

    test('checks maximum lengths', () {
      expect(Bio.dirty('x' * 161).error, BioError.tooLong);
      expect(Bio.dirty('x' * 160).error, isNull);
    });
  });
}
