import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

/// Get User UseCase
///
/// Retrieves user details from the backend.
@injectable
class GetUserUseCase {
  final UserRepository _userRepository;

  GetUserUseCase(this._userRepository);

  /// Execute get user
  ///
  /// [userId] User ID (int)
  ///
  /// Returns Either<Failure, UserModel>
  Future<Either<Failure, UserModel>> call({
    required int userId,
  }) async {
    return await _userRepository.getUser(userId);
  }
}
