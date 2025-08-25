import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/main.dart';
import 'package:tusabitacoraapp/presentation/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login';

  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  // ignore: non_constant_identifier_names
  String _matri = "";
  String _contrasena = "";
  bool _passwordVisible = true;
  var textController = TextEditingController();

  final colors = <Color>[
    myColorBackground3,
    myColorBackground3,
    myColorBackground3,
    myColorBackground3,
    myColorBackground1,
  ];

  // Permisos
  Future<void> requestPermission() async {
    var status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      //print('Permiso otorgado');
    } else {
      //print('Permiso denegado');
    }

    // NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   // log('Permisos de notificaciones otorgados.');
    // } else {
    //   // log('Permisos de notificaciones denegados.');
    //   return;
    // }
  }

  // Función de login segura
  Future<String> getLoginSafe(String matricula, String pass) async {
    try {
      return await getLogin(matricula, pass).timeout(
        const Duration(seconds: 10),
        onTimeout: () => "Error, verificar conexión a Internet",
      );
    } catch (e) {
      //return "Error de conexión: $e";
      return "Error, verificar conexión a Internet";
    }
  }

  // conexión
  Future<String> getLogin(matricula, pass) async {
    String result = "";
    try{
      bool isConnected = await mssqlConnection.connect(
        ip: ipSQL,
        port: portSQL,
        databaseName: databaseSQL,
        username: usernameSQL,
        password: passSQL,
        timeoutInSeconds: 15,
      );
      if(isConnected){
        String query = "SELECT TOP 1 * FROM usuarios2 WHERE Matricula = $matricula AND Contraseña = '$pass' AND Carpeta_SGC = 'Patio' AND Contraseña != 'Baja de la empresa' ";
        result = await mssqlConnection.getData(query);
        // log(result);
        if(result.length <= 2){
          return result = "Error, verificar datos";
        }else{
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('usuario', result);
          return result = "Correcto";
        }
      }else{
        //log("No se puede establecer conexión con el servidor");
        return result = "Error, verificar conexión a Internet";
      }
    }catch (e) {
      //log("Error al conectar o consultar SQL: $e");
      //return "Error de conexión: $e";
      return result = "Error, verificar conexión a Internet";
    }
  }

  // login
  // Future<String> getLogin(matricula, pass) async {
  //   final url = Uri.parse("http://app.transladosuniversales.com.mx/app/bitacora/login.php?=1760");
  //   final response = await http.get(url);
  //   log(matricula);
  //   log(pass);
  //   final data = json.decode(response.body);
  //   if (data["response"] == true) {
  //     log("Bienvenido, ${data["user"]["nombre"]}");
  //     return "Correcto";
  //   } else {
  //     log("Error: ${data["message"]}");
  //     return "Error, verificar datos";
  //   }
  // }

  void onError(String messageError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        padding: const EdgeInsets.all(8.0),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                messageError,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showProgress(BuildContext context, String user, String pass) async {
    var result = await showDialog(
      context: context,
      //builder: (context) => FutureProgressDialog(getLogin(user, pass)),
      builder: (context) => FutureProgressDialog(getLoginSafe(user, pass)),
    );
    if (!context.mounted) return;
    showResultDialog(context, result);
  }

  Future<void> showResultDialog(BuildContext context, String result) async {
    if (result == 'Correcto') {
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * animation.value,
                sigmaY: 10 * animation.value,
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    }else {
      onError(result);
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        bool value = await _onWillPop(size, isLandscape);
        if (value) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(value);
        }
      },
      child: RouteAwareWidget(
        screenName: "login",
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: const Alignment(0.0, 1.3),
                colors: colors,
                tileMode: TileMode.repeated,
              ),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: isLandscape
                          ? size.width * 0.03
                          : size.width * 0.1,
                        ),
                        Image.asset(myLogo, 
                        width: isLandscape
                          ? size.width * 0.2 
                          : size.width * 0.5),
                        SizedBox(
                          height: isLandscape
                            ? size.height * 0.04
                            : size.height * 0.12,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Inicio de Sesión",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: myColor,
                                  fontSize: isLandscape
                                    ? size.width * 0.025
                                    : size.width * 0.05),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: isLandscape
                              ? size.height * 0.02
                              : size.height * 0.05),
                            Column(
                              children: <Widget>[
                                SizedBox(
                                  height: isLandscape
                                    ? size.height * 0.012
                                    : size.height * 0.012,
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ThemeData().colorScheme.copyWith(
                                      primary: myColor,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.01, right: size.width * 0.01),
                                    child: TextField(
                                      style: TextStyle(color: myColor, 
                                      fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.05),
                                      keyboardType:
                                        TextInputType.multiline,
                                      cursorColor: myColor,
                                      onChanged: (valor) {
                                        setState(() {
                                          _matri = valor;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                        hintText: "Matrícula del usuario",
                                        hintStyle: TextStyle(color: myColor, 
                                          fontSize: isLandscape
                                            ? size.width * 0.02
                                            : size.width * 0.04),
                                        labelText: "Matrícula",
                                        labelStyle: TextStyle(color: myColor, 
                                          fontSize: isLandscape
                                            ? size.width * 0.02
                                            : size.width * 0.04),
                                        suffixIcon: Icon(
                                          Icons.numbers,
                                          size: isLandscape
                                            ? size.width * 0.03
                                            : size.width * 0.05,
                                          color: myColor,
                                        ),
                                        icon: Icon(
                                          Icons.numbers_outlined,
                                          size: isLandscape
                                          ? size.width * 0.03
                                          : size.width * 0.05,
                                          color: myColor,
                                        )),
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: isLandscape
                                  ? size.height * 0.025
                                  : size.height * 0.012,
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ThemeData().colorScheme.copyWith(
                                      primary: myColor,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.01, right: size.width * 0.01),
                                    child: TextField(
                                      obscureText: _passwordVisible,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      cursorColor: myColor,
                                      style: TextStyle(color: myColor, 
                                        fontSize: isLandscape
                                        ? size.width * 0.02
                                        : size.width * 0.05),
                                      onChanged: (valor) {
                                        setState(() {
                                          _contrasena = valor;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                          hintText: "Contraseña del usuario",
                                          hintStyle: TextStyle(color: myColor, 
                                            fontSize: isLandscape 
                                            ? size.width * 0.02
                                            : size.width * 0.04),
                                          labelText: "Contraseña",
                                          labelStyle:
                                            TextStyle(color: myColor, 
                                              fontSize: isLandscape 
                                              ? size.width * 0.02
                                              : size.width * 0.04),
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _passwordVisible =
                                                    !_passwordVisible;
                                                });
                                              },
                                              icon: Icon(
                                                _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                                size: isLandscape 
                                                ? size.width * 0.03
                                                : size.width * 0.05,
                                                color: myColor,
                                              )),
                                          icon: Icon(
                                            Icons.bookmark,
                                            size: isLandscape 
                                              ? size.width * 0.03
                                              : size.width * 0.05,
                                            color: myColor,
                                          )),
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (value) async {
                                        if (_matri != "" &&
                                            _contrasena != "") {
                                          //bool isValid =
                                          //EmailValidator.validate(_matri);
                                          //if (isValid) {
                                          if (_contrasena.length < 2) {
                                            onError("La contraseña debe incluir al menos 2 caracteres");
                                          } else {
                                            showProgress(context, _matri, _contrasena);
                                          }
                                          // } else {
                                          //   awesomeTopSnackbar(
                                          //     context,
                                          //     "Debe ingresar un Email valido",
                                          //     textStyle: const TextStyle(
                                          //         color: Colors.white,
                                          //         fontStyle: FontStyle.normal,
                                          //         fontWeight: FontWeight.w400,
                                          //         fontSize: 20),
                                          //     backgroundColor:
                                          //         Colors.orangeAccent,
                                          //     icon: const Icon(Icons.check,
                                          //         color: Colors.black),
                                          //     iconWithDecoration: BoxDecoration(
                                          //       borderRadius:
                                          //           BorderRadius.circular(20),
                                          //       border: Border.all(
                                          //           color: Colors.black),
                                          //     ),
                                          //   );
                                          // }
                                        } else {
                                          onError("Debe ingresar teléfono y contraseña");
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.02,
                                ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(
                                  top: 10, right: 10, left: 10),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: myColor,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size(isLandscape
                                    ? size.width * 0.1
                                    : size.width * 0.2,
                                    isLandscape
                                      ? size.height * 0.01
                                      : size.height * 0.02),
                                  padding: EdgeInsets.symmetric(vertical: isLandscape
                                    ? size.width * 0.01
                                    : size.width * 0.02, 
                                    horizontal: isLandscape
                                    ? size.width * 0.010
                                    : size.width * 0.020),
                                ),
                                onPressed: () async {
                                  if (_matri != "" && _contrasena != "") {
                                    if (_contrasena.length < 2) {
                                      onError("La contraseña debe incluir al menos 2 caracteres");
                                    } else {
                                      showProgress(
                                          context, _matri, _contrasena);
                                    }
                                  } else {
                                    onError("Debe ingresar teléfono y contraseña");
                                  }
                                },
                                child: Text(
                                  "Iniciar sesión",
                                  style: TextStyle(color: myColor, 
                                    fontSize: isLandscape
                                    ? size.width * 0.025
                                    : size.width * 0.04),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              height: isLandscape
                                ? 0
                                : size.height * 0.10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(Size size, final isLandscape) async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Cerrar aplicación', style: TextStyle(fontSize: isLandscape
              ? size.width * 0.03
              : size.width * 0.04)),
            content: Text('¿Deseas salir de la aplicación?', style: TextStyle(fontSize: isLandscape
              ? size.width * 0.02
              : size.width * 0.03)),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(isLandscape
                    ? size.width * 0.15
                    : size.width * 0.2,
                    isLandscape
                      ? size.height * 0.02
                      : size.height * 0.02),
                  padding: EdgeInsets.symmetric(vertical: isLandscape
                    ? size.width * 0.01
                    : size.width * 0.02,    
                    horizontal: isLandscape
                    ? size.width * 0.003
                    : size.width * 0.010),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No', style: TextStyle(fontSize: isLandscape
                 ? size.width * 0.02
                 : size.width * 0.03)),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(isLandscape
                    ? size.width * 0.15
                    : size.width * 0.2,
                    isLandscape
                      ? size.height * 0.02
                      : size.height * 0.02),
                  padding: EdgeInsets.symmetric(vertical: isLandscape
                    ? size.width * 0.01
                    : size.width * 0.02, 
                    horizontal: isLandscape
                    ? size.width * 0.003
                    : size.width * 0.010),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Si', style: TextStyle(fontSize: isLandscape
                  ? size.width * 0.02
                  : size.width * 0.03)),
              ),
            ],
          ),
        )) ??
        false;
  }
}
