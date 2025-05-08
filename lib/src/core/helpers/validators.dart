

class Validators {
  static String? emptyValidator(value) {
    if (value.toString().isEmpty) {
      return "The field is required";
    }
    return null;
  }

}