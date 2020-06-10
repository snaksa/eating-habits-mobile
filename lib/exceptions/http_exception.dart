class HttpException implements Exception {
  final String message;
  final int status;

  const HttpException(this.message, [this.status]);

  @override
  String toString() {
    return message;
  }
}