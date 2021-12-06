class Validator {
  static bool isEmpty({required String? value, required Function callback}) {
    if (value?.isEmpty ?? true) {
      callback();
      return true;
    }
    return false;
  }

  static bool isNull({var value, required Function callback}) {
    if (value == null) {
      callback();
      return true;
    }
    return false;
  }
}
