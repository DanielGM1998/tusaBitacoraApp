import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/main.dart';
import 'package:tusabitacoraapp/models/usuario.dart';
import 'package:tusabitacoraapp/presentation/screens/historial/historial_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/home/home_screen.dart';
import 'package:tusabitacoraapp/presentation/widgets/side_menu.dart';
import 'package:http/http.dart' as http;

class EvidenciaScreen extends StatefulWidget {
  static const String routeName = 'evidencia';

  final String idapp;
  final String directory;
  final String pathImages;

  const EvidenciaScreen({
    Key? key,
    required this.idapp, required this.pathImages, required this.directory,
  }) : super(key: key);

  @override
  State<EvidenciaScreen> createState() => _EvidenciaScreenState();
}

class _EvidenciaScreenState extends State<EvidenciaScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<File> downloadedImages = [];
  bool isLoading = true;
  String error = '';

  late List<String> imagenes;

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('usuario');
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString!);
      final Map<String, dynamic> jsonUsuario = jsonList[0];
      Usuario usuario = Usuario.fromJson(jsonUsuario);
      _userapp = usuario.nombre;
      _tipoapp = "1";
    } catch (e) {
      log("Error al decodificar usuario: $e");
    }
    return false;
  }

  Future<void> descargarYMostrar() async {
    final Directory? appDocDir = await getDownloadsDirectory();
    if (appDocDir == null) {
      log("No se pudo obtener el directorio de descargas.");
      return;
    }

    final List<File> archivosLocales = [];

    // Paso 1: Buscar imágenes locales primero
    for (String imageName in imagenes) {
      final localPath = "${appDocDir.path}/$imageName";
      final localFile = File(localPath);

      if (await localFile.exists()) {
        log("Archivo local encontrado: $imageName");
        archivosLocales.add(localFile);
      }
    }

    // Mostrar imágenes locales
    if (mounted) {
      setState(() {
        downloadedImages = archivosLocales;
      });
    }

    // Paso 2: Ver si faltan imágenes por descargar
    final faltantes = imagenes.where((img) =>
      !archivosLocales.any((f) => f.path.endsWith(img))
    ).toList();

    if (faltantes.isEmpty) {
      log("Todas las imágenes ya están localmente.");
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    // Paso 3: Intentar conexión FTP
    final ftpClient = FTPConnect(
      ftpServer,
      user: ftpUser,
      pass: ftpPass,
      timeout: 5, // Más rápido ante errores
      showLog: true,
    );

    try {
      await ftpClient.connect();
      log("Conectado al FTP");
      await ftpClient.changeDirectory("/EvidenciasBitacora/${widget.directory}");

      // Paso 4: Descargar faltantes
      for (int i = 0; i < faltantes.length; i++) {
        final imageName = faltantes[i];
        final localPath = "${appDocDir.path}/$imageName";
        final localFile = File(localPath);

        log("Descargando [$i/${faltantes.length}]: $imageName");

        try {
          final descargado = await ftpClient.downloadFile(imageName, localFile);
          if (descargado) {
            if (mounted) {
              setState(() {
                downloadedImages.add(localFile);
              });
            }
            log("✓ Descargado: $imageName");
          } else {
            log("✗ Falló descarga: $imageName");
          }
        } catch (e) {
          log("⚠ Error al descargar $imageName: $e");
        }
      }
    } catch (e) {
      log("❌ Error de conexión FTP: $e");
      if (mounted) {
        onError("Sin conexión. Solo se mostrarán imágenes locales.");
      }
    } finally {
      try {
          await ftpClient.disconnect();
        } catch (e) {
          log("No se pudo desconectar o no estaba conectado: $e");
        }
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void onError(String messageError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.all(8.0),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                messageError,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> verificarConexion() async {
    try {
      final response = await http.get(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void openCustomViewer(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(imageFile),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
              Positioned(
                top: 30,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 40, color: Colors.white), // tamaño personalizado
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();  
    // Convertir el string JSON a lista
    try {
      imagenes = List<String>.from(jsonDecode(widget.pathImages));
    } catch (e) {
      //log("Error al decodificar pathImages: $e");
      imagenes = [];
    }
    descargarYMostrar();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              Navigator.of(context).pushReplacementNamed(
                HistorialScreen.routeName,
                arguments: {
                  'idapp': widget.idapp,
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0.0, 1.3),
                  colors: colors,
                  tileMode: TileMode.repeated,
                ),
              ),
              child: RouteAwareWidget(
                screenName: "evidencia",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp?? "0", tipoapp: _tipoapp ?? "1", idapp: widget.idapp),
                  appBar: AppBar(
                    title: Text("$nameEvidencia ${widget.directory}", style: TextStyle(color: Colors.white, fontSize: size.width * 0.04)),
                    elevation: 1,
                    toolbarHeight: 100,
                    centerTitle: true,
                    shadowColor: Colors.white,
                    backgroundColor: myColorIntense,
                    iconTheme: const IconThemeData(color: Colors.white),
                    leading: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu, size: size.width * 0.05),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.home_outlined, size: size.width * 0.05),
                          onPressed: () {
                            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              HomeScreen.routeName,
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                    leadingWidth: size.width * 0.28,
                  ),
                  resizeToAvoidBottomInset: false,
                  body: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: const Alignment(0.0, 1.3),
                            colors: colors,
                            tileMode: TileMode.repeated,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                        child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : error.isNotEmpty
                              ? Center(child: Text(error))
                              : downloadedImages.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inbox,
                                            color: Colors.grey,
                                            size: isLandscape
                                                ? size.width * 0.06
                                                : size.width * 0.06,
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.width * 0.025),
                                          Text('No hay evidencias',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: isLandscape
                                                  ? size.width * 0.025
                                                  : size.width * 0.030,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: downloadedImages.length,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isLandscape 
                                          ? 5
                                          : 3,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                      ),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            openCustomViewer(context, downloadedImages[index]);
                                            // showImageViewer(
                                            //   context,
                                            //   Image.file(downloadedImages[index]).image,
                                            //   swipeDismissible: false,
                                            //   doubleTapZoomable: true,
                                            //   backgroundColor: Colors.black,
                                            // );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8), // MISMO radio para todo
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 2,
                                                ),
                                                // Aquí no necesitas borderRadius porque ya está en ClipRRect
                                              ),
                                              child: Image.file(
                                                downloadedImages[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}