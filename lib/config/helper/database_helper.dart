import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tusabitacoraapp/models/registro.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'registros.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE registros (
            id_registro INTEGER PRIMARY KEY AUTOINCREMENT,
            fk_matricula TEXT,
            nombre TEXT,
            empresa_externo TEXT,
            evidencia_externo TEXT,
            evidencia_url TEXT,
            evidencias_url TEXT,
            firma_url TEXT,
            fecha_entrada TEXT,
            fecha_salida TEXT,
            fecha TEXT,
            guardia TEXT,
            fila TEXT,
            vin TEXT,
            modelo TEXT,
            llave TEXT,
            distribuidor TEXT,
            ejes TEXT,
            origen TEXT,
            modeloTanqueIzq TEXT,
            cmTanqueIzq TEXT,
            modeloTanqueDer TEXT,
            cmTanqueDer TEXT,
            tipoTanque TEXT,
            nivel TEXT,
            equipamiento TEXT,
            status INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertarFormulario(RegistroModel form) async {
    final db = await database;
    return await db.insert('registros', form.toMap());
  }

  Future<List<RegistroModel>> obtenerFormularios() async {
    final db = await database;
    final maps = await db.query('registros');
    return maps.map((item) => RegistroModel(
      id_registro: item['id_registro'] as int?,
      fk_matricula: item['fk_matricula'] as String?,
      nombre: item['nombre'] as String?,
      empresa_externo: item['empresa_externo'] as String?,
      evidencia_externo: item['evidencia_externo'] != null
        ? List<String>.from(jsonDecode(item['evidencia_externo'] as String))
        : [],
      evidencia_url: item['evidencia_url'] != null
        ? List<String>.from(jsonDecode(item['evidencia_url'] as String))
        : [],
      evidencias_url: item['evidencias_url'] != null
        ? List<String>.from(jsonDecode(item['evidencias_url'] as String))
        : [],
      firma_url: item['firma_url'] != null
        ? List<String>.from(jsonDecode(item['firma_url'] as String))
        : [],
      fecha_entrada: item['fecha_entrada'] as String?,
      fecha_salida: item['fecha_salida'] as String?,
      fecha: item['fecha'] as String?,
      guardia: item['guardia'] as String?,
      fila: item['fila'] as String?,
      vin: item['vin'] as String?,
      modelo: item['modelo'] as String?,
      llave: item['llave'] as String?,
      distribuidor: item['distribuidor'] as String?,
      ejes: item['ejes'] as String?,
      origen: item['origen'] as String?,
      modeloTanqueIzq: item['modeloTanqueIzq'] as String?,
      cmTanqueIzq: item['cmTanqueIzq'] as String?,
      modeloTanqueDer: item['modeloTanqueDer'] as String?,
      cmTanqueDer: item['cmTanqueDer'] as String?,
      tipoTanque: item['tipoTanque'] as String?,
      nivel: item['nivel'] as String?,
      equipamiento: item['equipamiento'] as String?,
      status: item['status'] as int?,
    )).toList();
  }
}
