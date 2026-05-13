class Restoran {
  final int restoranId;
  final String ad;
  final String? aciklama;
  final String? logoUrl;   // resimUrl yerine logoUrl (backend ile eşleşti)
  final String? adres;     // YENİ
  final double? puan;      // YENİ
  final String? kategori;
 
  Restoran({
    required this.restoranId,
    required this.ad,
    this.aciklama,
    this.logoUrl,
    this.adres,
    this.puan,
    this.kategori,
  });
 
  factory Restoran.fromJson(Map<String, dynamic> json) {
    return Restoran(
      restoranId: json['restoranId'] ?? 0,
      ad: json['ad'] ?? '',
      aciklama: json['aciklama'],
      logoUrl: json['logoUrl'],
      adres: json['adres'],
      puan: json['puan'] != null ? double.tryParse(json['puan'].toString()) : null,
      kategori: json['kategori'],
    );
  }
}
