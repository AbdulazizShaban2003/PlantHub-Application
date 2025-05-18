class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class FirebaseAuthException implements Exception {
  final String message;
  FirebaseAuthException(this.message);
}