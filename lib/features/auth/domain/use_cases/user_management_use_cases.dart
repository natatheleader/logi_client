import 'package:dartz/dartz.dart'; // Provides the Either class
import '../../../../core/error/failures.dart'; // Provides the Failure class
import '../../../../core/use_cases/use_case.dart'; // Provides UseCase and NoParams
import '../entities/user.dart'; // Provides the User class
import '../repositories/auth_repository.dart'; // Provides the AuthRepository class

class GetCurrentUser implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}

class UpdateProfileParams {
  final String? name;
  final String? email;
  final String? phone;

  UpdateProfileParams({
    this.name,
    this.email,
    this.phone,
  });
}

class UpdateProfile implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      phone: params.phone,
    );
  }
}

class ConvertGuestToRegistered implements UseCase<User, AuthProvider> {
  final AuthRepository repository;

  ConvertGuestToRegistered(this.repository);

  @override
  Future<Either<Failure, User>> call(AuthProvider provider) async {
    return await repository.convertGuestToRegistered(provider);
  }
}