import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/dialogflow/v3.dart' as DialogflowApi;
import '../models/kosakata.dart';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Ganti dengan URL API Laravel Anda
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // Fungsi untuk mengambil daftar kosakata
  Future<List<Kosakata>> getDaftarKosakata() async {
    final response = await http.get(Uri.parse('$baseUrl/kosakata'));

    if (response.statusCode == 200) {
      // Jika request berhasil, parse JSON dan kembalikan daftar Kosakata
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((item) => Kosakata.fromJson(item)).toList();
    } else {
      // Jika request gagal, lempar exception
      throw Exception('Gagal mengambil daftar kosakata');
    }
  }

  // Fungsi untuk mengambil detail kosakata berdasarkan ID
  Future<Kosakata> getDetailKosakata(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/kosakata/$id'));

    if (response.statusCode == 200) {
      // Jika request berhasil, parse JSON dan kembalikan objek Kosakata
      return Kosakata.fromJson(jsonDecode(response.body));
    } else {
      // Jika request gagal, lempar exception
      throw Exception('Gagal mengambil detail kosakata dengan ID: $id');
    }
  }

  Future<String> kirimPesanKeDialogflowCX(String pesan) async {
    // Ganti dengan Agent ID, Location ID, dan Project ID Dialogflow CX Anda
    final String agentId = '0f92a7d2-bbe1-4d1b-9e55-88fce44b8ba5';
    final String locationId = 'asia-southeast2';
    final String projectId = 'final-p-457608';

    // Generate sessionId
    final String sessionId = Uuid().v4();

    String serviceAccount = '';

    if (kIsWeb) {
       // Kode private key
        final privateKey = '''-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDQtYywuY7nyOA5\nNJzAIMvBTUjDSXkgf6NX6Kv167KN2H3YFzjykkJcrTqmIdx/LHYttgC0jbzbEs/3\nr74q1zjEvzLZonLgXPxbKqT8K7HZr8CVmSJgMocGtgTbTTJPwmmqIDpXUMiHfIUE\nwdO+Ztf14EPbmGGgt3iaXTrArzlBtoqpXaFi3yDJVEIRGhUrbEBKvq7REkPiEznT\nfsLedcRIPvRZAQdZgg6wcGf+JXwaiH3ONarQc8S8A77MosvOw9q8oqSHIUhp6XeS\nGMwZhV8HFXKxNRIamms/mQ2roAftbESQ9VvGoPM1doVJ3gjw0TfHf0KubkKhYSe4\nS3M+p0X5AgMBAAECggEARPoTdt7Eu5b4f/+C5L6SCJ89sokIVrTIa8fSeVK97sJD\niRTXtdefxhhcX0ampIMxxZa2sfV8Gp0jjXUQMQFzWhbku+fD9qHUp163Kz5Xp529\n1NNI+KkKVi32+fGP9KtIl7jR/0SMGbcOEU3r6Kv9qN3HH37DmUW5vq6cOc1Pa4dL\nHropAGo3dRLE7cg6mGTsbI5aoTzRa4Sc5p6H17/Xs/aGKvEuVrzUWYPUc0qKubmP\nfawWmQ3f24yNOFzfZRvb6qC/DfwrYrbyoqzdvPEx4kC7jjQLQSmUdC0p+zE/huZW\ngoBZUz6UyyxnNJXhOUuH/1Ci6659OwoEKOlQ0eR9dwKBgQD5Z0OCbrRLKHDpIvmS\nBx5/XZOFn9LMNNc8V9fz/NsEea0rWxCPaivpFyBLYbK+vhaHvaXkSTO/8EhxhcFK\nsL2WgQVO6j6/1ZxcAJ9qxUFdpXOPFvuPDBh+Ib96gIcrES93RcEFp5jBzk7tNO/5\njy2aM/xpgYUaMUaEzn3clcqSNwKBgQDWOr3AG+UyW/YQLovTtmVY2hVDcqaNsq7B\nqCt2YYjKVxdpmtAM/rGV93youjiZsvuPEZC5SHpms6yvIr+J4CdEBTDTQtG420iw\nZTX7UC1NdnltkFw7SxtkegPu8OJnGll4f4Yy6pXCFHVp6m0+bRC71FspivnG5JeT\nZr09XMWRTwKBgFjXGOwwZRbUrAvQApiq4ok6Gx+hQ+Sr+fOr0ug9rQLWGQJ1qNt9\nVXDtZPqVLafWbI4j1yEPlliLzjJqE+V4OcCP6wUmWf3ZqJ35NtBAvb0O/6/73tYg\n1+SuPtfzSrLjp0XUWiKahcabp+/FSKpb/0GLvSEUGwaugNE0AQ9/aC5XAoGAIfuX\ndg32wZJM6iw4ChF46itODDD3sqqRhi7DFjhKlq5SDHJ+ZlFQolVr9Of1aow103AZ\n4QpaQEhoMC/26kwgbm3UXO7Qjd5bHYAwm/kP9qXAhVzNBKrZYYrpbNHRWEGZx7+S\n7ijAMNVF+tMxGSH78Y+yFljxXleMo9k8U6uPu4kCgYAntK3emTCiPkVS86wwJCag\nb1co7R0BnIsZaAQyUSRemYatLB9uBAJ6NYmAGITDCbrofC+siQU82eiPZiLWERC7\nOtxUIawNVsaJuzO1mvDO5tL7WM+hcAcoDJYR9vb6JLSJ+UuwWb/Pk9jrTJCiAcm3\nVIH2wX0pNI7LQUBA0QGILg==\n-----END PRIVATE KEY-----''';

      // Kode Service Account JSON (tanpa private key)
        final jsonString = '''
       {
          "type": "service_account",
          "project_id": "final-p-457608",
          "private_key_id": "d533e339798e082643351d9a65ac111925228bbe",
          "client_email": "dialogflow-cx-agent@final-p-457608.iam.gserviceaccount.com",
          "client_id": "103238006746513487395",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/dialogflow-cx-agent%40final-p-457608.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
        ''';
         Map<String, dynamic> json = jsonDecode(jsonString);
         json['private_key'] = privateKey;
         serviceAccount = jsonEncode(json);


    } else {
      //Mobile
      // Dapatkan path ke service account key dari variabel lingkungan
      final serviceAccountPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

      if (serviceAccountPath == null) {
        throw Exception(
            'Variabel lingkungan GOOGLE_APPLICATION_CREDENTIALS tidak diatur. '
            'Atur variabel ini dengan path ke file service_account.json Anda.');
      }

      // Baca isi file JSON
      final serviceAccountFile = File(serviceAccountPath);
        List<int> bytes = await serviceAccountFile.readAsBytes();
        serviceAccount = utf8.decode(bytes);
    }

    // // Tambahkan baris ini untuk debugging
    // debugServiceAccountString(serviceAccount);

    //Uri
    final Uri uri = Uri.parse(
        'https://$locationId-dialogflow.googleapis.com/v3/projects/$projectId/locations/$locationId/agents/$agentId/sessions/$sessionId:detectIntent');

    final Map<String, dynamic> request = {
      "queryInput": {
        "text": {
          "text": pesan
        },
        "languageCode": "id"
      }
    };

    // Get credential
    final credentials =
    ServiceAccountCredentials.fromJson(jsonDecode(serviceAccount));
    final client = await clientViaServiceAccount(credentials,
        [DialogflowApi.DialogflowApi.dialogflowScope]);

    try {
      final response = await client.post(uri, headers: {
        'Content-Type': 'application/json',
      }, body: jsonEncode(request));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Ambil fulfillment text dari response Dialogflow CX
        String fulfillmentText = '';
        if (jsonResponse['queryResult']['responseMessages'] != null &&
            jsonResponse['queryResult']['responseMessages'].isNotEmpty) {
          for (var message in jsonResponse['queryResult']['responseMessages']) {
            if (message['text'] != null && message['text']['text'] != null &&
                message['text']['text'].isNotEmpty) {
              fulfillmentText += message['text']['text'][0]; // Mengambil teks pertama dari array
            }
          }
        }

        return fulfillmentText.isNotEmpty ? fulfillmentText : 'Maaf, terjadi kesalahan.';
      } else {
        throw Exception('Gagal mengirim pesan ke Dialogflow CX: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  // Fungsi untuk debugging string serviceAccount
    // void debugServiceAccountString(String serviceAccount) {
    //   for (int i = 0; i < serviceAccount.length; i++) {
    //     int charCode = serviceAccount.codeUnitAt(i);
    //     print('Character at index $i: ${serviceAccount[i]} (Code: $charCode)');
    //     if (charCode < 32 && charCode != 10 && charCode != 13) {
    //       // ASCII control characters (excluding newline and carriage return)
    //       print('  ^-- WARNING: Control character found!');
    //     }
    //   }
    // }
}