import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  Future<UserModel> call() async {
    return await repository.signInWithGoogle();
  }
}