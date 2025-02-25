enum DbCollections {
  users('users'),
  rooms('rooms'),
  schedulers('schedulers');

  final String key;
  const DbCollections(this.key);
}
