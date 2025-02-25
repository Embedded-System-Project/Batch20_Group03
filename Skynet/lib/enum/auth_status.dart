enum AuthStatus {
  unverified('unverified'),
  active('active'),
  blocked('blocked'),
  invalid('invalid');

  final String key;
  const AuthStatus(this.key);
}
