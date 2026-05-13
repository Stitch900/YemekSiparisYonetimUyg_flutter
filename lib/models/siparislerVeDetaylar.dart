class Siparis {
  final int siparisId;
  final int kullaniciId;
  final int restoranId;
  final double toplamTutar;
  final String durum;
  final DateTime tarih;
  final List<SiparisDetay>? detaylar;

  Siparis({
    required this.siparisId,
    required this.kullaniciId,
    required this.restoranId,
    required this.toplamTutar,
    required this.durum,
    required this.tarih,
    this.detaylar,
  });

  factory Siparis.fromJson(Map<String, dynamic> json) {
    return Siparis(
      siparisId: json['siparisId'] ?? json['SiparisId'] ?? 0,
      kullaniciId: json['kullaniciId'] ?? json['KullaniciId'] ?? 0,
      restoranId: json['restoranId'] ?? json['RestoranId'] ?? 0,
      
      // Güvenli Double Çevirimi
      toplamTutar: (json['toplamTutar'] ?? json['ToplamTutar'] ?? 0).toDouble(),
      
      durum: json['durum'] ?? json['Durum'] ?? 'Hazırlanıyor',
      
      // Güvenli Tarih Çevirimi
      tarih: (json['tarih'] != null || json['Tarih'] != null)
          ? DateTime.parse(json['tarih'] ?? json['Tarih'])
          : DateTime.now(),
          
      // Güvenli Liste Çevirimi
      detaylar: (json['siparisDetaylari'] ?? json['SiparisDetaylari']) != null 
          ? ((json['siparisDetaylari'] ?? json['SiparisDetaylari']) as List)
              .map((i) => SiparisDetay.fromJson(i)).toList()
          : null,
    );
  }
}

class SiparisDetay {
  final int yemekId;
  final int adet;
  final double birimFiyat;

  SiparisDetay({required this.yemekId, required this.adet, required this.birimFiyat});

  factory SiparisDetay.fromJson(Map<String, dynamic> json) {
    return SiparisDetay(
      yemekId: json['yemekId'] ?? json['YemekId'] ?? 0,
      adet: json['adet'] ?? json['Adet'] ?? 0,
      birimFiyat: (json['birimFiyat'] ?? json['BirimFiyat'] ?? 0).toDouble(),
    );
  }
}