import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/main.dart';
import 'package:tusabitacoraapp/models/usuario.dart';
import 'package:tusabitacoraapp/presentation/screens/entradas_salidas/edit_entradas_salidas_screen.dart';
import '../../../constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/side_menu.dart';
import '../home/home_screen.dart';

class PatioScreen extends StatefulWidget {
  static const String routeName = 'patio';

  final String idapp;

  const PatioScreen({
    Key? key,
    required this.idapp,
  }) : super(key: key);

  @override
  State<PatioScreen> createState() => _PatioScreenState();
}

class _PatioScreenState extends State<PatioScreen> with SingleTickerProviderStateMixin {
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
            path: '/app/bitacora/getRegistrosPatio.php',
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
            path: '/app/bitacora/getRegistrosPatio.php',
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
            path: '/app/bitacora/getRegistrosPatio.php',
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
            path: '/app/bitacora/getRegistrosPatio.php',
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
        onError("Verificar conexión a Internet");
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

  // void filterItems(String query) {
  //   final normalizedQuery = removeDiacritics(query);
  //   setState(() {
  //     if (query.isEmpty) {
  //       filteredItems = List.from(items); // Restaura todos los elementos
  //     } else {
  //       filteredItems = items.where((item) {
  //         final solicitante = removeDiacritics(item['solicitante'] ?? '');
  //         final local =
  //             removeDiacritics(item['local'] ?? '');
  //         return solicitante.contains(normalizedQuery) ||
  //             local.contains(normalizedQuery);
  //       }).toList();
  //     }
  //   });
  // }

  void filterItems(String query) {
    final normalizedQuery = removeDiacritics(query);
    setState(() {
      filteredItems = items.where((item) {
        final fk_matricula = removeDiacritics(item['fk_matricula'] ?? '');
        final VIN = removeDiacritics(item['VIN'] ?? '');
        final nombre = removeDiacritics(item['nombre'] ?? '');
        final statusMatch = _selectedStatus == null || item['estado'] == _selectedStatus;
        
        return (fk_matricula.contains(normalizedQuery) ||
                VIN.contains(normalizedQuery) || nombre.contains(normalizedQuery)) && statusMatch;
      }).toList();
    });
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

  @override
  void initState() {
    super.initState();
    fistLoad();
    controller = ScrollController()..addListener(loadMore);
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
                screenName: "patio",
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
                        : Text(namePatio, style: TextStyle(color: Colors.white, fontSize: size.width * 0.04)),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.01, vertical: size.width * 0.01),
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
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.025),
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
                                            // log(item['id_registro']);
                                            
                                            Navigator.of(context).pushReplacementNamed(
                                              EditEntradasSalidasScreen.routeName,
                                              arguments: {
                                                'idapp': widget.idapp,
                                                'id_registro': item['id_registro'],
                                              },
                                            );

                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              side: const BorderSide(
                                                color: Colors.green, // Color del borde
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
                                                        color: Colors.greenAccent,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons.local_shipping,
                                                        size: isLandscape
                                                          ? size.width * 0.04
                                                          : size.width * 0.05,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),
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
                                                                item['fila'] != null && item['fila'].toString().isNotEmpty
                                                                    ? "Fila: ${item['fila']}"
                                                                    : "",
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
                                                                    fontSize: isLandscape
                                                                      ? size.width * 0.0115
                                                                      : size.width * 0.02),
                                                              ),
                                                              Text(
                                                                item['modelo_unidad'] != null && item['modelo_unidad'].toString().isNotEmpty
                                                                    ? "Modelo Unidad: ${item['modelo_unidad']}"
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontSize: isLandscape
                                                                      ? size.width * 0.0115
                                                                      : size.width * 0.02),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(right: size.width * 0.01),
                                                            child: Icon(
                                                              Icons.arrow_forward_ios_outlined,
                                                              size: isLandscape
                                                                ? size.width * 0.03
                                                                : size.width * 0.04,
                                                              color: Colors.green.withOpacity(0.5),
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

  Future<void> showResultDialog(BuildContext context, String result) async {  
    if (result == 'Error, verificar conexión a Internet') {
        HapticFeedback.heavyImpact();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent, 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Icon(
                    Icons.error,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 10,
            duration: const Duration(seconds: 3),
          ),
        );
    } else {
      HapticFeedback.heavyImpact();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Autorizacion
  Future<String> _autorizacion(idUsuario, solicitudId) async {
    try {
      var data = {
        "usuario_id": idUsuario, 
      };

      final response = await http.post(Uri(
        scheme: https,
        host: host,
        path: "/solicitud/app/cambioStatus/$solicitudId",
      ), 
      body: data
      );

      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['response'] == true) {
          return 'Solicitud Autorizada exitosamente';
        } else {
          return 'Error, verificar conexión a Internet';
        }
      } else {
        return 'Error, verificar conexión a Internet';
      }
    } catch (e) {
      return 'Error, verificar conexión a Internet';
    }
  }

  showProgressAutorizada(BuildContext context, String idUsuario, String solicitudId) async {

    EasyLoading.show(
      status: 'Autorizando...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    var result = await _autorizacion(idUsuario, solicitudId);
    // log(result);

    EasyLoading.dismiss();
    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

  // Denegación
  Future<String> _denegacion(idUsuario, solicitudId, motivo) async {
    try {
      var data = {
        "usuario_id" : idUsuario, 
        "motivo" : motivo
      };

      final response = await http.post(Uri(
        scheme: https,
        host: host,
        path: "/solicitud/app/cambioStatus/$solicitudId",
      ), 
      body: data
      );

      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['response'] == true) {
          return 'Solicitud Denegada exitosamente';
        } else {
          return 'Error, verificar conexión a Internet';
        }
      } else {
        return 'Error, verificar conexión a Internet';
      }
    } catch (e) {
      return 'Error, verificar conexión a Internet';
    }
  }

  showProgressDenegada(BuildContext context, String idUsuario, String solicitudId, String motivo) async {

    EasyLoading.show(
      status: 'Denegando...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    var result = await _denegacion(idUsuario, solicitudId, motivo);
    // log(result);

    EasyLoading.dismiss();
    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

}