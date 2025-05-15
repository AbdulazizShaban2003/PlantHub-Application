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
}

