class ValidatorController {
   String? emailValid(String? value) {
    final bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value!);
    if (value.isEmpty) {
      return 'Please Enter Email';
    } else if (!emailValid) {
      return "This Email is not Correct";
    }
    return null;
  }

   String? passwordValid(String? value) {
    RegExp regex =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value!.isEmpty) {
      return 'Please Enter password';
    } else if (!regex.hasMatch(value)) {
      return 'Enter valid password';
    } else if (value.length < 7) {
      return 'Password should be at least 7 characters';
    }
    return null;
  }

   String? userNameValid(String? value) {
    final bool nameValid =
    RegExp(r'^[a-zA-Z\s]+$').hasMatch(value ?? '');
    if (value!.isEmpty || value == null) {
      return 'Enter Your Name';
    } else if (!nameValid) {
      return "This Name is not valid";
    }
    return null;
  }
   String? phoneValid(String? value, {String country = 'egypt'}) {
     if (value == null || value.isEmpty) {
       return 'Please enter phone number';
     }

     // Remove any non-digit characters
     final cleanedNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

     final arabCountries = {
       'egypt': {
         'regex': r'^01[0125][0-9]{8}$',
         'message': 'Egyptian number must be 11 digits starting with 010, 011, 012, or 015'
       },
       'saudi': {
         'regex': r'^05[0-9]{8}$',
         'message': 'Saudi number must be 10 digits starting with 05'
       },
       'uae': {
         'regex': r'^(050|052|054|055|056|058)[0-9]{7}$',
         'message': 'UAE number must be 10 digits starting with 050, 052, 054, 055, 056, or 058'
       },
       'kuwait': {
         'regex': r'^[569][0-9]{7}$',
         'message': 'Kuwaiti number must be 8 digits starting with 5, 6, or 9'
       },
       'qatar': {
         'regex': r'^(3|5|6|7)[0-9]{7}$',
         'message': 'Qatari number must be 8 digits starting with 3, 5, 6, or 7'
       },
       'bahrain': {
         'regex': r'^(3|6|9)[0-9]{7}$',
         'message': 'Bahraini number must be 8 digits starting with 3, 6, or 9'
       },
       'oman': {
         'regex': r'^9[0-9]{8}$',
         'message': 'Omani number must be 9 digits starting with 9'
       },
       'jordan': {
         'regex': r'^07[789][0-9]{7}$',
         'message': 'Jordanian number must be 10 digits starting with 077, 078, or 079'
       },
       'lebanon': {
         'regex': r'^(03|70|71|76|78|79|81)[0-9]{6}$',
         'message': 'Lebanese number must be 8 digits starting with 03, 70, 71, 76, 78, 79, or 81'
       },
       'iraq': {
         'regex': r'^07[0-9]{9}$',
         'message': 'Iraqi number must be 11 digits starting with 07'
       },
       'morocco': {
         'regex': r'^(06|07)[0-9]{8}$',
         'message': 'Moroccan number must be 10 digits starting with 06 or 07'
       },
       'algeria': {
         'regex': r'^(05|06|07)[0-9]{8}$',
         'message': 'Algerian number must be 10 digits starting with 05, 06, or 07'
       },
       'tunisia': {
         'regex': r'^[2459][0-9]{7}$',
         'message': 'Tunisian number must be 8 digits starting with 2, 4, 5, or 9'
       },
       'palestine': {
         'regex': r'^05[0-9]{8}$',
         'message': 'Palestinian number must be 10 digits starting with 05'
       },
       'syria': {
         'regex': r'^09[0-9]{8}$',
         'message': 'Syrian number must be 10 digits starting with 09'
       },
       'yemen': {
         'regex': r'^7[0-9]{8}$',
         'message': 'Yemeni number must be 9 digits starting with 7'
       },
       'libya': {
         'regex': r'^9[0-9]{8}$',
         'message': 'Libyan number must be 9 digits starting with 9'
       },
       'sudan': {
         'regex': r'^9[0-9]{8}$',
         'message': 'Sudanese number must be 9 digits starting with 9'
       },
       'mauritania': {
         'regex': r'^[0-9]{8}$',
         'message': 'Mauritanian number must be 8 digits'
       },
       'djibouti': {
         'regex': r'^77[0-9]{6}$',
         'message': 'Djiboutian number must be 8 digits starting with 77'
       },
       'comoros': {
         'regex': r'^3[0-9]{6}$',
         'message': 'Comorian number must be 7 digits starting with 3'
       },
       'somalia': {
         'regex': r'^[0-9]{8}$',
         'message': 'Somali number must be 8 digits'
       },
     };

     final countryData = arabCountries[country.toLowerCase()] ?? {
       'regex': r'^[0-9]{8,15}$',
       'message': 'Invalid phone number format'
     };

     final regex = RegExp(countryData['regex'] as String);

     if (!regex.hasMatch(cleanedNumber)) {
       return countryData['message'] as String;
     }

     return null;
   }}

