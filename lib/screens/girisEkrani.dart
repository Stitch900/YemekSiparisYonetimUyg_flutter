 import 'anasayfaEkrani.dart';

import 'restoranSahibiPanel.dart';

import 'adminPanel.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'kayitEkrani.dart';


class GirisEkrani extends StatefulWidget {

  @override

  _GirisEkraniState createState() => _GirisEkraniState();

 

}


class _GirisEkraniState extends State<GirisEkrani> {

 

  final _epostaController = TextEditingController();

  final _sifreController = TextEditingController();

bool _sifreGoster = false;

  bool _islemSuruyor = false;


  Future<void> _girisYap() async {

    print("🚀 GİRİŞ BUTONUNA TIKLANDI!");


    if (_epostaController.text.trim().isEmpty ||

        _sifreController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Lütfen e-posta ve şifrenizi girin!"),

          backgroundColor: Colors.red,

        ),

      );

      return;

    }


    setState(() => _islemSuruyor = true);


    try {

      var url = Uri.parse("http://localhost:5147/api/Auth/giris");


      print("📡 API İSTEĞİ GÖNDERİLİYOR...");

      print(url);


      var response = await http

          .post(

            url,

            headers: {"Content-Type": "application/json"},

            body: jsonEncode({

              "eposta": _epostaController.text.trim(),

              "sifre": _sifreController.text.trim(),

            }),

          )

          .timeout(const Duration(seconds: 20));


      print("✅ STATUS CODE: ${response.statusCode}");

      print("✅ RESPONSE BODY: ${response.body}");


      setState(() => _islemSuruyor = false);


      if (response.statusCode == 200) {

        var data = jsonDecode(response.body);


        String token = data['token'] ?? "";

        String rol = data['rol'] ?? "";

        int id = data['id'] ?? 0;

        String adSoyad = data['adSoyad'] ?? "";

        String eposta = data['eposta'] ?? "";


        print("🎫 TOKEN: $token");

        print("👤 ROL: $rol");


        // Tüm kullanıcı bilgilerini kaydet

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);

        await prefs.setString('auth_token', token); // KimlikDogrulamaServisi uyumu

        await prefs.setString('kullanici_rolu', rol);

        await prefs.setInt('kullaniciId', id);

        await prefs.setString('adSoyad', adSoyad);

        await prefs.setString('eposta', eposta);


        // ✅ DÜZELTME: C# "musteri" döndürüyor, "customer" değil

        // --- ROLA GÖRE FARKLI SAYFALARA YÖNLENDİRME ---

        if (rol == "Müşteri") {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(builder: (context) => AnasayfaEkrani()),

          );

        } else if (rol == "Restoran Sahibi") {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text("Restoran paneline giriliyor..."),

              backgroundColor: Colors.blue,

            ),

          );

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(builder: (context) => RestoranSahibiPanel())

          );

        } else if (rol == "Admin") {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text("Admin paneline giriliyor..."),

              backgroundColor: Colors.purple,

            ),

          );

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(builder: (context) => AdminPanel())

          );

        } else {

          // Bilinmeyen rol — yine de anasayfaya gönder

          print("⚠️ Bilinmeyen rol: $rol — anasayfaya yönlendiriliyor");

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(builder: (context) => AnasayfaEkrani()),

          );

        }

      } else {

        print("❌ HATALI STATUS: ${response.statusCode}");

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text("Giriş başarısız: ${response.body}"),

            backgroundColor: Colors.red,

          ),

        );

      }

    } catch (e) {

      setState(() => _islemSuruyor = false);

      print("🔥 BAĞLANTI HATASI: $e");

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text("Hata oluştu: $e"),

          backgroundColor: Colors.red,

        ),

      );

    }

  }


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.orangeAccent,

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(15),

              boxShadow: const [

                BoxShadow(color: Colors.black26, blurRadius: 10)

              ],

            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const Icon(Icons.fastfood, size: 100, color: Colors.orange),

                const SizedBox(height: 10),

                const Text(

                  "Yemek Sipariş Sistemi",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

                ),

                const SizedBox(height: 20),

                TextField(

                  controller: _epostaController,

                  decoration: const InputDecoration(

                    labelText: "E-Posta",

                    border: OutlineInputBorder(),

                    prefixIcon: Icon(Icons.email),

                  ),

                ),

                const SizedBox(height: 15),

               TextField(

  controller: _sifreController,


  obscureText: !_sifreGoster,


  decoration: InputDecoration(

    labelText: "Şifre",


    border: const OutlineInputBorder(),


    prefixIcon: const Icon(Icons.lock),


    suffixIcon: IconButton(

      icon: Icon(

        _sifreGoster

            ? Icons.visibility

            : Icons.visibility_off,

      ),


      onPressed: () {

        setState(() {

          _sifreGoster = !_sifreGoster;

        });

      },

    ),

  ),

),

                const SizedBox(height: 20),

                SizedBox(

                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.orange,

                    ),

                    onPressed: _islemSuruyor ? null : _girisYap,

                    child: _islemSuruyor

                        ? const SizedBox(

                            width: 24,

                            height: 24,

                            child: CircularProgressIndicator(

                              color: Colors.white,

                              strokeWidth: 2,

                            ),

                          )

                        : const Text(

                            "Giriş Yap",

                            style: TextStyle(fontSize: 18, color: Colors.white),

                          ),

                  ),

                ),

                TextButton(

                  onPressed: () {

                    Navigator.pushReplacement(

                      context,

                      MaterialPageRoute(builder: (context) => KayitEkrani()),

                    );

                  },

                  child: const Text(

                    "Hesabın yok mu? Kayıt Ol",

                    style: TextStyle(color: Colors.orange),

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

} 