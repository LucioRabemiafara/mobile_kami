import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

/// Login UseCase
///
/// Authenticates a user with email and password.
/// Returns the authenticated user on success.
@injectable
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  /// Execute login
  ///
  /// [email] User email
  /// [password] User password
  ///
  /// Returns Either<Failure, UserModel>
  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
  }) async {
    print('CALL LOGIN PLEASE');
    return await _authRepository.login(email, password);
  }
}
