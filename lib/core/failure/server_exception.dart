class ServerExceptions implements Exception {
  final String message;

  ServerExceptions(this.message);

  @override
  String toString() => 'ServerExceptions: $message';
}