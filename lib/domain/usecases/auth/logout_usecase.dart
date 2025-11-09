import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';

/// Logout UseCase
///
/// Logs out the current user and clears all stored data.
@injectable
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  /// Execute logout
  ///
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> call() async {
    return await _authRepository.logout();
  }
}
