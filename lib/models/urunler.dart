class Urun {
  final int yemekId;
  final int restoranId;
  final String ad;
  final String? aciklama;
  final double fiyat;
  final String? resimUrl;

  Urun({
    required this.yemekId,
    required this.restoranId,
    required this.ad,
    this.aciklama,
    required this.fiyat,
    this.resimUrl,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      yemekId: json['yemekId'] ?? 0,
      restoranId: json['restoranId'] ?? 0,
      ad: json['ad'] ?? '',
      aciklama: json['aciklama'],
      fiyat: (json['fiyat'] as num).toDouble(),
      resimUrl: json['resimUrl'],
    );
  }
}