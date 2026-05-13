class Yorum {
  final int yorumId;
  final int kullaniciId;
  final int? restoranId; // Yorum restorana yapıldıysa dolu, ürüne yapıldıysa null
  final int? urunId;     // Yorum ürüne yapıldıysa dolu, restorana yapıldıysa null
  final int puan;        // 1 ile 5 arası
  final String metin;
  final String adSoyad;  // Yorumu yapanın adı (C# DTO'dan gelmeli)
  final DateTime tarih;

  Yorum({
    required this.yorumId,
    required this.kullaniciId,
    this.restoranId,
    this.urunId,
    required this.puan,
    required this.metin,
    required this.adSoyad,
    required this.tarih
  });

  factory Yorum.fromJson(Map<String, dynamic> json) {
  return Yorum(
    yorumId: json['yorumId'] ?? json['YorumId'] ?? 0,

    kullaniciId: json['kullaniciId'] ?? json['KullaniciId'] ?? 0,

    restoranId: json['restoranId'] ?? json['RestoranId'],

    urunId: json['urunId'] ?? json['UrunId'],

    puan: json['puan'] ?? json['Puan'] ?? 5,

    metin: json['metin'] ?? json['Metin'] ?? "",

    // BURAYI DEĞİŞTİR
    adSoyad:
        json['kullaniciAdi'] ??
        json['KullaniciAdi'] ??
        "Anonim Kullanıcı",

    tarih: json['tarih'] != null
        ? DateTime.parse(json['tarih'])
        : DateTime.now(),
  );
}
}