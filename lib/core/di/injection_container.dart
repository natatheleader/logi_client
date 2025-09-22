import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../services/storage_service.dart';
import '../network/network_info.dart';
import '../network/dio_client.dart';
import '../constants/app_constants.dart';

import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';

import '../../features/auth/data/data_sources/firebase_auth_data_source.dart';
import '../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/phone_auth_use_cases.dart';
import '../../features/auth/domain/use_cases/google_auth_use_cases.dart';
import '../../features/auth/domain/use_cases/guest_auth_use_cases.dart';
import '../../features/auth/domain/use_cases/user_management_use_cases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/phone_auth_cubit.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register external dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Firebase
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn(scopes: ['email']));

  // Register network checker
  getIt.registerSingleton<InternetConnection>(
    InternetConnection(),
  );

  // Register network info
  getIt.registerSingleton<NetworkInfo>(
    NetworkInfoImpl(getIt<InternetConnection>()),
  );

  // Register services first
  getIt.registerSingleton<StorageService>(
    StorageService(sharedPreferences),
  );

  // Create Dio AFTER StorageService is registered
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
    receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
  ));

  // Add interceptors
  dio.interceptors.add(AuthInterceptor(getIt<StorageService>()));

  // Register Dio
  getIt.registerSingleton<Dio>(dio);

  // Register data sources
  getIt.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Register repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      firebaseDataSource: getIt<FirebaseAuthDataSource>(),
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      storageService: getIt<StorageService>(),
    ),
  );

  // Register use cases
  // Phone auth use cases
  getIt.registerFactory<InitiatePhoneVerification>(
    () => InitiatePhoneVerification(getIt<AuthRepository>()),
  );
  getIt.registerFactory<VerifyPhoneCode>(
    () => VerifyPhoneCode(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ResendPhoneCode>(
    () => ResendPhoneCode(getIt<AuthRepository>()),
  );

  // Google auth use cases
  getIt.registerFactory<SignInWithGoogle>(
    () => SignInWithGoogle(getIt<AuthRepository>()),
  );

  // Guest auth use cases
  getIt.registerFactory<ContinueAsGuest>(
    () => ContinueAsGuest(getIt<AuthRepository>()),
  );

  // User management use cases
  getIt.registerFactory<GetCurrentUser>(
    () => GetCurrentUser(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignOut>(
    () => SignOut(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UpdateProfile>(
    () => UpdateProfile(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ConvertGuestToRegistered>(
    () => ConvertGuestToRegistered(getIt<AuthRepository>()),
  );
  
  // Register cubits/blocs
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit(getIt<StorageService>()));

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getCurrentUser: getIt<GetCurrentUser>(),
      signOut: getIt<SignOut>(),
      signInWithGoogle: getIt<SignInWithGoogle>(),
      continueAsGuest: getIt<ContinueAsGuest>(),
      updateProfile: getIt<UpdateProfile>(),
    ),
  );

  getIt.registerFactory<PhoneAuthCubit>(
    () => PhoneAuthCubit(
      initiatePhoneVerification: getIt<InitiatePhoneVerification>(),
      verifyPhoneCode: getIt<VerifyPhoneCode>(),
      resendPhoneCode: getIt<ResendPhoneCode>(),
    ),
  );
  
  // Future: Register repositories, data sources, use cases, etc.
  // This will be expanded as we add more features
}