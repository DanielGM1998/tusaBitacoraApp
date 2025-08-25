
import 'dart:convert';

class RegistroModel {
  int? id_registro;
  String? fk_matricula;
  String? nombre;
  String? empresa_externo;
  List<String>? evidencia_externo;
  List<String>? evidencia_url;
  List<String>? evidencias_url;
  List<String>? firma_url;
  String? fecha_entrada;
  String? fecha_salida;
  String? fecha;
  String? guardia;
  String? fila;
  String? vin;
  String? modelo;
  String? llave;
  String? distribuidor;
  String? origen;
  String? ejes;
  String? modeloTanqueIzq;
  String? cmTanqueIzq;
  String? modeloTanqueDer;
  String? cmTanqueDer;
  String? tipoTanque;
  String? nivel;
  String? equipamiento;
  int? status; 

  RegistroModel({
    this.id_registro,
    this.fk_matricula,
    this.nombre,
    this.empresa_externo,
    this.evidencia_externo,
    this.evidencia_url,
    this.evidencias_url,
    this.firma_url,
    this.fecha_entrada,
    this.fecha_salida,
    this.fecha,
    this.guardia,
    this.fila,
    this.vin,
    this.modelo,
    this.llave,
    this.distribuidor,
    this.ejes,
    this.origen,
    this.modeloTanqueIzq,
    this.cmTanqueIzq,
    this.modeloTanqueDer,
    this.cmTanqueDer,
    this.tipoTanque,
    this.nivel,
    this.equipamiento,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_registro': id_registro,
      'fk_matricula': fk_matricula,
      'nombre': nombre,
      'empresa_externo': empresa_externo,
      'evidencia_externo': evidencia_externo != null ? jsonEncode(evidencia_externo) : null,
      'evidencia_url': evidencia_url != null ? jsonEncode(evidencia_url) : null,
      'evidencias_url': evidencias_url != null ? jsonEncode(evidencias_url) : null,
      'firma_url': firma_url != null ? jsonEncode(firma_url) : null,
      'fecha_entrada': fecha_entrada,
      'fecha_salida': fecha_salida,
      'fecha': fecha,
      'guardia': guardia,
      'fila': fila,
      'vin': vin,
      'modelo': modelo,
      'llave': llave,
      'distribuidor': distribuidor,
      'ejes': ejes,
      'origen': origen,
      'modeloTanqueIzq': modeloTanqueIzq,
      'cmTanqueIzq': cmTanqueIzq,
      'modeloTanqueDer': modeloTanqueDer,
      'cmTanqueDer': cmTanqueDer,
      'tipoTanque': tipoTanque,
      'nivel': nivel,
      'equipamiento': equipamiento,
      'status': status,
    };
  }
}
