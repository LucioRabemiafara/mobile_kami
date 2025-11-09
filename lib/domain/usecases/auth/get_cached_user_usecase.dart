import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

/// Get Cached User UseCase
///
/// Retrieves the cached user from secure storage.
/// Returns null if no user is cached.
@injectable
class GetCachedUserUseCase {
  final AuthRepository _authRepository;

  GetCachedUserUseCase(this._authRepository);

  /// Execute get cached user
  ///
  /// Returns Either<Failure, UserModel?>
  Future<Either<Failure, UserModel?>> call() async {
    return await _authRepository.getCachedUser();
  }
}
