import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:tusabitacoraapp/config/helper/database_helper.dart';
import 'package:tusabitacoraapp/config/navigation/route_observer.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/main.dart';
import 'package:tusabitacoraapp/models/registro.dart';
import 'package:tusabitacoraapp/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:tusabitacoraapp/presentation/screens/home/home_screen.dart';
import 'package:tusabitacoraapp/presentation/widgets/side_menu.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:path/path.dart' as path;

class EntradasSalidasScreen extends StatefulWidget {
  static const String routeName = 'entradasSalidas';

  final String idapp;

  const EntradasSalidasScreen({
    Key? key,
    required this.idapp,
  }) : super(key: key);

  @override
  State<EntradasSalidasScreen> createState() => _EntradasSalidasScreenState();
}

class _EntradasSalidasScreenState extends State<EntradasSalidasScreen>
    with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;
  String? _apellidos;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;

  List items = [];
  late ScrollController controller;

  // variables formulario
  int tipoRegistro = 0;
  // hora registro
  DateTime? dateTime = DateTime.now();
  // vin
  String? vin;
  late TextEditingController _vinController;
  // Modelo unidad
  // final List<String> itemsModelo = [
  //   'Modelo 1',
  //   'Modelo 2',
  //   'Modelo 3',
  //   'Modelo 4',
  //   'Modelo 5',
  //   'Modelo 6',
  //   'Modelo 7',
  // ];
  String? modelo;
  // llave
  late TextEditingController _modeloController;
  late TextEditingController _llaveController;
  late TextEditingController _distribuidorController;
  late TextEditingController _ejesController;
  late TextEditingController _origenController;
  String? llave;
  // distribuidor
  // final List<String> itemsDistribuidor = [
  //   'Distribuidor 1',
  //   'Distribuidor 2',
  //   'Distribuidor 3',
  //   'Distribuidor 4',
  //   'Distribuidor 5',
  //   'Distribuidor 6',
  //   'Distribuidor 7',
  // ];
  String? distribuidor;
  // num ejes
  // final List<String> itemsEjes = [
  //   '1',
  //   '2',
  //   '3',
  //   '4',
  //   '5',
  //   '6',
  //   '7',
  // ];
  String? ejes;
  // origen
  // final List<String> itemsOrigenes = [
  //   'Origen 1',
  //   'Origen 2',
  //   'Origen 3',
  //   'Origen 4',
  //   'Origen 5',
  //   'Origen 6',
  //   'Origen 7',
  // ];
  String? origen;
  // modelo tanque izq
  final List<String> itemsModeloTanqueIzq = [
    'Seleccione un modelo',
    'Cilindrico',
    'Tipo D',
  ];
  String? modeloTanqueIzq='';
  String? modeloTanqueIzqPrint='';
  
  bool showCmTanqueIzq = false;
  final List<String> itemsCMTanqueIzq = [
    'Seleccione Centimetros',
    '1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5','11','11.5','12','12.5','13','13.5','14','14.5','15','15.5','16',
    '16.5','17','17.5','18','18.5','19','19.5','20','20.5','21','21.5','22','22.5','23','23.5','24','24.5','25','25.5','26','26.5','27','27.5','28','28.5','29','29.5','30','30.5','31','31.5',
    '32','32.5','33',
  ];
  String? CMTanqueIzq='';
  String? CMTanqueIzqPrint='';

  // modelo tanque der
  final List<String> itemsModeloTanqueDer = [
    'Seleccione un modelo',
    'Cilindrico',
    'Tipo D',
  ];
  String? modeloTanqueDer;
  String? modeloTanqueDerPrint='';

  bool showCmTanqueDer = false;
  final List<String> itemsCMTanqueDer = [
    'Seleccione Centimetros',
    '1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5','11','11.5','12','12.5','13','13.5','14','14.5','15','15.5','16',
    '16.5','17','17.5','18','18.5','19','19.5','20','20.5','21','21.5','22','22.5','23','23.5','24','24.5','25','25.5','26','26.5','27','27.5','28','28.5','29','29.5','30','30.5','31','31.5',
    '32','32.5','33',
  ];
  String? CMTanqueDer='';
  String? CMTanqueDerPrint='';

  // Tipo tanque urea
  final List<String> itemsTipoTanque = [
    '26 L',
    '61 L',
    '87 L',
  ];
  String? tipoTanque;
  String? tipoTanquePrint;
  // Nivel de urea
  final List<String> itemsNivel = [
    'Menos de 1/4',
    '1/4',
    '1/2',
    '3/4',
    'Mas de 3/4',
  ];
  String? nivel;
  String? nivelPrint;
  // equipamiento
  List<String> itemsEquipamiento = [
    "Gato",
    "Reflejantes",
    "Llave & Barra",
    "Extintores",
    "Estereo",
    "Llanta/Rin",
    "Encendedor",
    "Cenicero",
    "Antena",
  ];
  Map<String, bool> checkboxes = {
    "Gato" : false,
    "Reflejantes" : false,
    "Llave & Barra" : false,
    "Extintores" : false,
    "Estereo" : false,
    "Llanta/Rin" : false,
    "Encendedor" : false,
    "Cenicero" : false,
    "Antena" : false
  };
  late TextEditingController _equipamientoController;
  // matricula Operador
  late TextEditingController _matriculaController;
  String? matricula;
  bool _esExterno = false;
  // nombre operador o externo
  late TextEditingController _nombreController;
  String? nombre;
  // empresa
  late TextEditingController _empresaController;
  String? empresa;
  // evidencia
  List<String> imagePaths = [];
  List<String> evidencia = [];
  // guardia
  late TextEditingController _guardiaController;
  String? guardia;
  // evidencias
  bool _evidencias = false;
  List<String> imagePathsEvidencias = [];
  // Fila
  final List<String> itemsFila = [
    'A',
    'B',
    'C',
    'D',
  ];
  String? fila="A";
  // Firma
  final SignatureController _firmaController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  List<String> imagePathsFirma = [];

  List<Widget> _pages(context, size, isLandscape){
    return [
      // Página 1 
      SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // tipo registro
                  Text("Tipo de registro: ", textAlign: TextAlign.start, style: TextStyle(color: myColor, fontSize: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.03)),
                  SizedBox(height: size.width * 0.01),
                  ToggleSwitch(
                    minWidth: double.infinity,
                    minHeight: isLandscape
                      ? size.width * 0.04
                      : size.width * 0.05,
                    iconSize: isLandscape
                      ? size.width * 0.04
                      : size.width * 0.05,
                    fontSize: isLandscape
                      ? size.width * 0.02
                      : size.width * 0.03,
                    initialLabelIndex: tipoRegistro,
                    cornerRadius: 20.0,
                    multiLineText: true,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 3,
                    labels: const ['Entrada', 'Entrada Salida', 'Salida'],
                    icons: const [Icons.arrow_upward, Icons.compare_arrows, Icons.arrow_downward],
                    activeBgColors: const [[Colors.green], [Colors.blueAccent], [Colors.orange]],
                    onToggle: (index) {
                      // log('switched to: $index');
                      tipoRegistro=index!;
                    },
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Hora de registro
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Hora de registro: ", textAlign: TextAlign.start, style: TextStyle(color: myColor, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03)),
                      // AbsorbPointer(
                      //   child: 
                        Container(
                          width: isLandscape
                          ? size.width * 0.3
                          : size.width * 0.4,
                          height: isLandscape
                          ? size.width * 0.04
                          : size.width * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: CupertinoCalendarPickerButton(
                            mainColor: myColor,
                            minimumDateTime: DateTime(dateTime!.year, dateTime!.month - 1, dateTime!.day, dateTime!.hour, dateTime!.minute),
                            maximumDateTime: DateTime(dateTime!.year, dateTime!.month + 1, dateTime!.day, dateTime!.hour, dateTime!.minute),
                            initialDateTime: DateTime(dateTime!.year, dateTime!.month, dateTime!.day, dateTime!.hour, dateTime!.minute),
                            currentDateTime: DateTime(dateTime!.year, dateTime!.month, dateTime!.day, dateTime!.hour, dateTime!.minute),
                            use24hFormat: false,
                            mode: CupertinoCalendarMode.dateTime,
                            timeLabel: 'Hora: ',
                            onDateTimeChanged: (date) {
                              //log(date.toString());
                              dateTime = date;
                            },
                          ),
                        ),
                      //  ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.03
                    : size.width * 0.04),
                  // VIN
                  Row(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                            child: TextField(
                              controller: _vinController,
                              enabled: !_esExterno,
                              keyboardType: TextInputType.text,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  //vin = 'OT-$valor';
                                  vin = valor;
                                });
                              },
                              onSubmitted: (value) {
                                if (!value.toLowerCase().startsWith("ot-")) {
                                  final nuevoValor = "OT-${value.replaceFirst(RegExp(r'ot-', caseSensitive: false), '')}";
                                  _vinController.text = nuevoValor;
                                  _vinController.selection = TextSelection.collapsed(offset: nuevoValor.length);
                                  setState(() {
                                    vin = nuevoValor;
                                  });
                                  cargaVIN(context, value);
                                } else {
                                  setState(() {
                                    vin = value;
                                  });
                                  cargaVIN(context, value);
                                }
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "VIN",
                                hintStyle: TextStyle(fontSize: isLandscape 
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "VIN",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape 
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      // VIN scanner
                      IntrinsicWidth(
                        child: ElevatedButton(
                          onPressed: 
                          _esExterno
                          ? null
                          : () async{
                            final result = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => AiBarcodeScanner(
                                  onDispose: () {
                                    //log("QR scanner disposed!");
                                  },
                                  hideGalleryButton: true,
                                  hideSheetTitle: true,
                                  sheetTitle: "¡Listo, Escanea QR!",
                                  hideSheetDragHandler: true,
                                  controller: MobileScannerController(
                                    detectionSpeed: DetectionSpeed.noDuplicates,
                                  ),
                                  onDetect: (BarcodeCapture capture) {
                                    final String? scannedValue = capture.barcodes.first.rawValue;
                                    //log("QR scanned: $scannedValue");
                                    // _vinController.text = scannedValue!;
                                    // vin = scannedValue;
                                    // cargaVIN(context, scannedValue);
                                    // Navigator.of(context).pop();

                                    if (!scannedValue!.toLowerCase().startsWith("ot-")) {
                                      final nuevoValor = "OT-${scannedValue.replaceFirst(RegExp(r'ot-', caseSensitive: false), '')}";
                                      _vinController.text = nuevoValor;
                                      _vinController.selection = TextSelection.collapsed(offset: nuevoValor.length);
                                      setState(() {
                                        vin = nuevoValor;
                                      });
                                      cargaVIN(context, nuevoValor);
                                      Navigator.of(context).pop();
                                    } else {
                                      setState(() {
                                        vin = scannedValue;
                                        _vinController.text = scannedValue;
                                      });
                                      cargaVIN(context, scannedValue);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  validator: (value) {
                                    if (value.barcodes.isEmpty) {
                                      return false;
                                    }
                                    if (!(value.barcodes.first.rawValue?.contains('flutter.dev') ?? false)) {
                                      return false;
                                    }
                                    return true;
                                  },
                                ),
                              ),
                            );
                        
                            if (result != null) {
                              setState(() {
                                _vinController.text = result;
                              });
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: isLandscape
                                ? size.width * 0.015
                                : size.width * 0.020),
                              Icon(Icons.qr_code_scanner, size: isLandscape
                                ? size.width * 0.03
                                : size.width * 0.05),
                              SizedBox(height: isLandscape
                                ? size.width * 0.015
                                : size.width * 0.020),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Matricula Operador
                  Row(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                            child: TextField(
                              enabled: !_esExterno,
                              controller: _matriculaController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  matricula = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Matrícula",
                                hintStyle: TextStyle(fontSize: isLandscape 
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Matrícula del operador",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape 
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _esExterno = !_esExterno; 
                            _matriculaController.text = "";
                            _empresaController.text = "";
                          });
                        },
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: isLandscape ? 1.8 : 1.2,
                              child: Checkbox(
                                value: _esExterno,
                                onChanged: (valor) {
                                  setState(() {
                                    _esExterno = valor!;
                                    _matriculaController.text = "";
                                    matricula="";
                                    _vinController.text = "";
                                    vin = "";
                                    _nombreController.text = "";
                                    _empresaController.text = "";
                                    empresa="";
                                    _modeloController.text = "";
                                    _llaveController.text = "";
                                    _distribuidorController.text = "";
                                    _ejesController.text = "";
                                    _origenController.text = "";
                                    modeloTanqueIzq = "Seleccione un modelo";
                                    modeloTanqueIzqPrint = "";
                                    showCmTanqueIzq = false;
                                    CMTanqueIzq = "Seleccione Centimetros";
                                    CMTanqueIzqPrint = "";
                                    showCmTanqueDer = false;
                                    modeloTanqueDer = "Seleccione un modelo";
                                    modeloTanqueDerPrint = "";
                                    CMTanqueDer = "Seleccione Centimetros";
                                    CMTanqueDerPrint = "";
                                    tipoTanque = "26 L";
                                    tipoTanquePrint = "";
                                    nivel = "Menos de 1/4";
                                    nivelPrint = "";
                                    checkboxes = {
                                      "Gato" : false,
                                      "Reflejantes" : false,
                                      "Llave & Barra" : false,
                                      "Extintores" : false,
                                      "Estereo" : false,
                                      "Llanta/Rin" : false,
                                      "Encendedor" : false,
                                      "Cenicero" : false,
                                      "Antena" : false
                                    };
                                    _equipamientoController.text = "";
                                    fila = "A";
                                    _firmaController.clear();
                                    imagePaths = [];
                                    imagePathsEvidencias = [];
                                  });
                                },
                              ),
                            ),
                            Text("Externo", style: TextStyle(color: myColor, fontSize: isLandscape
                              ? size.width * 0.020
                              : size.width * 0.025)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Nombre externo u Operador
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.15,
                        child: Text("Nombre: ", style: TextStyle(color: myColor, fontSize: isLandscape
                          ? size.width * 0.02
                          : size.width * 0.03)),
                      ),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              //enabled: _esExterno,
                              controller: _nombreController,
                              keyboardType: TextInputType.text,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  nombre = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Nombre",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Nombre",
                                labelStyle: TextStyle(color: Colors.black87, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Empresa externo
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.15,
                        child: Text("Empresa: ", style: TextStyle(color: _esExterno ? myColor : Colors.grey, fontSize: isLandscape
                          ? size.width * 0.02
                          : size.width * 0.03)),
                      ),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              enabled: _esExterno,
                              controller: _empresaController,
                              keyboardType: TextInputType.text,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  empresa = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Empresa",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Empresa",
                                labelStyle: TextStyle(color: _esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Evidencia
                  Row(
                    children: [
                      Text("Evidencia: (foto de credencial)", style: TextStyle(color: _esExterno ? myColor : Colors.grey, fontSize: isLandscape
                          ? size.width * 0.02
                          : size.width * 0.03)),
                      SizedBox(height: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.04),
                      // foto evidencia
                      IntrinsicWidth(
                        child: ElevatedButton(
                          onPressed: 
                          _esExterno 
                          ? () async{
                              handleImage();
                            }
                          : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: isLandscape
                                ? size.width * 0.015
                                : size.width * 0.020),
                              Icon(Icons.photo_camera, size: isLandscape
                                ? size.width * 0.03
                                : size.width * 0.05),
                              SizedBox(height: isLandscape
                                ? size.width * 0.015
                                : size.width * 0.020),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // ImageSlideshow
                  if (imagePaths.isNotEmpty && _esExterno)
                    Container(
                      color: Colors.black12,
                      child: ImageSlideshow(
                        width: double.infinity,
                        height: isLandscape
                          ? size.width * 0.2
                          : size.width * 0.35,
                        initialPage: 0,
                        indicatorColor: Colors.blueAccent,
                        indicatorBackgroundColor: Colors.white,
                        onPageChanged: (value) {},
                        autoPlayInterval: 0,
                        isLoop: false,
                        indicatorRadius: 5,
                        indicatorPadding: 7,
                        disableUserScrolling: false,
                        indicatorBottomPadding: 10,
                        children: [
                          for (String image in imagePaths)
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: isLandscape
                                      ? size.width * 0.2
                                      : size.width * 0.5,
                                    child: Image.file(
                                      File(image),
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.file(
                                          File('assets/images/icon_user.png'),
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),                  
                ],
              ),
            ),
          ),
        ),
      ),

      // Página 2 
      SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [   

                  // Modelo
                  SizedBox(height: isLandscape
                    ? size.width * 0.01
                    : size.width * 0.02),
                  Row(
                    children: [
                      Expanded(child: Text("Modelo de la Unidad: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _modeloController,
                              enabled: !_esExterno,
                              maxLines: 3,
                              minLines: 1,
                              keyboardType: TextInputType.text,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              cursorColor: myColor,
                              onChanged: (valor) {
                                setState(() {
                                  modelo = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Modelo",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Modelo",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.03
                    : size.width * 0.04),
                  /*
                  Row(
                    children: [
                      Expanded(child: Text("Modelo de la Unidad: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Modelo 1',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !_esExterno ? myColor : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsModelo
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: !_esExterno ? myColor : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: modelo,
                          onChanged: _esExterno
                          ? null
                          : (value) {
                              setState(() {
                                modelo = value;
                              });
                            },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 160,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  */
                  
                  // LLAVE
                  Row(
                    children: [
                      Expanded(child: Text("Llave: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _llaveController,
                              enabled: !_esExterno,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  llave = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Últ. 4 dígitos",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Llave",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.03
                    : size.width * 0.04),

                  // Distribuidor
                  Row(
                    children: [
                      Expanded(child: Text("Distribuidor: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _distribuidorController,
                              enabled: !_esExterno,
                              maxLines: 3,
                              minLines: 1,
                              keyboardType: TextInputType.text,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              cursorColor: myColor,
                              onChanged: (valor) {
                                setState(() {
                                  distribuidor = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Distribuidor",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Distribuidor",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.03
                    : size.width * 0.04),
                  /*
                  Row(
                    children: [
                      Expanded(child: Text("Distribuidor: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Distribuidor 1',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !_esExterno ? myColor : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsDistribuidor
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: !_esExterno ? myColor : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: distribuidor,
                          onChanged: 
                          _esExterno
                            ? null
                            : (value) {
                              setState(() {
                                distribuidor = value;
                              });
                            },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 160,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  */

                  // Núm. ejes
                  Row(
                    children: [
                      Expanded(child: Text("Núm. de Ejes: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _ejesController,
                              enabled: !_esExterno,
                              maxLines: 3,
                              minLines: 1,
                              keyboardType: TextInputType.text,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              cursorColor: myColor,
                              onChanged: (valor) {
                                setState(() {
                                  ejes = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Ejes",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Ejes",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.03
                    : size.width * 0.04),
                  /*
                  Row(
                    children: [
                      Expanded(child: Text("Núm. ejes: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '1',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !_esExterno ? myColor : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsEjes
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: !_esExterno ? myColor : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: ejes,
                          onChanged: _esExterno
                            ? null
                            : (value) {
                              setState(() {
                                ejes = value;
                              });
                            },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 160,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  */

                  // Origen de la unidad
                  Row(
                    children: [
                      Expanded(child: Text("Origen de la Unidad: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _origenController,
                              enabled: !_esExterno,
                              maxLines: 3,
                              minLines: 1,
                              keyboardType: TextInputType.text,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              cursorColor: myColor,
                              onChanged: (valor) {
                                setState(() {
                                  origen = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Origen",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Origen",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.03
                    : size.width * 0.04),
                  /*
                  Row(
                    children: [
                      Expanded(child: Text("Origen de la Unidad: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Origen 1',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !_esExterno ? myColor : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsOrigenes
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: !_esExterno ? myColor : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: origen,
                          onChanged: 
                          _esExterno
                          ? null
                          : (value) {
                            setState(() {
                              origen = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 160,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  */
                ],
              ),
            ),
          ),
        ),
      ),

      // Pagina 3
      SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Modelo Tanque izq
                  Row(
                    children: [
                      Expanded(child: Text("Modelo Tanque Izquierdo: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Seleccione un modelo',
                                  //textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: !_esExterno ? myColor : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsModeloTanqueIzq
                            .where((item) => item != 'Seleccione un modelo')
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: isLandscape
                                        ? size.width * 0.02
                                        : size.width * 0.03,
                                      //fontWeight: FontWeight.bold,
                                      color: !_esExterno ? myColor : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                          value: modeloTanqueIzq!.isNotEmpty && modeloTanqueIzq != 'Seleccione un modelo'
                            ? modeloTanqueIzq
                            : null,
                          onChanged: _esExterno
                          ? null
                          : (value) {
                            setState(() {
                              modeloTanqueIzq = value;
                              if(value!='Seleccione un modelo'){
                                showCmTanqueIzq = true;
                              }else{
                                showCmTanqueIzq = false;
                                //_cmTanqueIzqController.text="";
                              }
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03,
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // CM Tanque izq
                  Row(
                    children: [
                      Expanded(child: Text("Centímetros Tanque Izquierdo: ", style: TextStyle(color: showCmTanqueIzq ? !_esExterno ? myColor : Colors.grey : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Seleccione Centimetros',
                                  //textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.019
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: showCmTanqueIzq ? !_esExterno ? myColor : Colors.grey : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          items: itemsCMTanqueIzq
                            .where((item) => item != 'Seleccione Centimetros')
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: isLandscape
                                        ? size.width * 0.02
                                        : size.width * 0.03,
                                      //fontWeight: FontWeight.bold,
                                      color: showCmTanqueIzq ? !_esExterno ? myColor : Colors.grey : Colors.grey
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                          value: CMTanqueIzq!.isNotEmpty && CMTanqueIzq != 'Seleccione Centimetros'
                            ? CMTanqueIzq
                            : null,
                          onChanged: _esExterno && showCmTanqueIzq || _esExterno && !showCmTanqueIzq || !_esExterno && !showCmTanqueIzq
                          ? null
                          : (value) {
                            setState(() {
                              CMTanqueIzq = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03,
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Modelo Tanque der
                  Row(
                    children: [
                      Expanded(child: Text("Modelo Tanque Derecho: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Seleccione un modelo',
                                  //textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: !_esExterno ? myColor : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsModeloTanqueDer
                            .where((item) => item != 'Seleccione un modelo')
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: isLandscape
                                        ? size.width * 0.02
                                        : size.width * 0.03,
                                      //fontWeight: FontWeight.bold,
                                      color: !_esExterno ? myColor : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                          value: modeloTanqueDer!.isNotEmpty && modeloTanqueDer != 'Seleccione un modelo'
                            ? modeloTanqueDer
                            : null,
                          onChanged: _esExterno
                          ? null
                          : (value) {
                            setState(() {
                              modeloTanqueDer = value;
                              if(value!='Seleccione un modelo'){
                                showCmTanqueDer = true;
                              }else{
                                showCmTanqueDer = false;
                                //_cmTanqueDerController.text="";
                              }
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03, 
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // CM Tanque der
                  Row(
                    children: [
                      Expanded(child: Text("Centímetros Tanque Derecho: ", style: TextStyle(color: showCmTanqueDer ? !_esExterno ? myColor : Colors.grey : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Seleccione Centimetros',
                                  //textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.019
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: showCmTanqueDer ? !_esExterno ? myColor : Colors.grey : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          items: itemsCMTanqueDer
                            .where((item) => item != 'Seleccione Centimetros')
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: isLandscape
                                        ? size.width * 0.02
                                        : size.width * 0.03,
                                      //fontWeight: FontWeight.bold,
                                      color: showCmTanqueDer ? !_esExterno ? myColor : Colors.grey : Colors.grey
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                          value: CMTanqueDer!.isNotEmpty && CMTanqueDer != 'Seleccione Centimetros'
                            ? CMTanqueDer
                            : null,
                          onChanged: _esExterno && showCmTanqueDer || _esExterno && !showCmTanqueDer || !_esExterno && !showCmTanqueDer
                          ? null
                          : (value) {
                            setState(() {
                              CMTanqueDer = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03,
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  /*Row(
                    children: [
                      Expanded(child: Text("CM Tanque Derecho: ", style: TextStyle(color: showCmTanqueDer ? !_esExterno ? myColor : Colors.grey : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              enabled: showCmTanqueDer && !_esExterno,
                              controller: _cmTanqueDerController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  cmTanqueDer = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "CM Tanque Der",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "CM Tanque Der",
                                labelStyle: TextStyle(color: showCmTanqueDer ? !_esExterno ? Colors.black87 : Colors.grey : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),*/
                    
                  // Tipo tanque
                  Row(
                    children: [
                      Expanded(child: Text("Tipo Tanque de Urea: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '26 L',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: myColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsTipoTanque
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: isLandscape
                                          ? size.width * 0.02
                                          : size.width * 0.03,
                                        //fontWeight: FontWeight.bold,
                                        color: !_esExterno ? myColor : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: tipoTanque,
                          onChanged: _esExterno
                          ? null
                          : (value) {
                              setState(() {
                                tipoTanque = value;
                              });
                            },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03, 
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                  // Nivel urea
                  Row(
                    children: [
                      Expanded(child: Text("Nivel de Urea: ", style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Menos de 1/4',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: myColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsNivel
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: isLandscape
                                          ? size.width * 0.02
                                          : size.width * 0.03,
                                        //fontWeight: FontWeight.bold,
                                        color: !_esExterno ? myColor : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: nivel,
                          onChanged: _esExterno
                          ? null
                          : (value) {
                              setState(() {
                                nivel = value;
                              });
                            },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03, 
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                        
                ],
              ),
            ),
          ),
        ),
      ),

      // Página 4
      SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Check List
                  Text("Equipamiento", style: TextStyle(
                    fontSize: isLandscape
                      ? size.width * 0.02
                      : size.width * 0.03, 
                    color: !_esExterno ? myColor : Colors.grey)),
                  Column(
                    children: itemsEquipamiento.map((item) {
                      return CheckboxListTile(
                        title: Text(item, style: TextStyle(color: !_esExterno ? myColor : Colors.grey, fontSize: isLandscape
                          ? size.width * 0.0225
                          : size.width * 0.0325)),
                        //tristate: true,
                        value: checkboxes[item] ?? false,
                        onChanged: _esExterno
                        ? null
                        : (value) {
                          setState(() {
                            checkboxes[item] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: size.width * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                            child: TextField(
                              controller: _equipamientoController,
                              enabled: !_esExterno,
                              keyboardType: TextInputType.text,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                              onSubmitted: (value) {
                                setState(() {
                                  itemsEquipamiento.add(value);
                                  checkboxes[value] = false;
                                  _equipamientoController.text="";
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Equipamiento",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "Agregar equipamiento",
                                labelStyle: TextStyle(color: !_esExterno ? Colors.black87 : Colors.grey, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ),
                      ),
                      // Boton Agregar equipamiento
                      IntrinsicWidth(
                        child: ElevatedButton(
                          onPressed: _esExterno
                          ? null
                          : () async{
                              if(_equipamientoController.text!=""){
                                setState(() {
                                  itemsEquipamiento.add(_equipamientoController.text);
                                  checkboxes[_equipamientoController.text] = false;
                                  _equipamientoController.text="";
                                });
                              }
                            },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: isLandscape
                                ? size.width * 0.015
                                : size.width * 0.020),
                              Icon(Icons.playlist_add_outlined, size: isLandscape
                                ? size.width * 0.03
                                : size.width * 0.05),
                              SizedBox(height: isLandscape
                                ? size.width * 0.015
                                : size.width * 0.020),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
      
      // pagina 5
      SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Guardia
                  Row(
                    children: [
                      Text("Guardia: ", style: TextStyle(color: myColor, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03)),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: myColor,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                            child: TextField(
                              enabled: false,
                              controller: _guardiaController,
                              keyboardType: TextInputType.text,
                              cursorColor: myColor,
                              style: TextStyle(color: myColor, 
                                fontSize: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                              onChanged: (valor) {
                                setState(() {
                                  guardia = valor;
                                });
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: "Guardia",
                                hintStyle: TextStyle(fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                                labelText: "${_userapp!} ${_apellidos!}",
                                labelStyle: TextStyle(color: myColor, fontSize: isLandscape
                                  ? size.width * 0.02
                                  : size.width * 0.03),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.width * 0.02),
                  // evidencias
                  InkWell(
                    onTap: () {
                      setState(() {
                        _evidencias = !_evidencias; 
                        imagePathsEvidencias = [];
                      });
                    },
                    child: Row(
                      children: [
                        Text("Evidencias", style: TextStyle(color: myColor, fontSize: isLandscape
                          ? size.width * 0.02
                          : size.width * 0.03)),
                        Transform.scale(
                          scale: isLandscape ? 1.8 : 1.2,
                          child: Checkbox(
                            value: _evidencias,
                            onChanged: (valor) {
                              setState(() {
                                _evidencias = !_evidencias; 
                                imagePathsEvidencias = [];
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ImageSlideshow
                  if (imagePathsEvidencias.isNotEmpty)
                    Container(
                      color: Colors.black12,
                      child: ImageSlideshow(
                        width: double.infinity,
                        height: isLandscape
                          ? size.width * 0.2
                          : size.width * 0.35,
                        initialPage: 0,
                        indicatorColor: Colors.blueAccent,
                        indicatorBackgroundColor: Colors.white,
                        onPageChanged: (value) {},
                        autoPlayInterval: 0,
                        isLoop: false,
                        indicatorRadius: 5,
                        indicatorPadding: 7,
                        disableUserScrolling: false,
                        indicatorBottomPadding: 10,
                        children: [
                          for (String image in imagePathsEvidencias)
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: isLandscape
                                      ? size.width * 0.2
                                      : size.width * 0.5,
                                    child: Image.file(
                                      File(image),
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.file(
                                          File('assets/images/icon_user.png'),
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  SizedBox(height: size.width * 0.02),
                  // boton camara evidencias
                  IntrinsicWidth(
                    child: ElevatedButton(
                      onPressed: 
                      _evidencias 
                      ? () async{
                          handleImageEvidencias();
                        }
                      : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: isLandscape
                            ? size.width * 0.015
                            : size.width * 0.020),
                          Icon(Icons.photo_camera, size: isLandscape
                            ? size.width * 0.03
                            : size.width * 0.05),
                          SizedBox(height: isLandscape
                            ? size.width * 0.015
                            : size.width * 0.020),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * 0.02),
                  // Fila
                  Row(
                    children: [
                      Expanded(child: Text("Fila: ", style: TextStyle(color: myColor, fontSize: isLandscape
                        ? size.width * 0.02
                        : size.width * 0.03))),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'A',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03,
                                    //fontWeight: FontWeight.bold,
                                    color: myColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          items: itemsFila
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: isLandscape
                                          ? size.width * 0.02
                                          : size.width * 0.03,
                                        //fontWeight: FontWeight.bold,
                                        color: myColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: fila,
                          onChanged: (value) {
                            setState(() {
                              fila = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: isLandscape
                              ? size.width * 0.06
                              : size.width * 0.08,
                            width: isLandscape
                              ? size.width * 0.25
                              : size.width * 0.45,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: IconStyleData(
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: isLandscape
                              ? size.width * 0.02
                              : size.width * 0.03,
                            iconEnabledColor: myColor,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: isLandscape
                              ? size.height * 0.5
                              : size.height * 0.5,
                            width: isLandscape
                              ? size.height * 0.45
                              : size.height * 0.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            offset: const Offset(-20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(6),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            height: isLandscape
                              ? size.height * 0.07
                              : size.height * 0.05,
                            padding: EdgeInsets.only(
                              left: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03, 
                              right: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.width * 0.02),
                  // Firma
                  Text("Firma: ", style: TextStyle(color: myColor, fontSize: isLandscape
                    ? size.width * 0.02
                    : size.width * 0.03)),
                  Signature(
                    controller: _firmaController,
                    height: isLandscape
                      ? size.width * 0.2
                      : size.width * 0.4,
                    width: isLandscape
                      ? size.width * 0.6
                      : size.width * 0.8,
                    backgroundColor: Colors.grey[200]!,
                  ),
                  SizedBox(height: size.width * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _firmaController.clear();
                        },
                        child: Text("Borrar", style: TextStyle(color: myColor, fontSize: isLandscape
                          ? size.width * 0.02
                          : size.width * 0.03)),
                      ),
                    ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('usuario');
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString!);
      final Map<String, dynamic> jsonUsuario = jsonList[0];
      Usuario usuario = Usuario.fromJson(jsonUsuario);
      _userapp = usuario.nombre;
      _apellidos = usuario.apellidos;
      _tipoapp = "1";
    } catch (e) {
      log("Error al decodificar usuario: $e");
    }
    return false;
  }

  Future<void> handleImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 30);

      EasyLoading.show(
        status: 'Cargando...',
        maskType: EasyLoadingMaskType.black,
      );

      if (image != null) {
        // ruta de cache
        //log(image.path);

        // Obtener directorio permanente
        
        // antes con getApplicationDocumentsDirectory()
        
        final Directory? appDocDir = await getDownloadsDirectory();
        final String fileName;
        // final String timestamp = dateTime.toString()
        //   .replaceAll(':', '-')
        //   .replaceAll('.', '-');
        // if(vin=="" || vin==null){
        //   fileName = 
        //     tipoRegistro==0
        //     ? "externo_identificacion_entrada_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //     : tipoRegistro==2 
        //       ? "externo_identificacion_salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //       : "externo_identificacion_entrada-salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        // }else{
        //   fileName = 
        //     tipoRegistro==0
        //     ? "${vin!.toUpperCase()}_identificacion_entrada_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //     : tipoRegistro==2 
        //       ? "${vin!.toUpperCase()}_identificacion_salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //       : "${vin!.toUpperCase()}_identificacion_entrada-salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        // }

        if(vin=="" || vin==null){
          fileName = "externo_${DateTime.now().millisecondsSinceEpoch}.jpg";
        }else{
          fileName = "${vin!.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        }

        final String newPath = path.join(appDocDir!.path, fileName);

        // Copiar imagen desde cache a destino permanente
        final File newImage = await File(image.path).copy(newPath);

        log("Guardado en: ${newImage.path}");

        setState(() {
          imagePaths = List.from(imagePaths)..add(newImage.path);
        });

        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      return;
    } finally {
      // Ocultar el Progress Dialog
      EasyLoading.dismiss();
    }
  }

  Future<void> handleImageEvidencias() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 30);

      EasyLoading.show(
        status: 'Cargando...',
        maskType: EasyLoadingMaskType.black,
      );

      if (image != null) {
        //log(image.path);

        // Obtener directorio permanente
        final Directory? appDocDir = await getDownloadsDirectory();
        final String fileName;
        // final String timestamp = dateTime.toString()
        //   .replaceAll(':', '-')
        //   .replaceAll('.', '-');
        // if(vin=="" || vin==null){
        //   fileName = 
        //     tipoRegistro==0
        //     ? "externo_evidencia_entrada_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //     : tipoRegistro==2 
        //       ? "externo_evidencia_salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //       : "externo_evidencia_entrada-salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        // }else{
        //   fileName = 
        //     tipoRegistro==0
        //     ? "${vin!.toUpperCase()}_evidencia_entrada_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //     : tipoRegistro==2 
        //       ? "${vin!.toUpperCase()}_evidencia_salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        //       : "${vin!.toUpperCase()}_evidencia_entrada-salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        // }
        
        if(vin=="" || vin==null){
          fileName = "externo_${DateTime.now().millisecondsSinceEpoch}.jpg";
        }else{
          fileName = "${vin!.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        }

        final String newPath = path.join(appDocDir!.path, fileName);

        // Copiar imagen desde cache a destino permanente
        final File newImage = await File(image.path).copy(newPath);

        log("Guardado en: ${newImage.path}");

        setState(() {
          imagePathsEvidencias = List.from(imagePathsEvidencias)..add(newImage.path);
        });

        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      return;
    } finally {
      // Ocultar el Progress Dialog
      EasyLoading.dismiss();
    }
  }

  Future<bool> _guardarFirma() async {
    if (_firmaController.isNotEmpty) {
      final Uint8List? datosFirma = await _firmaController.toPngBytes();
      if (datosFirma != null) {
        // Obtener directorio temporal
        final Directory? tempDir = await getDownloadsDirectory();
        final String filePath;
        // final String timestamp = dateTime.toString()
        //   .replaceAll(':', '-')
        //   .replaceAll('.', '-');
        // Ruta del archivo con fecha y hora en el nombre
        // if(vin=="" || vin==null){
        //   filePath =
        //     tipoRegistro==0
        //     ? '${tempDir!.path}/externo_firma_entrada_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        //     : tipoRegistro==2 
        //       ? '${tempDir!.path}/externo_firma_salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        //       : '${tempDir!.path}/externo_firma_entrada-salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        //     log(filePath);
        // }else{
        //   filePath =
        //     tipoRegistro==0
        //     ? '${tempDir!.path}/${vin!.toUpperCase()}_firma_entrada_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        //     : tipoRegistro==2 
        //       ? '${tempDir!.path}/${vin!.toUpperCase()}_firma_salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        //       : '${tempDir!.path}/${vin!.toUpperCase()}_firma_entrada-salida_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        //     log(filePath);
        // }

        if(vin=="" || vin==null){
          filePath = '${tempDir!.path}/externo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }else{
          filePath = '${tempDir!.path}/${vin!.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        // Guardar imagen
        final File file = File(filePath);
        await file.writeAsBytes(datosFirma);

        setState(() {
          setState(() {
            imagePathsFirma = List.from(imagePathsFirma)..add(filePath);
          });
        });
        return true;
      }
    }
    return false;
  }

  void success(BuildContext context, String message) {
    if (!mounted) return;
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

  void onError(context, String messageError) {
    if (!mounted) return;
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

  Future <bool> save(fk_matricula, nombre, empresa_externo, evidencia_externo, List<String>? evidencia_url, List<String>? evidencias_url, List<String>? firma_url, fecha_entrada, fecha_salida, fecha, guardia, fila, vin, modelo, llave, distribuidor, ejes, origen, modeloTanqueIzq, cmTanqueIzq, modeloTanqueDer, cmTanqueDer, tipoTanque, nivel, equipamiento) async{
    final form = RegistroModel(
      fk_matricula: fk_matricula,
      nombre: nombre,
      empresa_externo: empresa_externo,
      evidencia_externo: evidencia_externo,
      evidencia_url: evidencia_url,
      evidencias_url: evidencias_url,
      firma_url: firma_url,
      fecha_entrada: fecha_entrada,
      fecha_salida: fecha_salida,
      fecha: fecha,
      guardia: guardia,
      fila: fila,
      vin: (vin != null && vin!.trim().isNotEmpty) ? vin!.toUpperCase() : null,
      modelo: modelo,
      llave: llave,
      distribuidor: distribuidor,
      ejes: ejes,
      origen: origen,
      modeloTanqueIzq: modeloTanqueIzq,
      cmTanqueIzq: cmTanqueIzq,
      modeloTanqueDer: modeloTanqueDer,
      cmTanqueDer: cmTanqueDer,
      tipoTanque: tipoTanque,
      nivel: nivel,
      equipamiento: equipamiento,
      status: 2
    );

    await DatabaseHelper.instance.insertarFormulario(form);
    return true;
  }

  void fistLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      final response = await http.get(
        Uri(
          scheme: https,
          host: host,
          path: '/proveedor/app/getAll',
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          items = jsonResponse['data'];
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
                  Icons.check,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Error, verificar conexión a Internet",
                  style: TextStyle(
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
    }

    if (!mounted) return;

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    super.initState();
    //modelo = itemsModelo[0];
    //distribuidor = itemsDistribuidor[0];
    //ejes = itemsEjes[0];
    //origen = itemsOrigenes[0];
    modeloTanqueIzq = itemsModeloTanqueIzq[0];
    modeloTanqueDer = itemsModeloTanqueDer[0];
    tipoTanque = itemsTipoTanque[0];
    nivel = itemsNivel[0];
    _vinController = TextEditingController();
    _modeloController = TextEditingController();
    _llaveController = TextEditingController();
    _distribuidorController = TextEditingController();
    _ejesController = TextEditingController();
    _origenController = TextEditingController();
    _equipamientoController = TextEditingController();
    _matriculaController = TextEditingController();
    _nombreController = TextEditingController();
    _empresaController = TextEditingController();
    _guardiaController = TextEditingController();
    //fistLoad();
  }

  @override
  void dispose() {
    _vinController.dispose();
    _modeloController.dispose();
    _llaveController.dispose();
    _distribuidorController.dispose();
    _ejesController.dispose();
    _origenController.dispose();
    _equipamientoController.dispose();
    _matriculaController.dispose();
    _nombreController.dispose();
    _empresaController.dispose();
    _guardiaController.dispose();
    _firmaController.dispose();
    super.dispose();
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
                _onWillPop(context, size, isLandscape);
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
                screenName: "entradasSalidas",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "1", idapp: widget.idapp),
                  appBar: AppBar(
                    title: Text(nameEntradasSalidas, style: TextStyle(color: Colors.white, fontSize: size.width * 0.04)),
                    elevation: 1,
                    toolbarHeight: 100,
                    centerTitle: true,
                    shadowColor: Colors.white,
                    backgroundColor: myColorIntense,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white, size: size.width * 0.05),
                        onPressed: (){
                          // limpiar campos
                          setState(() {
                            // tipoRegistro, fecha y hora
                            tipoRegistro=0;
                            dateTime = DateTime.now();
                            // vin
                            _vinController.text = "";
                            vin = "";
                            // matricula
                            _matriculaController.text = "";
                            matricula = "";
                            // externo
                            _esExterno = false;
                            // nombre
                            _nombreController.text = "";
                            nombre = "";
                            // empresa
                            _empresaController.text = "";
                            empresa = null;
                            // evidencia
                            imagePaths = [];
                            evidencia = [];
                            // modelo
                            //modelo = "Modelo 1";
                            _modeloController.text = "";
                            modelo = "";
                            // llave
                            _llaveController.text = "";
                            llave = "";
                            // distribuidor
                            //distribuidor = "Distribuidor 1";
                            _distribuidorController.text = "";
                            distribuidor = "";
                            // ejes
                            //ejes = "1";
                            _ejesController.text = "";
                            ejes = "";
                            // origen
                            //origen = "Origen 1";
                            _origenController.text = "";
                            origen = "";
                            // Modelo Tanque izq
                            modeloTanqueIzq = "Seleccione un modelo";
                            modeloTanqueIzqPrint = "";
                            // cm tanque izq
                            showCmTanqueIzq = false;
                            CMTanqueIzq = "Seleccione Centimetros";
                            CMTanqueIzqPrint = "";
                            // Modelo Tanque der
                            modeloTanqueDer = "Seleccione un modelo";
                            modeloTanqueDerPrint = "";
                            // cm tanque der
                            showCmTanqueDer = false;
                            CMTanqueDer = "Seleccione Centimetros";
                            CMTanqueDerPrint = "";
                            // Tipo tanque
                            tipoTanque = "26 L";
                            tipoTanquePrint = "";
                            // nivel
                            nivel = "Menos de 1/4";
                            nivelPrint = "";
                            // equipamiento
                            itemsEquipamiento = [
                              "Gato",
                              "Reflejantes",
                              "Llave & Barra",
                              "Extintores",
                              "Estereo",
                              "Llanta/Rin",
                              "Encendedor",
                              "Cenicero",
                              "Antena",
                            ];
                            checkboxes = {
                              "Gato" : false,
                              "Reflejantes" : false,
                              "Llave & Barra" : false,
                              "Extintores" : false,
                              "Estereo" : false,
                              "Llanta/Rin" : false,
                              "Encendedor" : false,
                              "Cenicero" : false,
                              "Antena" : false
                            };
                            _equipamientoController.text = "";
                            // evidencias
                            _evidencias = false;
                            imagePathsEvidencias = [];
                            // fila
                            fila = "A";
                            // firma
                            _firmaController.clear();
                            imagePathsFirma = [];
                          });
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
                            _onWillPop(context, size, isLandscape);
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                        child: SafeArea(
                          child: Column(
                            children: [
                              Expanded(
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: (i) => setState(() => _currentPage = i),
                                  children: _pages(context, size, isLandscape),
                                ),
                              ),
                              SizedBox(height: size.width * 0.02),
                              PageViewDotIndicator(
                                currentItem: _currentPage,
                                count: _pages(context, size, isLandscape).length,
                                selectedColor: myColor,
                                unselectedColor: Colors.grey,
                              ),
                              SizedBox(height: size.width * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(height: size.width * 0.01),
                                  ElevatedButton(
                                    onPressed: _currentPage > 0
                                      ? () {
                                          _pageController.animateToPage(
                                            _currentPage - 1,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                    child: Text("Anterior", style: TextStyle(color: myColor, fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async{
                                      if (_currentPage == _pages(context, size, isLandscape).length - 1) {
                                        // log(tipoRegistro.toString());
                                        // log(dateTime.toString());
                                        // log(vin ?? "no hay VIN");
                                        // log(matricula ?? "no hay Matricula Operador");
                                        if(matricula==""){
                                          matricula=null;
                                        }
                                        // log(nombre ?? "No hay Nombre Externo");
                                        // log(empresa ?? "No hay Empresa");
                                        //ignore: unused_local_variable
                                        for (String image in imagePaths) {
                                          evidencia = List.from(evidencia)..add(image);
                                          log(image);
                                        }
                                        // log(modelo ?? "no hay Modelo");
                                        // log(llave ?? "no hay Llave");
                                        // log(distribuidor ?? "no hay Distribuidor");
                                        // log(ejes ?? "no hay Núm. Ejes");
                                        // log(origen ?? "no hay Origen");
                                        if(modeloTanqueIzq=='Seleccione un modelo'){
                                          modeloTanqueIzqPrint='';
                                          CMTanqueIzq = "Seleccione Centimetros";
                                          CMTanqueIzqPrint = "";
                                        }else{
                                          modeloTanqueIzqPrint = modeloTanqueIzq;
                                        }
                                        // log(modeloTanqueIzqPrint ?? "No hay modelo tanque izquierdo");
                                        if(CMTanqueIzqPrint=='Seleccione Centimetros'){
                                          CMTanqueIzq = "Seleccione Centimetros";
                                          CMTanqueIzqPrint = "";
                                        }else{
                                          CMTanqueIzqPrint = CMTanqueIzq;
                                        }
                                        // log(CMTanqueIzqPrint ?? "No hay cm tanque izquierdo");

                                        if(modeloTanqueDer=='Seleccione un modelo'){
                                          modeloTanqueDerPrint='';
                                          CMTanqueDer = "Seleccione Centimetros";
                                          CMTanqueDerPrint = "";
                                        }else{
                                          modeloTanqueDerPrint = modeloTanqueDer;
                                        }
                                        // log(modeloTanqueDerPrint ?? "No hay modelo tanque derecho");
                                        if(CMTanqueDerPrint=='Seleccione Centimetros'){
                                          CMTanqueDer = "Seleccione Centimetros";
                                          CMTanqueDerPrint = "";
                                        }else{
                                          CMTanqueDerPrint = CMTanqueDer;
                                        }
                                        // log(CMTanqueDerPrint ?? "No hay cm tanque izquierdo");
                                        
                                        tipoTanquePrint = tipoTanque;
                                        // log(tipoTanque ?? "no hay Tipo tanque");

                                        nivelPrint = nivel;
                                        // log(nivel ?? "no hay Nivel de Urea");
                                        //Extraer los ítems seleccionados
                                        List<String> seleccionados = checkboxes.entries
                                            .where((entry) => entry.value)
                                            .map((entry) => entry.key)
                                            .toList();
                                        //Convertirlos a String CSV
                                        String seleccionadosCSV = seleccionados.join(',');
                                        // log(seleccionadosCSV);
                                        //guardia
                                        // log("${_userapp!} ${_apellidos!}");
                                        //evidencias
                                        // for (String image in imagePathsEvidencias) {
                                        // log(image);
                                        // }
                                        //fila
                                        // log(fila ?? "no hay Fila");

                                        //firma
                                        var res = await _guardarFirma();
                                        if(!res){
                                          // ignore: use_build_context_synchronously
                                          onError(context, "Debe ingresar Firma");
                                          return;
                                        }

                                        for (String image in imagePathsEvidencias) {
                                          evidencia = List.from(evidencia)..add(image);
                                          log(image);
                                        }
                                        for (String image in imagePathsFirma) {
                                          evidencia = List.from(evidencia)..add(image);
                                          log(image);
                                        }

                                        List<String> evidenciaNombres = evidencia.map((e) => basename(e)).toList();
                                        //log(evidenciaNombres.toString());

                                        if(!_esExterno){
                                          if (vin == null || vin!.isEmpty) {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar VIN");
                                            return;
                                          }
                                          if (matricula == null || matricula!.isEmpty) {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar Matricula");
                                            return;
                                          }
                                          if (nombre == null || nombre!.isEmpty) {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar Nombre");
                                            return;
                                          }
                                          if (llave == null || llave!.isEmpty) {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar llave");
                                            return;
                                          }
                                          if (modeloTanqueIzqPrint == '') {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar Modelo Tanque Izquierdo");
                                            return;
                                          }

                                          if (CMTanqueIzqPrint == '') {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar cm Tanque Izquierdo");
                                            return;
                                          }

                                          if (modeloTanqueDerPrint == '') {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar Modelo Tanque Derecho");
                                            return;
                                          }

                                          if (CMTanqueDerPrint == '') {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar cm Tanque Derecho");
                                            return;
                                          }
                                        }else{
                                          if (nombre == null || nombre!.isEmpty) {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar Nombre");
                                            return;
                                          }
                                          if (empresa == null || empresa!.isEmpty) {
                                            // ignore: use_build_context_synchronously
                                            onError(context, "Debe ingresar Empresa");
                                            return;
                                          }
                                          vin = null;
                                          matricula = null;
                                          modelo = null;
                                          llave = null;
                                          distribuidor = null;
                                          ejes = null;
                                          origen = null;
                                          modeloTanqueIzqPrint = null;
                                          CMTanqueIzqPrint = null;
                                          modeloTanqueDerPrint = null;
                                          CMTanqueDerPrint = null;
                                          tipoTanquePrint = null;
                                          nivelPrint = null;
                                        }
                                        
                                        // Tipo de Entrada
                                        if(tipoRegistro == 0){
                                          // entrada  
                                          // ignore: use_build_context_synchronously
                                          await save(matricula, nombre, empresa, evidenciaNombres, imagePaths, imagePathsEvidencias, imagePathsFirma, dateTime.toString(), null, null, "${_userapp!} ${_apellidos!}", fila, vin, modelo, llave, distribuidor, ejes, origen, modeloTanqueIzqPrint, CMTanqueIzqPrint, modeloTanqueDerPrint, CMTanqueDerPrint, tipoTanquePrint, nivelPrint, seleccionadosCSV);                                          
                                        }else if(tipoRegistro == 2){
                                          // salida
                                          // ignore: use_build_context_synchronously
                                          await save(matricula, nombre, empresa, evidenciaNombres, imagePaths, imagePathsEvidencias, imagePathsFirma, null, dateTime.toString(), null, "${_userapp!} ${_apellidos!}", fila, vin, modelo, llave, distribuidor, ejes, origen, modeloTanqueIzqPrint, CMTanqueIzqPrint, modeloTanqueDerPrint, CMTanqueDerPrint, tipoTanquePrint, nivelPrint, seleccionadosCSV);
                                        }else{
                                          // ambas
                                          // ignore: use_build_context_synchronously
                                          await save(matricula, nombre, empresa, evidenciaNombres, imagePaths, imagePathsEvidencias, imagePathsFirma, null, null, dateTime.toString(), "${_userapp!} ${_apellidos!}", fila, vin, modelo, llave, distribuidor, ejes, origen, modeloTanqueIzqPrint, CMTanqueIzqPrint, modeloTanqueDerPrint, CMTanqueDerPrint, tipoTanquePrint, nivelPrint, seleccionadosCSV);
                                        }
                                        // ignore: use_build_context_synchronously
                                        success(context, "Registro agregado exitosamente");
                                        navigatorKey.currentState?.pushNamedAndRemoveUntil(
                                          HomeScreen.routeName,
                                          (Route<dynamic> route) => false,
                                        );
                                      } else {
                                        _pageController.animateToPage(
                                          _currentPage + 1,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: Text(_currentPage == _pages(context, size, isLandscape).length - 1 ? "Guardar" : "Siguiente", style: TextStyle(color: myColor, fontSize: isLandscape
                                      ? size.width * 0.02
                                      : size.width * 0.03)),
                                  ),
                                  SizedBox(height: size.width * 0.01),
                                ],
                              ),
                              SizedBox(height: isLandscape
                                ? size.width * 0.02
                                : size.width * 0.03),
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

  Future<bool> _onWillPop(context, size, isLandscape) async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Cancelar registro', style: TextStyle(fontSize: isLandscape
              ? size.width * 0.03
              : size.width * 0.04)),
            content: Text('¿Deseas cancelar el registro?', style: TextStyle(fontSize: isLandscape
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
                onPressed: () {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    HomeScreen.routeName,
                    (Route<dynamic> route) => false,
                  );
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

  void cargaVIN(context, orden) async {
    EasyLoading.show(
      status: 'Cargando...',
      maskType: EasyLoadingMaskType.black
    );
    try {
      final http.Response response;
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            path: '/app/bitacora/getRegistroByOrden.php',
            queryParameters: {
              'ID_orden': orden,
            },
          ),
        ).timeout(const Duration(seconds: 3));
      //log(response.statusCode.toString());
      //log(response.body);
      if (response.statusCode == 200) {
        //log(response.body);
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data != null && data is List && data.isNotEmpty) {
            final registro = data[0];
            // matricula
            if(registro['ID_matricula'] != null){
              _matriculaController.text = registro['ID_matricula'];
              matricula = registro['ID_matricula'];
            }
            // nombre
            if(registro['Nombres'] != null){
              _esExterno = false;
              _nombreController.text = registro['Nombres']+" "+registro['Ap_paterno'];
              nombre = registro['Nombres']+" "+registro['Ap_paterno']; 
            }
            // modelo
            if(registro['Modelo'] != null){
              _modeloController.text = registro['Modelo'];
              modelo = registro['Modelo'];
            }
            // distribuidor
            if(registro['r_social'] != null){
              _distribuidorController.text = registro['r_social'];
              distribuidor = registro['r_social'];
            }
            // ejes
            if(registro['ID_clave'] != null){
              _ejesController.text = registro['ID_clave'];
              ejes = registro['ID_clave'];
            }
            // origen
            if(registro['Origen_nombre'] != null){
              _origenController.text = registro['Origen_nombre'];
              origen = registro['Origen_nombre'];
            }            
          }
        }
        setState(() {});
      } else {
        // matricula
        _matriculaController.text = "";
        matricula = "";
        // nombre
        _esExterno = false;
        _nombreController.text = "";
        nombre = ""; 
        // modelo
        _modeloController.text = "";
        modelo = "";
        // distribuidor
        _distribuidorController.text = "";
        distribuidor = "";
        // ejes
        _ejesController.text = "";
        ejes = "";
        // origen
        _origenController.text = "";
        origen = "";
        setState(() {});
        if (kDebugMode) {
          print("Error en la respuesta: ${response.statusCode}");
        }
      }
    } on TimeoutException catch (_){
      //EasyLoading.showError("Conexión demasiado lenta, intenta nuevamente");
      // matricula
        _matriculaController.text = "";
        matricula = "";
        // nombre
        _esExterno = false;
        _nombreController.text = "";
        nombre = ""; 
        // modelo
        _modeloController.text = "";
        modelo = "";
        // distribuidor
        _distribuidorController.text = "";
        distribuidor = "";
        // ejes
        _ejesController.text = "";
        ejes = "";
        // origen
        _origenController.text = "";
        origen = "";
        setState(() {});
    } catch (e) {
      // matricula
        _matriculaController.text = "";
        matricula = "";
        // nombre
        _esExterno = false;
        _nombreController.text = "";
        nombre = ""; 
        // modelo
        _modeloController.text = "";
        modelo = "";
        // distribuidor
        _distribuidorController.text = "";
        distribuidor = "";
        // ejes
        _ejesController.text = "";
        ejes = "";
        // origen
        _origenController.text = "";
        origen = "";
        setState(() {});
      if (kDebugMode) {
        print('Error al cargar datos');
      }
      //EasyLoading.showError("Verificar conexión a Internet");
    }

    if (!mounted) return;

    EasyLoading.dismiss();
    setState(() {});
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

}