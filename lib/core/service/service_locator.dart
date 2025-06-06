import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/booking/home/data/repos/home_repo_impl.dart';
import '../cache/cache_helper.dart';
import 'api_service.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  sl.registerLazySingleton<CacheHelper>(() => CacheHelper());
  sl.registerSingleton<ApiService>(ApiService(Dio()));
  sl.registerSingleton<HomeRepoImpl>(HomeRepoImpl(sl.get<ApiService>()));
}
