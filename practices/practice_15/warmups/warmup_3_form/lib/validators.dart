String? validateName(String? value) {
  if ((value ?? '').trim().length < 2) {
    return 'Name must have at least 2 characters';
  }
  return null;
}

String? validateEmail(String? value) {
  final email = (value ?? '').trim();
  final at = email.indexOf('@');
  final dot = email.indexOf('.', at + 1);

  if (at < 1 || dot <= at + 1 || dot == email.length - 1) {
    return 'Email looks wrong';
  }
  return null;
}
