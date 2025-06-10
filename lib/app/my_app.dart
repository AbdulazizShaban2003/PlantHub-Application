import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:plant_hub_app/features/account/presentation/views/account_view.dart';
import 'package:plant_hub_app/features/account/presentation/views/profile_view.dart';
import 'package:plant_hub_app/features/auth/presentation/manager/auth_provider.dart';
import 'package:plant_hub_app/features/home/presentation/views/home_view.dart';
import 'package:plant_hub_app/features/home/presentation/widgets/custom_explore_plant.dart';
import 'package:plant_hub_app/features/onBoarding/presentation/view/onBoarding_view.dart';
import 'package:plant_hub_app/features/splash/presentation/view/splash_view.dart';
import 'package:provider/provider.dart';
import '../config/theme/app_theme.dart';
import '../core/provider/language_provider.dart';
import '../core/provider/theme_provider.dart';
import '../core/service/service_locator.dart';
import '../core/utils/size_config.dart';
import '../features/account/domain/repository/profile_repository.dart';
import '../features/account/domain/repository/profile_repository_impl.dart';
import '../features/account/presentation/manager/profile_provider.dart';
import '../features/account/presentation/views/plant_photography_guide_screen.dart';
import '../features/articles/domain/repositories/plant_repo.dart';
import '../features/articles/view_model.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/domain/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/controller/operation_controller.dart';
import '../features/auth/presentation/manager/password_visibility_provider.dart';
import '../features/bookMark/data/datasource/bookmark_service.dart';
import '../features/booking/home/data/models/book_model/book_model.dart';
import '../features/booking/home/data/repos/home_repo_impl.dart';
import '../features/booking/home/presentation/manger/featured_books_cubit/featured_books_cubit.dart';
import '../features/booking/home/presentation/manger/newest_books_cubit/newset_books_cubit.dart';
import '../features/booking/home/presentation/manger/smila_books_cubit/similar_books_cubit.dart';
import '../features/chatAi/controller/chat_provider.dart';
import '../features/diagnosis/presentation/views/diagnosis_screen.dart';
import '../features/home/presentation/views/explore_plant_view.dart';

class PlantHub extends StatefulWidget {
  const PlantHub({super.key, required this.cameras});
  final List<CameraDescription> cameras;
  @override
  State<PlantHub> createState() => _PlantHubState();
}

late final BookModel bookModel;
final firebaseAuth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;
final themeProvider = Provider.of<ThemeProvider>(context as BuildContext);
final languageProvider = Provider.of<LanguageProvider>(context as BuildContext);
class _PlantHubState extends State<PlantHub> {

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return MultiBlocProvider(

      providers: [
        BlocProvider(
          create:
              (context) =>
                  FeaturedBooksCubit(sl.get<HomeRepoImpl>())
                    ..fetchFeaturedBooks(),
        ),
        BlocProvider(
          create:
              (context) =>
                  NewsetBooksCubit(sl.get<HomeRepoImpl>())..fetchNewestBooks(),
        ),
        BlocProvider(
          create: (context) {
            final cubit = SimilarBooksCubit(sl.get<HomeRepoImpl>());
            if (bookModel.volumeInfo.categories != null &&
                bookModel.volumeInfo.categories!.isNotEmpty) {
              cubit.fetchSimilarBooks(
                category: bookModel.volumeInfo.categories![0],
              );
            }
            return cubit;
          },
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider(create: (_) => AuthRemoteDataSource()),
          Provider(create: (_) => OperationController()),
          Provider(create: (_) => PlantRepository()),
          Provider<BookmarkService>(
            create: (_) => BookmarkService(FirebaseAuth.instance.currentUser?.uid),
          ),          Provider(
            create:
                (context) => AuthRepositoryImpl(
                  remoteDataSource: context.read<AuthRemoteDataSource>(),
                ),
          ),
          Provider<ProfileRepository>(
            create:
                (_) => ProfileRepositoryImpl(
                  auth: firebaseAuth,
                  firestore: firestore,
                ),
          ),
          ChangeNotifierProvider(
            create:
                (context) => ProfileProvider(context.read<ProfileRepository>()),
          ),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => PlantViewModel()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
          Provider(
            create:
                (context) => AuthProviderManager(
                  repository: context.read<AuthRepositoryImpl>(),
                  operationController: context.read<OperationController>(),
                ),
          ),
        ],
        child: Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            final languageProvider = Provider.of<LanguageProvider>(context);
            return MaterialApp(
              title: 'Plant Hub',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: Locale('en'),
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: ThemeMode.dark,
              home: SplashView()
            );
          },
        ),
      ),
    );
  }
}
