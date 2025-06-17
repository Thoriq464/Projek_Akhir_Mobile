class Kosakata {
  final int id;
  final String kataJawa;
  final String kataIndonesia;
  final String? jenisKata;
  final String? contohKalimat;
  final String? contohKalimatIndonesia;

  Kosakata({
    required this.id,
    required this.kataJawa,
    required this.kataIndonesia,
    this.jenisKata,
    this.contohKalimat,
    this.contohKalimatIndonesia,
  });

  factory Kosakata.fromJson(Map<String, dynamic> json) {
    return Kosakata(
      id: json['id'] as int,
      kataJawa: json['kata_jawa'] as String,
      kataIndonesia: json['kata_indonesia'] as String,
      jenisKata: json['jenis_kata'] as String?,
      contohKalimat: json['contoh_kalimat'] as String?,
      contohKalimatIndonesia: json['contoh_kalimat_id'] as String?,
    );
  }
}