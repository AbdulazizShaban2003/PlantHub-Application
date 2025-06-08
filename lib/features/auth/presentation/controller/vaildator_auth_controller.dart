import '../../../../core/utils/app_strings.dart';

class ValidatorController {
  String? emailValid(String? value) {
    if (value == null || value.isEmpty) {
      return RegxStrings.emptyEmail;
    }
    final bool emailValid = RegExp(RegxStrings.emailPattern).hasMatch(value);
    if (!emailValid) {
      return RegxStrings.invalidEmail;
    }
    return null;
  }

  String? passwordValid(String? value) {
    if (value == null || value.isEmpty) {
      return RegxStrings.emptyPassword;
    }
    if (value.length < 7) {
      return RegxStrings.shortPassword;
    }
    final regex = RegExp(RegxStrings.passwordPattern);
    if (!regex.hasMatch(value)) {
      return RegxStrings.invalidPassword;
    }
    return null;
  }

  String? userNameValid(String? value) {
    if (value == null || value.isEmpty) {
      return RegxStrings.emptyName;
    }
    final bool nameValid = RegExp(RegxStrings.namePattern).hasMatch(value);
    if (!nameValid) {
      return RegxStrings.invalidName;
    }
    return null;
  }

  String? phoneValid(String? value, {String country = 'egypt'}) {
    if (value == null || value.isEmpty) {
      return RegxStrings.emptyPhone;
    }
    final cleanedNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

    final countryData = RegxStrings.phonePatterns[country.toLowerCase()] ?? {
      'regex': RegxStrings.defaultPhoneRegex,
      'message': RegxStrings.defaultPhoneMessage,
    };

    final regex = RegExp(countryData['regex']!);

    if (!regex.hasMatch(cleanedNumber)) {
      return countryData['message'];
    }

    return null;
  }
}
