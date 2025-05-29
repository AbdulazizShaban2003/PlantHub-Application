import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase({required this.repository});

  Future<UserModel> call({
    required String name,
    required String email,
    required String password,
  }) async {
    return await repository.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }
}