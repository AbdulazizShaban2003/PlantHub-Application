import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/data/data.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_view.dart';
import 'package:plant_hub_app/features/auth/domain/usecases/google_sign.dart';
import 'package:plant_hub_app/features/auth/presentation/views/login_view.dart';
import 'package:plant_hub_app/features/auth/presentation/views/sign_up_view.dart';
import 'package:plant_hub_app/features/splash/presentation/view/splash_view.dart';
import 'package:provider/provider.dart';
import '../config/theme/app_theme.dart';
import '../core/utils/size_config.dart';
import '../features/articles/view_model.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/domain/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/sign_up_usecase.dart';
import '../features/auth/presentation/controller/operation_controller.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../features/auth/presentation/viewmodels/password_visibility_provider.dart';
import '../features/chatAi/controller/chat_provider.dart';
import 'package:provider/provider.dart';

class PlantHub extends StatefulWidget {
  const PlantHub({super.key});
  @override
  State<PlantHub> createState() => _PlantHubState();
}
class _PlantHubState extends State<PlantHub> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return  MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
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
              (context) =>
              SignUpUseCase(repository: context.read<AuthRepositoryImpl>()),
        ),
        Provider(
          create:
              (context) =>
              LoginUseCase(repository: context.read<AuthRepositoryImpl>()),
        ),

        Provider(
          create:
              (context) => ForgotPasswordUseCase(
            repository: context.read<AuthRepositoryImpl>(),
          ),

        ),
        Provider(
          create: (_) => PlantRepository(),
        ),
        Provider(
          create: (context) => SignInWithGoogleUseCase(
            repository: context.read<AuthRepositoryImpl>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PlantViewModel(),
        ),
        ChangeNotifierProvider(

          create:
              (context) => AuthViewModel(
            signUpUseCase: context.read<SignUpUseCase>(),
            loginUseCase: context.read<LoginUseCase>(),
            forgotPasswordUseCase: context.read<ForgotPasswordUseCase>(),
            signInWithGoogleUseCase: context.read<SignInWithGoogleUseCase>(),
            operationController: context.read<OperationController>(),
          ),
        ),
      ],
      child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              darkTheme: AppThemes.darkTheme,
              themeMode: ThemeMode.dark,
              theme: AppThemes.darkTheme,
              home: PlantsPage()
      ),
    );
  }
}
