class PermissionNotEnabledException implements Exception {
  final String message;

  PermissionNotEnabledException([this.message = 'Location permission is not enabled']);

  @override
  String toString() => 'PermissionNotEnabledException: $message';
}
