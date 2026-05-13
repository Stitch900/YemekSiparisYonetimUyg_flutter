 import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart'; // Hafızadan ID çekmek için şart

import 'package:uyg_yemek_siparis/models/yorumlar.dart';

import '../services/kimlikDogrulama.dart';

import '../models/restoran.dart';

import '../models/urunler.dart';

import '../models/siparislerVeDetaylar.dart';


class ApiVeriCekme {

  static const String baseUrl = "http://localhost:5147/api";


  // 1. RESTORANLARI LİSTELE (GET)

  Future<List<Restoran>> restoranlariGetir() async {

    try {

      final response = await http.get(Uri.parse('$baseUrl/Restoranlar'));

      if (response.statusCode == 200) {

        List<dynamic> veri = json.decode(response.body);

        return veri.map((json) => Restoran.fromJson(json)).toList();

      }

      return [];

    } catch (e) {

      throw Exception("Bağlantı hatası: $e");

    }

  }


  // 2. SEÇİLEN RESTORANIN MENÜSÜNÜ GETİR (GET)

  Future<List<Urun>> menuyuGetir(int restoranId) async {

    try {

      final response = await http.get(Uri.parse('$baseUrl/Menu/restoran/$restoranId'));

      if (response.statusCode == 200) {

        List<dynamic> veri = json.decode(response.body);

        return veri.map((json) => Urun.fromJson(json)).toList();

      }

      return [];

    } catch (e) {

      throw Exception("Menü hatası: $e");

    }

  }


  // 3. YENİ SİPARİŞ OLUŞTUR (POST)

  Future<bool> siparisGonder(Siparis yeniSiparis) async {

    try {

      final authServis = KimlikDogrulamaServisi();

      String? token = await authServis.tokenGetir();

     

      // KRİTİK DÜZELTME: Hafızadaki gerçek giriş yapan kullanıcı ID'sini alıyoruz

      final prefs = await SharedPreferences.getInstance();

      int gercekId = prefs.getInt('kullaniciId') ?? yeniSiparis.kullaniciId;


      final response = await http.post(

        Uri.parse('$baseUrl/Siparis'),

        headers: {

          "Content-Type": "application/json",

          "Authorization": "Bearer $token",

        },

        body: json.encode({

          "kullaniciId": gercekId, // Statik 1 değil, gerçek ID gidiyor

          "restoranId": yeniSiparis.restoranId,

          "toplamTutar": yeniSiparis.toplamTutar,

          "durum": yeniSiparis.durum,

          "tarih": yeniSiparis.tarih.toIso8601String(),

          "siparisDetaylari": yeniSiparis.detaylar?.map((d) => {

            "yemekId": d.yemekId,

            "adet": d.adet,

            "birimFiyat": d.birimFiyat

          }).toList(),

        }),

      );


      return response.statusCode == 201 || response.statusCode == 200;

    } catch (e) {

      return false;

    }

  }


  // 4. SİPARİŞ GEÇMİŞİNİ GETİR (GET)

  Future<List<Siparis>> siparisGecmisiGetir(int kullaniciId) async {

    try {

      final authServis = KimlikDogrulamaServisi();

      String? token = await authServis.tokenGetir();

     

      final response = await http.get(

        Uri.parse('$baseUrl/Siparis/Müşteri/$kullaniciId'),

        headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},

      );


      if (response.statusCode == 200) {

        List<dynamic> veri = json.decode(response.body);

        return veri.map((json) => Siparis.fromJson(json)).toList();

      }

      return [];

    } catch (e) {

      return [];

    }

  }


 // 5. KULLANICI BİLGİLERİNİ GÜNCELLE (PUT)

  Future<bool> kullaniciGuncelle(int id, String adSoyad, String eposta) async {

    try {

      final authServis = KimlikDogrulamaServisi();

      String? token = await authServis.tokenGetir();


      // C# AuthController içindeki [HttpPut("guncelle/{id}")] metoduna gidiyoruz

      final response = await http.put(

        Uri.parse('$baseUrl/Auth/guncelle/$id'),

        headers: {

          "Content-Type": "application/json",

          "Authorization": "Bearer $token"

        },

        body: json.encode({

          "kullaniciId": id,

          "adSoyad": adSoyad,

          "eposta": eposta,

        }),

      );

     

      // Hata ayıklama için C#'tan dönen cevabı konsola yazdıralım

      print("GÜNCELLEME CEVABI (${response.statusCode}): ${response.body}");

     

      return response.statusCode == 200 || response.statusCode == 204;

    } catch (e) {

      print("Güncelleme hatası: $e");

      return false;

    }

  }


  // 6. ŞİFRE DEĞİŞTİR (POST)

  Future<bool> sifreDegistir(int id, String eskiSifre, String yeniSifre) async {

    try {

      final authServis = KimlikDogrulamaServisi();

      String? token = await authServis.tokenGetir();


      final response = await http.post(

        Uri.parse('$baseUrl/Auth/sifre-degistir'),

        headers: {

          "Content-Type": "application/json",

          "Authorization": "Bearer $token"

        },

        body: json.encode({

          "kullaniciId": id,

          "eskiSifre": eskiSifre,

          "yeniSifre": yeniSifre

        }),

      );

     

      print("ŞİFRE DEĞİŞTİRME CEVABI: ${response.statusCode} - ${response.body}");

      return response.statusCode == 200;

    } catch (e) {

      print("Şifre değiştirme hatası: $e");

      return false;

    }

  }


  // --- YORUM VE PUAN SİSTEMİ ---


  // 1. Yorumları Getir (İster restoranın, ister ürünün)

  Future<List<Yorum>> yorumlariGetir({int? restoranId, int? urunId}) async {

    try {

      // Backend'deki route yapına göre burası değişebilir

      String url = restoranId != null

          ? '$baseUrl/Yorumlar/restoran/$restoranId'

          : '$baseUrl/Yorumlar/urun/$urunId';


      final response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {

        List<dynamic> veri = json.decode(response.body);

        return veri.map((json) => Yorum.fromJson(json)).toList();

      }

      return [];

    } catch (e) {

      print("Yorum çekme hatası: $e");

      return [];

    }

  }


  // 2. Yeni Yorum ve Puan Gönder

  Future<bool> yorumGonder(int kullaniciId, int? restoranId, int? urunId, int puan, String metin) async {

  try {

    final authServis = KimlikDogrulamaServisi();

    String? token = await authServis.tokenGetir();

   

    print("🔑 YORUM TOKEN: $token");  // ← ekle

   

    final response = await http.post(

      Uri.parse('$baseUrl/Yorumlar'),

      headers: {

        "Content-Type": "application/json",

        "Authorization": "Bearer $token"

      },

      body: json.encode({

  "kullaniciId": kullaniciId,

  "restoranId": restoranId,

  "puan": puan,

  "metin": metin

}),

    );


    print("📡 YORUM STATUS: ${response.statusCode}");  // ← ekle

    print("📡 YORUM RESPONSE: ${response.body}");       // ← ekle


    return response.statusCode == 200 || response.statusCode == 201;

  } catch (e) {

    print("Yorum gönderme hatası: $e");

    return false;

  }

}



  Future<double> puanOrtalamasiGetir(int restoranId) async {

  try {

    final response = await http.get(

      Uri.parse('$baseUrl/Yorumlar/restoran/$restoranId/ortalama'),

    );

    if (response.statusCode == 200) {

      return double.tryParse(response.body) ?? 0.0;

    }

    return 0.0;

  } catch (e) {

    return 0.0;

  }

}

} 