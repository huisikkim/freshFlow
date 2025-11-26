class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server error occurred'});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'Network error occurred'});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = 'Unauthorized'});
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({this.message = 'Not found'});
}
