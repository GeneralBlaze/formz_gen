import 'package:test/test.dart';

import 'golden_helpers.dart';

void main() {
  test(
    'sign_up_form.g.dart is byte-identical to the hand-written spec',
    () async {
      final generated = await generateFor('sign_up_form');
      expect(generated, expectedFor('sign_up_form'));
    },
  );

  test(
    'profile_form.g.dart (events: true) is byte-identical to the spec',
    () async {
      final generated = await generateFor('profile_form');
      expect(generated, expectedFor('profile_form'));
    },
  );
}
