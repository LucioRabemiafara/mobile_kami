import 'package:injectable/injectable.dart';
import '../../../data/repositories/auth_repository.dart';

/// Is Authenticated UseCase
///
/// Checks if a user is currently authenticated (has a valid token).
@injectable
class IsAuthenticatedUseCase {
  final AuthRepository _authRepository;

  IsAuthenticatedUseCase(this._authRepository);

  /// Execute authentication check
  ///
  /// Returns true if user is authenticated, false otherwise
  Future<bool> call() async {
    return await _authRepository.isAuthenticated();
  }
}
