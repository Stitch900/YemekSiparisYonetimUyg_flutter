import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KimlikDogrulamaServisi {
  static const String baseUrl = "http://localhost:5147/api/Auth";

  // 1. GİRİŞ YAP (LOGIN)
  Future<bool> girisYap(String email, String sifre) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/giris'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "eposta": email,
          "sifre": sifre
        }),
      );

      if (response.statusCode == 200) {
        final veri = json.decode(response.body);
        
        // HATA AYIKLAMA: Backend ne atıyor konsolda görelim
        print("C# GİRİŞ CEVABI: ${response.body}"); 
        
        final tercih = await SharedPreferences.getInstance();
        
        // Token'ı kaydet
        String token = veri['token'] ?? veri['Token'] ?? '';
        await tercih.setString('auth_token', token);
        
        // KULLANICI BİLGİLERİNİ HAFIZAYA KAZIMA (Büyük/Küçük harf duyarsız)
        int id = veri['id'] ?? veri['Id'] ?? veri['kullaniciId'] ?? veri['KullaniciId'] ?? 1;
        String ad = veri['adSoyad'] ?? veri['AdSoyad'] ?? "İsim Yok";
        String eposta = veri['eposta'] ?? veri['Eposta'] ?? veri['Email'] ?? "E-posta Yok";

        await tercih.setInt('kullaniciId', id);
        await tercih.setString('adSoyad', ad);
        await tercih.setString('eposta', eposta);
        
        print("GİRİŞ BAŞARILI! Veriler telefona kaydedildi.");
        return true;
      } else {
        print("GİRİŞ REDDEDİLDİ: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Giriş bağlantı hatası: $e");
      return false;
    }
  }

  // 2. KAYIT OL (REGISTER)
  Future<bool> kayitOl(String adSoyad, String email, String sifre) async {
    try {
      print("Kayıt isteği atılıyor: $baseUrl/kayit");
      final response = await http.post(
        Uri.parse('$baseUrl/kayit'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
  "adSoyad": adSoyad,
  "eposta": email,
  "sifreHash": sifre,   // ← "sifre" değil, "sifreHash" olmalı
  "rol": "musteri"
}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("KAYIT BAŞARILI!");
        return true;
      } else {
        print("KAYIT HATASI (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("Kayıt bağlantı hatası: $e");
      return false;
    }
  }

  // Kayıtlı token'ı getir
  Future<String?> tokenGetir() async {
    final tercih = await SharedPreferences.getInstance();
    return tercih.getString('auth_token');
  }
}