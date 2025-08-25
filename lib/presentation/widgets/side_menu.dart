import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tusabitacoraapp/constants/constants.dart';
import 'package:tusabitacoraapp/presentation/screens/entradas_salidas/entradas_salidas_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/historial/historial_screen.dart';
import 'package:tusabitacoraapp/presentation/screens/patio/patio_screen.dart';
import '../screens/home/home_screen.dart';

class SideMenu extends StatefulWidget {
  final String userapp;
  final String tipoapp;
  final String idapp;
  const SideMenu({
    Key? key,
    required this.userapp,
    required this.tipoapp,
    required this.idapp,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int? navDrawerIndex;
  late Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _checkVersion();
  }

  Future<String> _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return NavigationDrawer(
      backgroundColor: myColorIntense,
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (value) {
        setState(() {
          navDrawerIndex = value;
          if(widget.tipoapp=="1"){
            switch (navDrawerIndex) {
              case 0:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                );
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed(
                  PatioScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed(
                  EntradasSalidasScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;                
              case 3:
                Navigator.of(context).pushReplacementNamed(
                  HistorialScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;                
              default:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                );
                break;
            }
          }else{
            switch (navDrawerIndex) {
              case 0:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                );
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed(
                  PatioScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed(
                  EntradasSalidasScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 3:
                Navigator.of(context).pushReplacementNamed(
                  HistorialScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              default:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                );
                break;
            }
          }
        });
      },
      children: [
        FutureBuilder<String>(
          future: _versionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const DrawerHeader(
                decoration: BoxDecoration(color: myColorIntense),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const DrawerHeader(
                decoration: BoxDecoration(color: myColorIntense),
                child: Center(child: Text("Error al cargar la versión")),
              );
            } else {
              // return DrawerHeader(
              //   decoration: const BoxDecoration(color: myColorIntense),
              //   child: SizedBox.expand(
              //     child: Container(
              //       color: Colors.transparent,
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Center(
              //             child: Container(
              //               height: size.height * 0.071,
              //               width: size.width * 0.4,
              //               color: Colors.white10,
              //               child: Image.asset(
              //                 myLogo,
              //                 height: size.height * 0.08,
              //                 width: size.width * 0.4,
              //               ),
              //             ),
              //           ),
              //           SizedBox(height: size.width * 0.01),
              //           Text(
              //             widget.userapp,
              //             style: const TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           Text(
              //             nameVersion + snapshot.data!,
              //             style: const TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // );

              // HEADER PERSONALIZADO
              return Container(
                padding: EdgeInsets.all(size.width * 0.025),
                color: myColorIntense,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: isLandscape
                          ? size.width * 0.05
                          : size.width * 0.15,
                        width: isLandscape
                          ? size.width * 0.15
                          : size.width * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(size.width * 0.02),
                        ),
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Image.asset(
                          myLogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.02),
                    Text(
                      widget.userapp,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape
                          ? size.width * 0.02
                          : size.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size.width * 0.005),
                    Text(
                      '$nameVersion${snapshot.data!}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape
                          ? size.width * 0.015
                          : size.width * 0.025,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }
          },
        ),
        Divider(height: size.width * 0.005),
        SizedBox(height: size.width * 0.01),
        NavigationDrawerDestination(
          icon: Icon(Icons.home_filled, color: Colors.white, 
            size: isLandscape
              ? size.width * 0.03
              : size.width * 0.04),
          label: Text("Inicio", style: TextStyle(color: Colors.white, 
            fontSize: isLandscape
              ? size.width * 0.018
              : size.width * 0.03)),
        ),
        const Divider(
          height: 1,
          thickness: 0.1,
          indent: 20,
          endIndent: 20,
          color: Colors.white,
        ),

        if(widget.tipoapp=="1")
          NavigationDrawerDestination(
            icon: Icon(Icons.local_shipping, color: Colors.white, 
              size: isLandscape
                ? size.width * 0.03
                : size.width * 0.04),
            label: Text("Patio", style: TextStyle(color: Colors.white, 
              fontSize: isLandscape
                ? size.width * 0.018
                : size.width * 0.03)),
          ),
        if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),

        if(widget.tipoapp=="1")
          NavigationDrawerDestination(
            icon: Icon(Icons.list_alt, color: Colors.white, 
              size: isLandscape
                ? size.width * 0.03
                : size.width * 0.04),
            label: Text("Entradas / Salidas", style: TextStyle(color: Colors.white, 
              fontSize: isLandscape
                ? size.width * 0.018
                : size.width * 0.03)),
          ),
        if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),

        if(widget.tipoapp=="1")
          NavigationDrawerDestination(
            icon: Icon(Icons.history, color: Colors.white, 
            size: isLandscape
              ? size.width * 0.03
              : size.width * 0.04),
            label: Text("Historial de bitacora", style: TextStyle(color: Colors.white, 
              fontSize: isLandscape
                ? size.width * 0.018
                : size.width * 0.03)),
          ),
        if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),

      ],
    );
  }

}
