import 'package:get_it/get_it.dart';
import '../cache/cache_helper.dart';

final sl = GetIt.instance;
Future<void> setup()async {
sl.registerLazySingleton<CacheHelper>(()=>CacheHelper());

}