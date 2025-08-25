import 'package:cloudflare/cloudflare.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/presentation/screens/entradas_salidas/edit_entradas_salidas_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/entradas_salidas/entradas_salidas_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/historial/evidencia_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/historial/historial_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/home/home_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/login/login_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/patio/patio_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/splash/splash_screen.dart';

import 'config/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

String? initialPayload;

MssqlConnection mssqlConnection = MssqlConnection.getInstance();

// Cloudflare
late Cloudflare cloudflare;
String? cloudflareInitMessage;

void configEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.light
    ..maskColor = myColor
    ..progressColor = myColor
    ..textColor = Colors.red
    ..dismissOnTap = false
    ..userInteractions = false;
}

void main() async {
    
  await initializeDateFormatting('es', null); // Inicializa para español
  Intl.defaultLocale = 'es'; // Configura el locale predeterminado

  // CloudFlare
  try {
    cloudflare = Cloudflare(
      apiUrl: apiUrl,
      accountId: accountId,
      token: tokenCloudflare,
      apiKey: apiKey,
      accountEmail: accountEmail,
      userServiceKey: userServiceKey,
    );
    await cloudflare.init();
  } catch (e) {
    cloudflareInitMessage = '''
    Check your environment definitions for Cloudflare.
    Make sure to run this app with:  
    
    flutter run
    --dart-define=CLOUDFLARE_API_URL=https://api.cloudflare.com/client/v4
    --dart-define=CLOUDFLARE_ACCOUNT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_ACCOUNT_EMAIL=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    --dart-define=CLOUDFLARE_USER_SERVICE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    Exception details:
    ${e.toString()}
    ''';
  }

  // Config progressdialog
  configEasyLoading();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: nameApp,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme(selectedColor: 0).getTheme(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
        Locale('he', ''),
        Locale('es', ''),
        Locale('ru', ''),
        Locale('ko', ''),
        Locale('hi', ''),
      ],
      builder: EasyLoading.init(),
      navigatorObservers: [appRouteObserver],
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (BuildContext context) => const SplashScreen(),
        LoginScreen.routeName: (BuildContext context) => const LoginScreen(),
        HomeScreen.routeName: (BuildContext context) => const HomeScreen(),
        PatioScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PatioScreen(
            idapp: args['idapp'],
          );
        },        
        EntradasSalidasScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EntradasSalidasScreen(
            idapp: args['idapp'],
          );
        },
        HistorialScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HistorialScreen(
            idapp: args['idapp'],
          );
        },
        EditEntradasSalidasScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EditEntradasSalidasScreen(
            idapp: args['idapp'],
            idRegistro: args['id_registro'],
          );
        },
        EvidenciaScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EvidenciaScreen(
            idapp: args['idapp'],
            directory: args['directory'],
            pathImages: args['pathImages'],
          );
        },
      },
    );
  }
}
