import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/presentation/screens/home/home_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? userIsLoggedIn;

  final colors = <Color>[
    myColorBackground3,
    myColorBackground3,
    myColorBackground3,
    myColorBackground3,
    myColorBackground1,
  ];

  getLoggedInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('usuario') != null){
      if (mounted) {
        setState(() {
          userIsLoggedIn = "inicio";
        });
      }
    }else{
      if (mounted) {
        setState(() {
          userIsLoggedIn = "login";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return FutureBuilder(
      future: getLoggedInState(),
      builder: (context, snapshot) {
        if (userIsLoggedIn == "inicio") {
          return EasySplashScreen(
            gradientBackground: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(isLandscape
                ? 0.0 
                : 0.0, 
                isLandscape 
                ? 2.0
                : 1.3),
              colors: colors,
              tileMode: TileMode.repeated,
            ),
            logo: Image.asset(myLogo, scale: 5),
            logoWidth: size.height*0.2,
            showLoader: true,
            loaderColor: myColor,
            navigator: const HomeScreen(),
            durationInSeconds: 2,
          );
        } else if (userIsLoggedIn == "login") {
          return EasySplashScreen(
            gradientBackground: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(isLandscape
                ? 0.0 
                : 0.0, 
                isLandscape 
                ? 2.0
                : 1.3),
              colors: colors,
              tileMode: TileMode.repeated,
            ),
            logo: Image.asset(myLogo, scale: 5),
            logoWidth: size.height*0.2,
            showLoader: true,
            loaderColor: myColor,
            navigator: const LoginScreen(),
            durationInSeconds: 2,
          );
        }
        return const SizedBox(height: 0, width: 0);
      }
    );
  }
}
