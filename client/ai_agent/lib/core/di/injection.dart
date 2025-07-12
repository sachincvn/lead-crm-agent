import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/lead_api_service.dart';
import '../../data/services/agent_api_service.dart';
import '../../data/services/chat_storage_service.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../presentation/bloc/lead_bloc.dart';
import '../../presentation/bloc/chat_bloc.dart';
import '../constants/api_constants.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = Duration(milliseconds: ApiConstants.connectTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: ApiConstants.receiveTimeout);
    dio.options.sendTimeout = Duration(milliseconds: ApiConstants.sendTimeout);

    // Add interceptors for logging if needed
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true, requestHeader: true, responseHeader: false));

    return dio;
  });

  // Storage Services - Initialize Hive first
  final chatStorageService = ChatStorageService();
  await chatStorageService.init(); // Wait for Hive initialization
  getIt.registerLazySingleton<ChatStorageService>(() => chatStorageService);

  // API Services
  getIt.registerLazySingleton<LeadApiService>(() => LeadApiService(getIt<Dio>()));
  getIt.registerLazySingleton<AgentApiService>(() => AgentApiService(getIt<Dio>()));

  // Repositories
  getIt.registerLazySingleton<LeadRepository>(() => LeadRepositoryImpl(getIt<LeadApiService>()));
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository(getIt<AgentApiService>(), getIt<ChatStorageService>()));

  // BLoCs
  getIt.registerFactory<LeadBloc>(() => LeadBloc(getIt<LeadRepository>()));
  getIt.registerFactory<ChatBloc>(() => ChatBloc(getIt<ChatRepository>()));
}
