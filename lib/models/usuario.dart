class Usuario {
  final String idUsuario;
  final int idEmpresa;
  final String contrasena;
  final String nombre;
  final String apellidos;
  final String area;
  final String? telefonos;
  final String? extrencion;
  final String pMaster;
  final String pAdmonyPers;
  final String pTrafico;
  final String pAsigGtos;
  final String pCompGtos;
  final String pFacturacion;
  final String pContabilidad;
  final String pOperadores;
  final String pCalidad;
  final String fCaptura;
  final String movto;
  final int matricula;
  final String correo;
  final String? correoAlterno;
  final String? ctaSkype;
  final String fechaModPassword;
  final String carpetaSGC;

  Usuario({
    required this.idUsuario,
    required this.idEmpresa,
    required this.contrasena,
    required this.nombre,
    required this.apellidos,
    required this.area,
    required this.telefonos,
    required this.extrencion,
    required this.pMaster,
    required this.pAdmonyPers,
    required this.pTrafico,
    required this.pAsigGtos,
    required this.pCompGtos,
    required this.pFacturacion,
    required this.pContabilidad,
    required this.pOperadores,
    required this.pCalidad,
    required this.fCaptura,
    required this.movto,
    required this.matricula,
    required this.correo,
    required this.correoAlterno,
    required this.ctaSkype,
    required this.fechaModPassword,
    required this.carpetaSGC,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['ID_Usuario'],
      idEmpresa: json['ID_Empresa'],
      contrasena: json['Contraseña'],
      nombre: json['Nombre'],
      apellidos: json['Apellidos'],
      area: json['Area'],
      telefonos: json['Telefonos'],
      extrencion: json['Extrención'],
      pMaster: json['P_Master'],
      pAdmonyPers: json['P_AdmonyPers'],
      pTrafico: json['P_Trafico'],
      pAsigGtos: json['P_AsigGtos'],
      pCompGtos: json['P_CompGtos'],
      pFacturacion: json['P_Facturación'],
      pContabilidad: json['P_Contabilidad'],
      pOperadores: json['P_Operadores'],
      pCalidad: json['P_Calidad'],
      fCaptura: json['F_captura'],
      movto: json['Movto'],
      matricula: json['Matricula'],
      correo: json['correo'],
      correoAlterno: json['correo_alterno'],
      ctaSkype: json['cta_skype'],
      fechaModPassword: json['Fecha_mod_password'],
      carpetaSGC: json['Carpeta_SGC'],
    );
  }

  Map<String, dynamic> toJson() => {
    "ID_Usuario": idUsuario,
    "ID_Empresa": idEmpresa,
    "Contrasena": contrasena,
    "Nombre": nombre,
    "Apellidos": apellidos,
    "Area": area,
    "Telefonos": telefonos,
    "Extrención": extrencion,
    "P_Master": pMaster,
    "P_AdmonyPers": pAdmonyPers,
    "P_Trafico": pTrafico,
    "P_AsigGtos": pAsigGtos,
    "P_CompGtos": pCompGtos,
    "P_Facturación": pFacturacion,
    "P_Contabilidad": pContabilidad,
    "P_Operadores": pOperadores,
    "P_Calidad": pCalidad,
    "F_captura": fCaptura,
    "Movto": movto,
    "Matricula": matricula,
    "correo": correo,
    "correo_alterno": correoAlterno,
    "cta_skype": ctaSkype,
    "Fecha_mod_password": fechaModPassword,
    "Carpeta_SGC": carpetaSGC,
  };
}
