import 'package:dartz/dartz.dart'; // Provides the Either class
import '../../../../core/error/failures.dart'; // Provides the Failure class
import '../../../../core/use_cases/use_case.dart'; // Provides UseCase and NoParams
import '../entities/user.dart'; // Provides the User class
import '../repositories/auth_repository.dart'; // Provides the AuthRepository class

class ContinueAsGuest implements UseCase<User, NoParams> {
  final AuthRepository repository;

  ContinueAsGuest(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.continueAsGuest();
  }
}