import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart'; // <-- [PENTING] Tambahkan ini untuk session ID
import '../models/kosakata.dart'; // Jika Anda masih menggunakannya di bagian lain

class ApiService {
  // Ganti dengan URL API Laravel Anda
  final String baseUrl = 'https://javdict.site/api';

  // --- Fungsi untuk halaman daftar kosakata (Bisa dipertahankan) ---
  Future<List<Kosakata>> getDaftarKosakata() async {
    final response = await http.get(Uri.parse('$baseUrl/kosakata'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((item) => Kosakata.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil daftar kosakata');
    }
  }

  // --- Fungsi untuk halaman detail kosakata (Bisa dipertahankan) ---
  Future<Kosakata> getDetailKosakata(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/kosakata/$id'));

    if (response.statusCode == 200) {
      return Kosakata.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil detail kosakata dengan ID: $id');
    }
  }

  // --- FUNGSI UTAMA UNTUK CHATBOT (JAUH LEBIH SEDERHANA) ---
  // Fungsi ini akan menggantikan `kirimPesanKeDialogflowCX`
  Future<String> kirimPesanKeBackend(String pesan) async {
    // Endpoint webhook di Laravel Anda
    final url = Uri.parse('$baseUrl/chatbot'); // <-- Sesuaikan dengan route di Laravel

    // Buat session ID unik untuk setiap percakapan
    // (Anda bisa menyimpannya jika ingin percakapan berlanjut)
    final String sessionId = Uuid().v4();

    // Body permintaan yang akan dikirim ke Laravel Anda
    final Map<String, dynamic> requestBody = {
      'text': pesan,
      'session_id': sessionId
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Kita harapkan Laravel mengembalikan JSON dengan format yang sama seperti Dialogflow
        final jsonResponse = jsonDecode(response.body);

        // Ambil pesan dari respons Laravel
        String fulfillmentText = jsonResponse['fulfillmentResponse']['messages'][0]['text']['text'][0];

        return fulfillmentText.isNotEmpty ? fulfillmentText : 'Maaf, terjadi kesalahan.';
      } else {
        // Tangani error dari server Laravel
        print('Error dari server: ${response.body}');
        throw Exception('Gagal mendapatkan respons dari server: ${response.statusCode}');
      }
    } catch (e) {
      // Tangani error jaringan atau lainnya
      print('Error saat mengirim pesan ke backend: $e');
      throw Exception('Gagal terhubung ke server.');
    }
  }
}