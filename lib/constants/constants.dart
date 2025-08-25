import 'package:flutter/cupertino.dart';

const nameVersion = "TUSA Bitacora v";

const nameApp = "TUSA Bitacora";

const myLogo = 'assets/icon/logoatm.png';

const myLogo2 = 'assets/images/logoatm3.jpg';

const nameProveedor = "Proveedor";

const namePatio = "Patio";

const nameHistorial = "Historial";

const nameEntradasSalidas = "Registro";

const nameEditEntradasSalidas = "Editar Registro";

const nameEvidencia = "Evidencia";

const Color myColor = Color.fromRGBO(1, 76, 151, 1);

const Color myColorIntense = Color.fromRGBO(14, 81, 160, 1);

const Color myColorBackground1 = Color.fromRGBO(0, 34, 67, 1);

const Color myColorBackground2 =Color.fromRGBO(110, 110, 110, 1);

const Color myColorBackground3 = Color.fromRGBO(255, 255, 255, 1);

const Color myDisable = Color.fromRGBO(128, 128, 128, 0.5);

final colors = <Color>[
  myColorBackground3,
  myColorBackground3,
  myColorIntense,
];

// servidor
const String https = "https";
const String host = "trasladosuniversales.com.mx";

// cloudflare
const String apiUrl = String.fromEnvironment('CLOUDFLARE_API_URL', defaultValue: 'https://api.cloudflare.com/client/v4');
const String accountId = String.fromEnvironment('CLOUDFLARE_ACCOUNT_ID', defaultValue: '587676921e6e286ff40195a9a1e49da4');
const String tokenCloudflare = String.fromEnvironment('CLOUDFLARE_TOKEN', defaultValue: 'SkUbBkwYu_HqcNcBhhnH_sQkpnVWJXwxtVSrJGu0');
const String apiKey = String.fromEnvironment('CLOUDFLARE_API_KEY', defaultValue: '78cf58f9ec2ea5e69dc9441998018bd58eb5f');
const String accountEmail = String.fromEnvironment('CLOUDFLARE_ACCOUNT_EMAIL', defaultValue: 'cloudflare@ddsmedia.net');
const String userServiceKey = String.fromEnvironment('CLOUDFLARE_USER_SERVICE_KEY', defaultValue: 'cloudflare@ddsmedia.net');

// SQL Server
const String ipSQL = "20.15.201.237";
const String portSQL = "1433";
const String databaseSQL = "Tusa";
const String usernameSQL = "tusasa";
const String passSQL = "51s73m452019";

// FTP
const String ftpServer = "vmtraunsqlsrv01.centralus.cloudapp.azure.com";
const String ftpUser = "admin.traslados";
const String ftpPass = "dL3@cNWmT7eopUw!mw4CrZKaNkp5nB";