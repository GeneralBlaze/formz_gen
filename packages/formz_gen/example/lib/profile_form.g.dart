// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint

part of 'profile_form.dart';

// **************************************************************************
// FormzGenerator
// **************************************************************************

enum DisplayNameError { empty, tooLong }

class DisplayName extends FormzInput<String, DisplayNameError> {
  const DisplayName.pure() : super.pure('');

  const DisplayName.dirty([super.value = '']) : super.dirty();

  @override
  DisplayNameError? validator(String value) {
    if (value.isEmpty) return DisplayNameError.empty;
    if (value.length > 40) return DisplayNameError.tooLong;
    return null;
  }
}

enum HandleError { empty, invalid, isNotReserved }

class Handle extends FormzInput<String, HandleError> {
  const Handle.pure() : super.pure('');

  const Handle.dirty([super.value = '']) : super.dirty();

  @override
  HandleError? validator(String value) {
    if (value.isEmpty) return HandleError.empty;
    if (!RegExp(handlePattern).hasMatch(value)) return HandleError.invalid;
    if (!isNotReserved(value)) return HandleError.isNotReserved;
    return null;
  }
}

enum AgeError { outOfRange }

class Age extends FormzInput<int, AgeError> {
  const Age.pure() : super.pure(0);

  const Age.dirty([super.value = 0]) : super.dirty();

  @override
  AgeError? validator(int value) {
    if (value < 13 || value > 120) return AgeError.outOfRange;
    return null;
  }
}

enum BioError { tooLong }

class Bio extends FormzInput<String, BioError> {
  const Bio.pure() : super.pure('');

  const Bio.dirty([super.value = '']) : super.dirty();

  @override
  BioError? validator(String value) {
    if (value.length > 160) return BioError.tooLong;
    return null;
  }
}

class ProfileFormState with FormzMixin {
  const ProfileFormState({
    this.displayName = const DisplayName.pure(),
    this.handle = const Handle.pure(),
    this.age = const Age.pure(),
    this.bio = const Bio.pure(),
  });

  final DisplayName displayName;

  final Handle handle;

  final Age age;

  final Bio bio;

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    displayName,
    handle,
    age,
    bio,
  ];

  ProfileFormState copyWith({
    DisplayName? displayName,
    Handle? handle,
    Age? age,
    Bio? bio,
  }) {
    return ProfileFormState(
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      age: age ?? this.age,
      bio: bio ?? this.bio,
    );
  }

  ProfileFormState apply(ProfileFormEvent event) {
    return switch (event) {
      ProfileFormDisplayNameChanged(:final value) => copyWith(
        displayName: DisplayName.dirty(value),
      ),
      ProfileFormHandleChanged(:final value) => copyWith(
        handle: Handle.dirty(value),
      ),
      ProfileFormAgeChanged(:final value) => copyWith(age: Age.dirty(value)),
      ProfileFormBioChanged(:final value) => copyWith(bio: Bio.dirty(value)),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileFormState &&
          other.displayName == displayName &&
          other.handle == handle &&
          other.age == age &&
          other.bio == bio;

  @override
  int get hashCode => Object.hashAll([displayName, handle, age, bio]);
}

sealed class ProfileFormEvent {
  const ProfileFormEvent();
}

final class ProfileFormDisplayNameChanged extends ProfileFormEvent {
  const ProfileFormDisplayNameChanged(this.value);

  final String value;
}

final class ProfileFormHandleChanged extends ProfileFormEvent {
  const ProfileFormHandleChanged(this.value);

  final String value;
}

final class ProfileFormAgeChanged extends ProfileFormEvent {
  const ProfileFormAgeChanged(this.value);

  final int value;
}

final class ProfileFormBioChanged extends ProfileFormEvent {
  const ProfileFormBioChanged(this.value);

  final String value;
}
