class Kullanici {
  final int kullaniciId;
  final String adSoyad;
  final String email;
  final String? sifre; // Güvenlik için genellikle boş gelir
  final String rol;

  Kullanici({
    required this.kullaniciId,
    required this.adSoyad,
    required this.email,
    this.sifre,
    required this.rol,
  });

  factory Kullanici.fromJson(Map<String, dynamic> json) {
    return Kullanici(
      kullaniciId: json['kullaniciId'] ?? 0,
      adSoyad: json['adSoyad'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'Müşteri',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adSoyad': adSoyad,
      'email': email,
      'sifre': sifre,
      'rol': rol,
    };
  }
}