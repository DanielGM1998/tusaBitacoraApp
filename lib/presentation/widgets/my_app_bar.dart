import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:tusabitacoraapp/config/helper/database_helper.dart';
import 'package:tusabitacoraapp/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';
import '../screens/home/home_screen.dart';
import 'package:http/http.dart' as http;

AppBar myAppBar(BuildContext context, String name, String idapp) {
  final Size size = MediaQuery.of(context).size;
  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

  Future<bool> onWillPop1(Size size, final isLandscape) async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión', style: TextStyle(fontSize: isLandscape
          ? size.width * 0.03
          : size.width * 0.04),),
        content: Text('¿Deseas cerrar sesión?', style: TextStyle(fontSize: isLandscape
          ? size.width * 0.02
          : size.width * 0.03),),
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
              : size.width * 0.03),),
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
            onPressed: () async {
              SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove("usuario");
              //await prefs.remove("token");
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, 'login');
            },
            child: Text('Si', style: TextStyle(fontSize: isLandscape
              ? size.width * 0.02
              : size.width * 0.03)),
          ),
        ],
      ),
    )) ??
    false;
  }
  
  return AppBar(
    elevation: 1,
    toolbarHeight: 100,
    shadowColor: myColorIntense,
    centerTitle: true,
    backgroundColor: myColorIntense,
    title: Text(name, style: TextStyle(color: Colors.white, fontSize: size.width * 0.04)),
    iconTheme: const IconThemeData(color: Colors.white),
    leading: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, size: size.width * 0.05),
            onPressed: () {
              Scaffold.of(context).openDrawer(); 
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
    actions: <Widget>[
      IconButton(
        onPressed: () => _mostrarDialogo(context, size, isLandscape),
        icon: Icon(Icons.cloud_sync, size: size.width * 0.05),
        color: Colors.white,
      ),
      PopupMenuButton(
        color: myColorIntense,
        icon: Icon(Icons.more_vert_outlined, color: Colors.white, size: size.width * 0.05),
        itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.login, size: size.width * 0.05),
                  SizedBox(width: size.width * 0.03),
                  Text("Cerrar sesión", style: TextStyle(color: Colors.white, fontSize: isLandscape
                    ? size.width * 0.019
                    : size.width * 0.03)),
                ],
              ),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 1) {
            onWillPop1(size, isLandscape);
          }
        },
      ),
    ],
  );
}

void _mostrarDialogo(BuildContext pantallaContext, Size size, final isLandscape) {
  showDialog(
    context: pantallaContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('¿Deseas sincronizar los registros?', style: TextStyle(fontSize: isLandscape
          ? size.width * 0.02
          : size.width * 0.03)),
        actions: [
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text("Cancelar", style: TextStyle(fontSize: isLandscape
              ? size.width * 0.02
              : size.width * 0.03),),
          ),
          SizedBox(width: MediaQuery.of(pantallaContext).size.width * 0.02),
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
            onPressed: () {
              // Cerrar el diálogo
              Navigator.of(dialogContext).pop();

              // Esperar que el diálogo se cierre
              Future.delayed(Duration.zero, () async {
                // Mostrar loading
                EasyLoading.show(
                  status: 'Sincronizando...',
                  maskType: EasyLoadingMaskType.black,
                );

                String check = await sincronizarRegistros();

                EasyLoading.dismiss();

                // Mostrar snackbar en la pantalla principal
                if (pantallaContext.mounted) {
                  if(check=="Sincronizado exitosamente"){
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(pantallaContext).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                "Sincronizado exitosamente",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }else if(check=="Error, verificar conexión a internet"){
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(pantallaContext).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                "Error, Verificar conexión a Internet",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }else if(check=="No hay registros pendientes"){
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(pantallaContext).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                "No hay registros pendientes",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              });
            },
            child: Text("Síncronizar", style: TextStyle(fontSize: isLandscape
              ? size.width * 0.02
              : size.width * 0.03),),
          ),
        ],
      );
    },
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

Future<String> sincronizarRegistros() async {
  final db = await DatabaseHelper.instance.database;
  final List<Map<String, dynamic>> registrosPendientes = await db.query('registros', where: 'status = ?', whereArgs: [2]);

  if (registrosPendientes.isEmpty) {
    return "No hay registros pendientes";
  }

  for (var registro in registrosPendientes) {
    // Decodificar cada lista de rutas
    List<String> evidenciaPaths = List<String>.from(jsonDecode(registro['evidencia_url']));
    List<String> evidenciasPaths = List<String>.from(jsonDecode(registro['evidencias_url']));
    List<String> firmaPaths = List<String>.from(jsonDecode(registro['firma_url']));

    // Unir todas las rutas en una sola lista
    List<String> todasLasRutas = [
      ...evidenciaPaths,
      ...evidenciasPaths,
      ...firmaPaths,
    ];

    bool carga = await uploadEvidencia(imagenes: todasLasRutas, vin: registro['vin'] ?? "");

    if (!carga) {
      log("Falló la subida de evidencia para VIN: ${registro['vin']}, deteniendo sincronización.");
      return "Error, verificar conexión a internet";
    }
    // for(var item in paths){
    //   log(item);
    // }

    final Map<String, dynamic> datosASincronizar = {      
      'fm': registro['fk_matricula'],
      'n':  registro['nombre'],
      'e':  registro['empresa_externo'],
      'ev': registro['evidencia_externo'],
      'fe': registro['fecha_entrada'],
      'fs': registro['fecha_salida'],
      'f':  registro['fecha'],
      'g':  registro['guardia'],
      'fi': registro['fila'],
      'v':  registro['vin'],
      'm':  registro['modelo'],
      'll': registro['llave'],
      'd':  registro['distribuidor'],
      'nu': registro['ejes'],
      'o':  registro['origen'],
      'mi': registro['modeloTanqueIzq'],
      'cmi':registro['cmTanqueIzq'],
      'md': registro['modeloTanqueDer'],
      'cmd':registro['cmTanqueDer'],
      't':  registro['tipoTanque'],
      'ni': registro['nivel'],
      'eq': registro['equipamiento']
    };

    //log("Datos a enviar (Map): $datosASincronizar");
    log("Datos a enviar (JSON): ${jsonEncode(datosASincronizar)}");

    final response = await http.post(
      Uri.parse('https://trasladosuniversales.com.mx/app/bitacora/addEntrada.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datosASincronizar),
    );
    log(response.body);
    log(response.statusCode.toString());

    if (response.statusCode == 200) {
      await db.update(
        'registros',
        {'status': 1},
        where: 'id_registro = ?',
        whereArgs: [registro['id_registro']],
      );
    } else {
      log("Error al sincronizar ID ${registro['id_registro']}: ${response.body}");
      return "Error, verificar conexión a internet";
    }
  }
  return "Sincronizado exitosamente";
}

Future<bool> uploadEvidencia({required List<String> imagenes, required String vin}) async {
  if (!await verificarConexion()) {
    log("Sin conexión a internet");
    return false;
  }

  final ftpClient = FTPConnect(
    ftpServer,
    user: ftpUser,
    pass: ftpPass,
    timeout: 15,
    showLog: true,
  );
  bool todoCorrecto = true;
  try {
    await ftpClient.connect();
    // Navegar o crear directorios
    await ftpClient.changeDirectory("/EvidenciasBitacora");
    if(vin==""){
      await ftpClient.makeDirectory("/EvidenciasBitacora/Externo");
      await ftpClient.changeDirectory("/EvidenciasBitacora/Externo");
    }else{
      await ftpClient.makeDirectory("/EvidenciasBitacora/$vin");
      await ftpClient.changeDirectory("/EvidenciasBitacora/$vin");
    }

    // Subir cada imagen
    for (int i = 0; i < imagenes.length; i++) {
      // log(imagenes[i]);
      final file = File(imagenes[i]);
      if (!await file.exists()) {
        log("Archivo no encontrado: ${imagenes[i]}");
        todoCorrecto = false;
        continue;
      }
      final success = await ftpClient.uploadFile(
        file,
        //sRemoteName: '${vin}_${i + 1}.jpg',
      );
      if (!success) {
        log("Error subiendo imagen ${i + 1}");
        todoCorrecto = false;
      } else {
        log("Imagen ${i + 1} subida correctamente");
      }
    }
    log("Evidencias subidas con éxito");
  } catch (e) {
    log("Error en uploadEvidencia: $e");
    todoCorrecto = false;
  }finally{
    try {
      await ftpClient.disconnect();
    } catch (e) {
      log("No se pudo desconectar o no estaba conectado: $e");
    }
    log("Desconectado del servidor FTP");
  }
  return todoCorrecto;
}