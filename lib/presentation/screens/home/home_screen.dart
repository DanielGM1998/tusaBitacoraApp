import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/models/usuario.dart';
import 'package:tusabitacoraapp/presentation/screens/entradas_salidas/entradas_salidas_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/historial/historial_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/patio/patio_screen.dart';
import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;
  String? _idapp;

  late List<Map<String, dynamic>> modulos;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    

    final jsonString = prefs.getString('usuario');
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString!);
      final Map<String, dynamic> jsonUsuario = jsonList[0];
      Usuario usuario = Usuario.fromJson(jsonUsuario);
      _userapp = usuario.nombre;
      _tipoapp = "1";
      _idapp = usuario.matricula.toString();
    } catch (e) {
      log("Error al decodificar usuario: $e");
    }
    return false;
  }

  Future<void> borrarArchivosViejosSemanas({int dias = 30}) async {
    final dir = await getDownloadsDirectory();
    final now = DateTime.now();

    final archivos = dir!.listSync(recursive: true, followLinks: false);

    for (var archivo in archivos) {
      if (archivo is File) {
        final ext = archivo.path.toLowerCase();
        // log(ext);

        if ((ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png')) && archivo.path.contains('OT-')) {
          final stat = await archivo.stat();
          final diferencia = now.difference(stat.modified);

          if (diferencia.inDays > dias) {
            try {
              await archivo.delete();
              log('Archivo eliminado: ${archivo.path}');
            } catch (e) {
              log('Error eliminando archivo: ${archivo.path} — $e');
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //log("Pantalla actual suscrita: $currentScreen");
    });
    borrarArchivosViejosSemanas(dias: 14);
  }

  // despues de initState
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    //  log("Pantalla actual: $currentScreen");
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          if(_tipoapp =="1"){
            modulos = [
              {'nombre': 'Patio', 'icono': Icons.local_shipping, 'color': Colors.green, 'ruta':  (String id) => PatioScreen(idapp: id)},
              {'nombre': 'Entradas / Salidas', 'icono': Icons.list_alt, 'color': Colors.blueAccent, 'ruta': (String id) => EntradasSalidasScreen(idapp: id)},
              {'nombre': 'Historial de bitacora', 'icono': Icons.history, 'color': Colors.orangeAccent, 'ruta': (String id) => HistorialScreen(idapp: id)},
            ];
          }else{
            modulos = [];
          }
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              bool value = await _onWillPop(size, isLandscape);
              if (value) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(value);
              }
            },
            child: RouteAwareWidget(
              screenName: "home",
              child: Scaffold(
                  backgroundColor: Colors.white.withOpacity(1),
                  appBar: myAppBar(context, nameApp, _idapp ?? "0"),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "1", idapp: _idapp ?? "0"),
                  resizeToAvoidBottomInset: false,
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0.0, 1.3),
                        colors: colors,
                        tileMode: TileMode.repeated,
                      ),
                    ),
                    child: Padding(
                  // Empieza el Padding que rodea la columna de la pantalla principal
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.02, horizontal: size.width * 0.04),
                  child: Column(
                    children: [
                      // Sección del saludo
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: size.height * 0.10,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Hola ${_userapp ?? ""}",
                              style: TextStyle(
                                fontSize: isLandscape
                                  ? size.width * 0.03
                                  : size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: myColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.00),
                      // Sección de módulos
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: size.width / (size.height / 2),
                          ),
                          itemCount: modulos.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => modulos[index]['ruta'](_idapp ?? "0"),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: modulos[index]['color'].withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          modulos[index]['icono'],
                                          size: isLandscape
                                            ? size.width * 0.05
                                            : size.width * 0.15,
                                          color: modulos[index]['color'],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          modulos[index]['nombre'],
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis, 
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: isLandscape
                                              ? size.width * 0.03
                                              : size.width * 0.03,
                                            fontWeight: FontWeight.w600,
                                            color: myColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                  ),
                ),
            ),
          );
        } else if (snapshot.data == true) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const SizedBox(height: 0, width: 0);
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const SizedBox(height: 0, width: 0);
      },
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
                onPressed: () => SystemNavigator.pop(),
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