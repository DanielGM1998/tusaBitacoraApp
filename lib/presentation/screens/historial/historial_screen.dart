import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/main.dart';
import 'package:tusabitacoraapp/models/usuario.dart';
import 'package:tusabitacoraapp/presentation/screens/historial/evidencia_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/side_menu.dart';
import '../home/home_screen.dart';

class HistorialScreen extends StatefulWidget {
  static const String routeName = 'historial';

  final String idapp;

  const HistorialScreen({
    Key? key,
    required this.idapp,
  }) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool finalScreen = false;

  List<dynamic> filteredItems = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

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

  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;
  int page = 1;
  final int limit = 50;
  List items = [];
  late ScrollController controller;

  List<DateTime?> _dialogCalendarPickerValue = [
    DateTime.now().add(const Duration(days: -7)),
    DateTime.now(),
  ];

  String now = "${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -7)))} a ${DateFormat('yyyy-MM-dd').format(DateTime.now())}";

  String inicio = "null", fin = "null";

  // filtro "0" = Cancelada, "1" = Autorizada, "2" = Pendiente
  String? _selectedStatus; 

  // llamada a servidor para solicitudes
  void fistLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    EasyLoading.show(
      status: 'Cargando...',
      maskType: EasyLoadingMaskType.black
    );
    try {
      final http.Response response;
      if(inicio == "null" && fin == "null"){
        inicio = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -7)));
        fin = DateFormat('yyyy-MM-dd').format(DateTime.now());
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            //path: '/solicitud/app/getAll/$inicio/$fin',
            path: '/app/bitacora/getHistorialRegistrosPatio.php',
            queryParameters: {
              'fecha_inicio': inicio,
              'fecha_final': fin,
            },
          ),
        );
      }else if(inicio == "null"){
        inicio = fin;
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            //path: '/solicitud/app/getAll/$inicio/$fin',
            path: '/app/bitacora/getHistorialRegistrosPatio.php',
            queryParameters: {
              'fecha_inicio': inicio,
              'fecha_final': fin,
            },
          ),
        );
      }else if(fin == "null"){
        fin = inicio;
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            //path: '/solicitud/app/getAll/$inicio/$fin',
            path: '/app/bitacora/getHistorialRegistrosPatio.php',
            queryParameters: {
              'fecha_inicio': inicio,
              'fecha_final': fin,
            },
          ),
        );
      }else{
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            //path: '/solicitud/app/getAll/$inicio/$fin',
            path: '/app/bitacora/getHistorialRegistrosPatio.php',
            queryParameters: {
              'fecha_inicio': inicio,
              'fecha_final': fin,
            },
          ),
        );
      }

      //log(response.statusCode.toString());

      if (response.statusCode == 200) {
        //log(response.body);
        final jsonResponse = json.decode(response.body);
        //log(jsonResponse.toString());
        setState(() {
          items = jsonResponse['data'];
          //log(jsonResponse['data']);
          filteredItems = List.from(items); // Inicializa la lista filtrada
          //log(filteredItems.length.toString());
        });
      } else {
        if (kDebugMode) {
          print("Error en la respuesta: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar datos');
      }
      if (!mounted) return;
        final context = this.context;
      // ignore: use_build_context_synchronously
      if (!mounted) return;
        // ignore: use_build_context_synchronously
        onError(context, "Verificar conexión a Internet");
    }

    if (!mounted) return;

    EasyLoading.dismiss();

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    // if (hasNextPage &&
    //     !isFirstLoadRunning &&
    //     !isLoadMoreRunning &&
    //     controller.position.pixels >=
    //         controller.position.maxScrollExtent - 100) {
    //   setState(() {
    //     isLoadMoreRunning = true;
    //   });

    //   page += 1;

    //   try {
    //     final response = await http.get(
    //       Uri(
    //         scheme: https,
    //         host: host,
    //         path: '/solicitud/app/getAll/2025-01-01/2025-02-06',
    //       ),
    //     );

    //     if (response.statusCode == 200) {
    //       final jsonResponse = json.decode(response.body);
    //       List newItems = jsonResponse['data'];

    //       if (newItems.isNotEmpty) {
    //         setState(() {
    //           for (var item in newItems) {
    //             if (!items
    //                 .any((existingItem) => existingItem['data_id'] == item['data_id'])) {
    //               items.add(item);
    //             }
    //           }
    //         });
    //       } else {
    //         setState(() {
    //           hasNextPage = false; // No hay más datos para cargar
    //         });
    //       }
    //     } else {
    //       if (kDebugMode) {
    //         print("Error en la respuesta: ${response.statusCode}");
    //       }
    //     }
    //   } catch (e) {
    //     if (kDebugMode) {
    //       print('Error al cargar más datos');
    //     }
    //   }

    //   setState(() {
    //     isLoadMoreRunning = false; // Finaliza el estado de carga
    //   });
    // }
  }

  // busqueda
  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        _selectedStatus = null;
        searchController.clear();
        filteredItems = List.from(items); // Restaura la lista original
      }
    });
  }

  String removeDiacritics(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  void filterItems(String query) {
    final normalizedQuery = removeDiacritics(query);
    setState(() {
      filteredItems = items.where((item) {
        final fk_matricula = removeDiacritics(item['fk_matricula'] ?? '');
        final VIN = removeDiacritics(item['VIN'] ?? '');
        final nombre = removeDiacritics(item['nombre'] ?? '');
        final empresa_externo = removeDiacritics(item['empresa_externo'] ?? '');
        final statusMatch = _selectedStatus == null || item['estado'] == _selectedStatus;
        
        return (fk_matricula.contains(normalizedQuery) ||
                VIN.contains(normalizedQuery) || nombre.contains(normalizedQuery) || empresa_externo.contains(normalizedQuery)) && statusMatch;
      }).toList();
    });
  }

  void onError(BuildContext context, String messageError) {
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

  Future<void> borrarArchivosViejosSemanas() async {
    final dir = await getDownloadsDirectory();

    final archivos = dir!.listSync(recursive: true, followLinks: false);

    for (var archivo in archivos) {
      if (archivo is File) {
        final ext = archivo.path.toLowerCase();

        if ((ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png')) && archivo.path.contains('OT-')) {
          final stat = await archivo.stat();

          // Condición para borrar si está vacío o si es viejo
          if (stat.size == 0) {
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
    fistLoad();
    controller = ScrollController()..addListener(loadMore);
    borrarArchivosViejosSemanas();
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
              EasyLoading.dismiss();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                HomeScreen.routeName,
                (Route<dynamic> route) => false,
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
                screenName: "historial",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp?? "0", tipoapp: _tipoapp ?? "1", idapp: widget.idapp),
                  appBar: AppBar(
                    title: isSearching
                        ? TextField(
                            controller: searchController,
                            autofocus: true,
                            onChanged: filterItems,
                            style: TextStyle(color: Colors.white, fontSize: size.width * 0.03),
                            decoration: const InputDecoration(
                              hintText: "Matricula, VIN o Nombre",
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                          )
                        : Text(nameHistorial, style: TextStyle(color: Colors.white, fontSize: size.width * 0.04)),
                    elevation: 1,
                    toolbarHeight: 100,
                    centerTitle: true,
                    shadowColor: Colors.white,
                    backgroundColor: myColorIntense,
                    actions: [
                      isSearching
                      ? const Text("")
                      : IconButton(
                        icon: Icon(Icons.refresh, size: size.width * 0.05),
                        onPressed: (){
                            isFirstLoadRunning = false;
                            hasNextPage = true;
                            isLoadMoreRunning = false;
                            items = [];
                            page = 1;
                            _selectedStatus = null;
                            fistLoad();
                          },
                        ),
                      IconButton(
                        icon: Icon(isSearching ? Icons.close : Icons.search, size: size.width * 0.05),
                        onPressed: toggleSearch,
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
                                  Icon(Icons.assignment, size: isLandscape
                                    ? size.width * 0.04
                                    : size.width * 0.05),
                                  SizedBox(width: isLandscape
                                    ? size.width * 0.01
                                    : size.width * 0.03),
                                  Text("Descargar Excel", style: TextStyle(color: Colors.white, 
                                    fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03)),
                                ],
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          if (value == 1) {
                            onWillPop2(size, isLandscape);
                          }
                        },
                      ),
                    ],
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
                        child: CustomRefreshIndicator(
                          // ignore: implicit_call_tearoffs
                          builder: MaterialIndicatorDelegate(
                            builder: (context, controller) {
                              return Icon(
                                Icons.refresh_outlined,
                                color: myColor,
                                size: isLandscape
                                  ? size.width * 0.03
                                  : size.width * 0.03,
                              );
                            },
                          ),
                          onRefresh: () async {
                            isFirstLoadRunning = false;
                            hasNextPage = true;
                            isLoadMoreRunning = false;
                            items = [];
                            page = 1;
                            _selectedStatus = null;
                            fistLoad();
                            controller = ScrollController()..addListener(loadMore);
                            return setState(() {});
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isFirstLoadRunning)
                                SizedBox(height: size.height * 0.005),
                              if (!isFirstLoadRunning)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.05), 
                                        borderRadius: BorderRadius.circular(20), 
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _datePicker();
                                        },
                                        icon: Row(
                                          mainAxisSize: MainAxisSize.min, 
                                          children: [
                                            Icon(Icons.date_range_outlined, size: isLandscape
                                              ? size.width * 0.03
                                              : size.width * 0.04),
                                            SizedBox(width: isLandscape
                                              ? size.width * 0.01
                                              : size.width * 0.01),
                                            Text(now, style: TextStyle(fontSize: isLandscape
                                              ? size.width * 0.015
                                              : size.width * 0.020)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (isFirstLoadRunning)
                                const Center()
                              else
                                Expanded(
                                  child: filteredItems.isEmpty
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
                                            Text(
                                              'No hay registros',
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
                                    : ListView.builder(
                                      controller: controller,
                                      itemCount: filteredItems.length +
                                          (isLoadMoreRunning ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == items.length) {
                                          return const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  color: myColor),
                                            ),
                                          );
                                        }
                  
                                        final item = filteredItems[index];
                                        return InkWell(
                                          onTap: () async{
                                            Navigator.of(context).pushReplacementNamed(
                                              EvidenciaScreen.routeName,
                                              arguments: {
                                                'idapp': widget.idapp,
                                                'directory': item['VIN'].toString() == "null" || item['VIN'].toString() == ""
                                                  ? 'externo' 
                                                  : item['VIN'].toString(),
                                                'pathImages': item['evidencia_externo'],
                                              },
                                            );
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              side: const BorderSide(
                                                color: Colors.orangeAccent, // Color del borde
                                                width: 0.2,
                                              ),
                                            ),
                                            elevation: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () async{
                                                      //await _descripcion(item['VIN'] ?? "", item['fk_matricula'] ?? "");
                                                    },
                                                    child: Container(
                                                      width: size.width * 0.12, // mismo diámetro que CircleAvatar
                                                      height: size.width * 0.12,
                                                      decoration: BoxDecoration(
                                                        color: item['fecha_entrada'] != null 
                                                                ? Colors.green.withOpacity(0.2)
                                                                : item['fecha_salida'] != null 
                                                                  ? Colors.orange.withOpacity(0.2)
                                                                  : Colors.blueAccent.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons.list_alt,
                                                        size: isLandscape
                                                          ? size.width * 0.04
                                                          : size.width * 0.05,
                                                        color: item['fecha_entrada'] != null 
                                                                ? Colors.green
                                                                : item['fecha_salida'] != null 
                                                                  ? Colors.orange
                                                                  : Colors.blueAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                item['fk_matricula'] != null && item['fk_matricula'].toString().isNotEmpty
                                                                    ? "Matricula: ${item['fk_matricula']}"
                                                                    : "Externo",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: isLandscape 
                                                                    ? size.width * 0.02
                                                                    : size.width * 0.025),
                                                                overflow: TextOverflow.ellipsis, 
                                                                maxLines: 1,
                                                              ),
                                                              Text(
                                                                item['VIN'] != null && item['VIN'].toString().isNotEmpty
                                                                    ? "${item['VIN']}"
                                                                    : "${item['empresa_externo']} / ${item['nombre']}",
                                                                style: TextStyle(
                                                                  fontSize: isLandscape 
                                                                    ? size.width * 0.015
                                                                    : size.width * 0.020,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                                overflow: TextOverflow.ellipsis, 
                                                                maxLines: 1,
                                                              ),
                                                              Text(
                                                                item['fecha_entrada'] != null 
                                                                ? "Entrada: ${item['fecha_entrada'].toString().substring(0,item['fecha_entrada'].toString().length - 7) }"
                                                                : item['fecha_salida'] != null 
                                                                  ? "Salida: ${item['fecha_salida'].toString().substring(0,item['fecha_salida'].toString().length - 7) }"
                                                                  : "Entrada-Salida:\n${item['fecha'].toString().substring(0,item['fecha'].toString().length - 7) }",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: isLandscape 
                                                                      ? size.width * 0.015
                                                                      : size.width * 0.020),
                                                              ),
                                                              Text(
                                                                item['distribuidor'] != null && item['distribuidor'].toString().isNotEmpty
                                                                    ? "Distribuidor: ${item['distribuidor']}"
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontSize: item['distribuidor'] != null && item['distribuidor'].toString().isNotEmpty
                                                                    ? isLandscape
                                                                      ? size.width * 0.0115
                                                                      : size.width * 0.02
                                                                    : 0),
                                                              ),
                                                              Text(
                                                                item['modelo_unidad'] != null && item['modelo_unidad'].toString().isNotEmpty
                                                                    ? "Modelo Unidad: ${item['modelo_unidad']}"
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontSize: item['distribuidor'] != null && item['distribuidor'].toString().isNotEmpty
                                                                    ? isLandscape
                                                                      ? size.width * 0.0115
                                                                      : size.width * 0.02
                                                                    : 0),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(right: size.width * 0.01),
                                                            child: Row(
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(Icons.delete, 
                                                                    size: isLandscape
                                                                      ? size.width * 0.03
                                                                      : size.width * 0.04),
                                                                  onPressed: () {
                                                                    _eliminar(context, item['id_registro']);
                                                                  },
                                                                  color: Colors.redAccent,
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Icon(
                                                                  Icons.arrow_forward_ios_outlined,
                                                                  size: isLandscape
                                                                    ? size.width * 0.03
                                                                    : size.width * 0.04,
                                                                  color: item['fecha_entrada'] != null 
                                                                    ? Colors.green
                                                                    : item['fecha_salida'] != null 
                                                                      ? Colors.orange
                                                                      : Colors.blueAccent,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
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

  Future<bool> onWillPop2(Size size, var isLandscape) async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Descargar', style: TextStyle(fontSize: isLandscape
          ? size.width * 0.03
          : size.width * 0.04)),
        content: Text('¿Deseas descargar el Reporte?', style: TextStyle(fontSize: isLandscape
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
            onPressed: () async {
              Navigator.of(context).pop(false);
              getExcel();
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

  Future<String> getExcel() async {
    var url = "$https://$host/app/bitacora/getExcel.php?fecha_inicio=$inicio&fecha_final=$fin";
    log(url);
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    return '';
  }

  // Future<bool> _descripcion(String locatario, String descripcion) async {
  //   final Size size = MediaQuery.of(context).size;
  //   final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
  //   return (await showDialog(
  //     barrierDismissible: true,
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(locatario, textAlign: TextAlign.center),
  //       content: SingleChildScrollView(child: HtmlWidget(descripcion, textStyle: const TextStyle(fontSize: 15))),
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(32.0))),
  //       actions: <Widget>[
  //         SizedBox(height: size.height * 0.02),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             FilledButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(false);
  //               },
  //               style: FilledButton.styleFrom(
  //                 backgroundColor: Colors.orangeAccent, 
  //               ),
  //               child: const Text('Cerrar'),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   )) ??
  //   false;
  // }

  Future<bool> _eliminar(context, String idRegistro) async {
    final parentContext = context;
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return (await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar", textAlign: TextAlign.center, style: TextStyle(fontSize: isLandscape
          ? size.width * 0.03
          : size.width * 0.04)),
        content: SingleChildScrollView(child: HtmlWidget("¿Desea eliminar el registro?", textStyle: TextStyle(fontSize: isLandscape
          ? size.width * 0.02
          : size.width * 0.03))),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          SizedBox(height: size.height * 0.02),
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
            onPressed: () async{
              Navigator.of(context).pop(true); 
              await _eliminacion(parentContext, idRegistro);
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

  _datePicker() async {
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    var dayTextStyle =
        TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.w700,
          fontSize: isLandscape 
            ? size.width * 0.02
            : size.width * 0.025);
    var weekendTextStyle =
        TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: isLandscape 
          ? size.width * 0.02
          : size.width * 0.025);
    var anniversaryTextStyle = TextStyle(
      color: Colors.red[400],
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      fontSize: isLandscape 
        ? size.width * 0.02
        : size.width * 0.025
    );
    final config = CalendarDatePicker2WithActionButtonsConfig(
      dayTextStyle: dayTextStyle,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: myColor,
      closeDialogOnCancelTapped: true,
      firstDayOfWeek: 1,
      weekdayLabelTextStyle: TextStyle(
        color: myColor,
        fontWeight: FontWeight.bold,
        fontSize: isLandscape
          ? size.width * 0.02
          : size.width * 0.02
      ),
      controlsTextStyle: TextStyle(
        color: myColor,
        fontSize: isLandscape
          ? size.width * 0.02
          : size.width * 0.03,
        fontWeight: FontWeight.bold,
      ),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
      dayTextStylePredicate: ({required date}) {
        TextStyle? textStyle;
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          textStyle = weekendTextStyle;
        }
        if (DateUtils.isSameDay(date, DateTime(2021, 1, 25))) {
          textStyle = anniversaryTextStyle;
        }
        return textStyle;
      },
      dayBuilder: ({
        required date,
        textStyle,
        decoration,
        isSelected,
        isDisabled,
        isToday,
      }) {
        Widget? dayWidget;
        if (date.day % 3 == 0 && date.day % 9 != 0) {
          dayWidget = Container(
            decoration: decoration,
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Text(
                    MaterialLocalizations.of(context).formatDecimal(date.day),
                    style: textStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 27.5),
                    child: Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isSelected == true
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return dayWidget;
      },
      yearBuilder: ({
        required year,
        decoration,
        isCurrentYear,
        isDisabled,
        isSelected,
        textStyle,
      }) {
        return Center(
          child: Container(
            decoration: decoration,
            height: 36,
            width: 72,
            child: Center(
              child: Semantics(
                selected: isSelected,
                button: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: textStyle?.copyWith(fontSize: isLandscape 
                        ? size.width * 0.1
                        : size.width * 0.01),
                    ),
                    if (isCurrentYear == true)
                      Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(left: 5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: Size(
        isLandscape
          ? size.width * 0.6
          : size.width * 0.6, 
        isLandscape
        ? size.width * 0.35
        : size.width * 0.6),
      borderRadius: BorderRadius.circular(15),
      value: _dialogCalendarPickerValue,
      dialogBackgroundColor: Colors.white,
    );
    if (values != null) {
      //log(_getValueText(config.calendarType, values));
      //log(_getValueText2(config.calendarType, values));
      inicio = _getValueText(config.calendarType, values);
      fin = _getValueText2(config.calendarType, values);
      setState(() {
        if(inicio == "null" && fin == "null"){
          now = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }else if(inicio == "null"){
          now = fin;
        }else if(fin == "null"){
          now = inicio;
        }else{
          now = "${inicio}al $fin";
        }
        _dialogCalendarPickerValue = values;
        //_getExcel(inicio, fin);
      });
      _selectedStatus = null;
      fistLoad();
    }
  }

  String _getValueText(
    CalendarDatePicker2Type datePickerType,
    List<DateTime?> values,
  ) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        // final endDate = values.length > 1
        //     ? values[1].toString().replaceAll('00:00:00.000', '')
        //     : 'null';
        // valueText = '$startDate to $endDate';
        valueText = startDate;
      } else {
        return 'null';
      }
    }
    return valueText;
  }

  String _getValueText2(
    CalendarDatePicker2Type datePickerType,
    List<DateTime?> values,
  ) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        // final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1
            ? values[1].toString().replaceAll('00:00:00.000', '')
            : 'null';
        valueText = endDate;
      } else {
        return 'null';
      }
    }
    return valueText;
  }

  // Eliminacion
  Future<void> _eliminacion(context, idRegistro) async {
    EasyLoading.show(
      status: 'Eliminando...',
      maskType: EasyLoadingMaskType.black,
    );

    if (!await verificarConexion()) {
      EasyLoading.dismiss();
      onError2(context, "Verificar conexión a Internet");
      return;
    }

    final Map<String, dynamic> datosASincronizar = {
      'id_registro': idRegistro,
      'es': '0'
    };
    
    //log('Datos a sincronizar:\n${const JsonEncoder.withIndent('  ').convert(datosASincronizar)}');

    final response = await http.post(
      Uri.parse('https://trasladosuniversales.com.mx/app/bitacora/editRegistro.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datosASincronizar),
    );

    if (response.statusCode == 200) {
      //log('Respuesta: ${response.body}');
      EasyLoading.dismiss();
      success(context, "Registro eliminado");
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(
        HistorialScreen.routeName,
        arguments: {
          'idapp': widget.idapp,
        },
      );
    } else {
      EasyLoading.dismiss();
      onError2(context, "Verificar conexión a Internet");
      return;
    }
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

  void success(context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.all(8.0),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onError2(BuildContext context, String messageError) {
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
                    fontSize: 18,
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

}