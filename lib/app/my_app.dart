import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_view.dart';
import 'package:plant_hub_app/features/auth/domain/usecases/google_sign.dart';
import 'package:plant_hub_app/features/auth/presentation/views/login_view.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/book_view.dart';
import 'package:plant_hub_app/features/home/presentation/views/home_view.dart';
import 'package:plant_hub_app/features/splash/presentation/view/splash_view.dart';
import 'package:provider/provider.dart';
import '../config/theme/app_theme.dart';
import '../core/service/service_locator.dart';
import '../core/utils/size_config.dart';
import '../features/articles/domain/repositories/plant_repo.dart';
import '../features/articles/view_model.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/domain/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/sign_up_usecase.dart';
import '../features/auth/presentation/controller/operation_controller.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../features/auth/presentation/viewmodels/password_visibility_provider.dart';
import '../features/bookMark/data/models/datasource/bookmark_service.dart';
import '../features/booking/home/data/models/book_model/book_model.dart';
import '../features/booking/home/data/repos/home_repo_impl.dart';
import '../features/booking/home/presentation/manger/featured_books_cubit/featured_books_cubit.dart';
import '../features/booking/home/presentation/manger/newest_books_cubit/newset_books_cubit.dart';
import '../features/booking/home/presentation/manger/smila_books_cubit/similar_books_cubit.dart';
import '../features/chatAi/controller/chat_provider.dart';
import '../features/diagnosis/presentation/views/diagnosis_error.dart';
import '../features/diagnosis/presentation/views/diagnosis_healthy.dart';

class PlantHub extends StatefulWidget {
  const PlantHub({super.key});

  @override
  State<PlantHub> createState() => _PlantHubState();
}

late final BookModel bookModel;

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
          ChangeNotifierProvider(create: (_) => PlantViewModel()),

          ChangeNotifierProvider(create: (context) => ChatProvider()),
          Provider(create: (_) => PlantRepository()),
          Provider<BookmarkService>(
            create:
                (_) => BookmarkService(FirebaseAuth.instance.currentUser?.uid),
          ),
          ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
          Provider(create: (_) => OperationController()),
          Provider(create: (_) => AuthRemoteDataSource()),
          Provider(
            create:
                (context) => AuthRepositoryImpl(
                  remoteDataSource: context.read<AuthRemoteDataSource>(),
                ),
          ),
          Provider(
            create:
                (context) => SignUpUseCase(
                  repository: context.read<AuthRepositoryImpl>(),
                ),
          ),
          Provider(
            create:
                (context) => LoginUseCase(
                  repository: context.read<AuthRepositoryImpl>(),
                ),
          ),
          Provider(
            create:
                (context) => ForgotPasswordUseCase(
                  repository: context.read<AuthRepositoryImpl>(),
                ),
          ),
          Provider(
            create:
                (context) => SignInWithGoogleUseCase(
                  repository: context.read<AuthRepositoryImpl>(),
                ),
          ),
          ChangeNotifierProvider(
            create:
                (context) => AuthViewModel(
                  signUpUseCase: context.read<SignUpUseCase>(),
                  loginUseCase: context.read<LoginUseCase>(),
                  forgotPasswordUseCase: context.read<ForgotPasswordUseCase>(),
                  signInWithGoogleUseCase:
                      context.read<SignInWithGoogleUseCase>(),
                  operationController: context.read<OperationController>(),
                ),
          ),
        ],
    child:  MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.dark,
          theme: AppThemes.darkTheme,
          home: SplashView(),
    ))
        );
  }
}
