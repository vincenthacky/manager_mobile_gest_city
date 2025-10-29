import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_gest_city/features/admin/controller/home_controller.dart';
import 'package:manager_gest_city/features/cotisations/controllers/add_cotisation_controller.dart';
import 'package:manager_gest_city/features/cotisations/controllers/validate_payment_controller.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/utils/app_router.dart';
import 'features/authentication/controller/auth_controller.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final authController = AuthController();

  final router = AppRouter.createRouter();
  DioClient.setRouter(router);
  DioClient.setAuthController(authController);

  runApp(GestCityApp(router: router));
}

class GestCityApp extends StatelessWidget {
  final GoRouter router;

  const GestCityApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => AddCotisationController()),
        ChangeNotifierProvider(create: (_) => ValidatePaymentController()),
      ],
      child: MaterialApp.router(
        title: 'Gest City',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          fontFamily: "Gilroy",
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
