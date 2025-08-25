/*lib/config/services/get_service_key.dart

//import 'package:googleapis_auth/auth_io.dart';

class GetServiceKey {
  Future<String> getServerKeyToken() async{
    return "";
    
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": "cad-actopan",
          "private_key_id": "2e96165f714fd3d5fe548cca9684283e2f705f6c",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDLYcHHscg2H+fg\nmYBUbQbuuJBMZD1kEK/LFnguk+E9Z8UHEJ2nSgGFKRjh/st5Aa/YMDWhQK649YUZ\n2i7oes6KI+UuFh5VY/frRDMSb9in8uHzT/nFQFuRfoCV8w+XeJJ1dyOtmsqO9A3o\nO+cSd/9C6kdcedpmrwlE3oKBxmN6AfiQjXfxJfwjFYNqli9CFig0+0NJeG+quONe\n7zRwriDvRPp7nggoZKpA0tIBuJ6x9Ow1cJznBHaGQMhUpuD0XD6DaaPbhnFAwDCt\n29JOVm72u0fFlXc1wU89KpM0uOnhGi3AjabQak+ctCkDBIyo+Ol+IRKx+0kdQ414\nDaS92QnnAgMBAAECggEACn5tRrX8HBrSVorlDbYgbPHV9DMZ3c9kmqh6pACaVxZD\nGsW3NLoDUREZSRPiAMje/1shcUQKn91/NCHHWNR5UrReb13Ry9sgICIBNprRxXyp\nPuop+40CDIRH8zS64bhlai0vCJabi/u4ufpZRmEtqRC4hON+qtyuMEEA39xSJqna\nvaBAJ1vPbF3EODrrgRjsrKDT7PAxh87zhGhVc3F4qTLQHbTKBsUOkxXzN1SSKEoU\nTi9SOUn+SWUYekMr8OTQGr337j9YGrh+orQCEI8tZj2eWsL+emK6Zkf9IKukXWOa\nOoT4QPZ4NnCs2cdIAZgwVI3l74+pWG0nEE5sXaGVgQKBgQD4LAm2UFp20M6pZXOp\nfMxmMyS1cVkeymYClO+uUfcSpTwAOTpPqCkuw2IAXIjyxx5eVQ2BRYnlUjUE1j5N\nZ5RynWmiF+BL4MnTLG0NzsyMiYkRMB9WXkRly3ejoLkS/DAt+YMG33o/sdJ5MlZh\na/Nl/kat9lz1PQa4a+7xrqgdgQKBgQDRzAsY/A+16UvEGnkwLwRaSTDeCN42Cc/h\nyK8/lC3K+UI5sxXNM7me1Xwm6CoR+stN/5s2iTLUegHbFkN3CqkPWS5m0MNhNy/p\nqQ3OQlmMnrTf6NNENKDtJyzA+A/2T1JGekxkhFu9ocIOt1jAPL3mxP5HZl24N7dT\nSlA8bICrZwKBgBk8ISCwuwIp6VnAPyqUzhP2T11D0VQYMJdCnbyUCROUSa2cJBnF\nd6qRo31161cEeEoPS/hBIex3l3yObHdieO3Oo9cfpmcQzHT0p4In7RS9R3q/8e/O\nVhYjwl6ZETik/CEwpeok/0FKy6QXQkFVwMI2QOmfi4REWFKYZwucPuwBAoGAeRAf\nj0lU34pCeGU2bYGUJ214z4eaguBin02pIy0kx63Sc21ONV2VzXwv6luqezmXu+i1\n7mB5fnbxPzW3tKfoKr0xs47gT+cCtPkiyFUtS6IBifvWfdNI0dD7WFdNDrtzJMxJ\n7O8b6W/AhbFze2sRwmsGuLjvd/Bez6dgaZ3LGh0CgYEAsGQuQKQkZ+sla8TZsCon\nbP18z93bKp2T1ylJEHdMV8FbArkbKRKpcoEQfnS3Px8trrAUUf7mn6C4qpDlBDwE\nxy5bVwbjfYqqEfsDHgHi2TpeZG7ILUi4h/LRjcCof3kANw1vR8ePo5yfZAFKcenH\ninAgixDlkO6uWVI0Hw97KuY=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-yeftr@cad-actopan.iam.gserviceaccount.com",
          "client_id": "110392873938717935614",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-yeftr%40cad-actopan.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
      ), 
      scopes
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
    
  }
}*/