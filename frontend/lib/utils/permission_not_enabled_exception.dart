class PermissionNotEnabledException implements Exception {
  final String message;

  //square brakets signifies optional params. If you dont specify a string when catching, this one will be used instead.
  //constructor
  PermissionNotEnabledException([this.message = 'Location permission is not enabled']);

  @override
  String toString() => 'PermissionNotEnabledException: $message';
}
