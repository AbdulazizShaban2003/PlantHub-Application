class FailureAuth {
  final String message;
  FailureAuth(this.message);
}

class ServerFailureAuth extends FailureAuth {
  ServerFailureAuth(super.message);
}

class CacheFailure extends FailureAuth {
  CacheFailure(super.message);
}

class FirebaseAuthFailure extends FailureAuth {
  FirebaseAuthFailure(super.message);
}