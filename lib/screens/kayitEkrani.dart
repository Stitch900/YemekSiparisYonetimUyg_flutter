import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'girisEkrani.dart';

class KayitEkrani extends StatefulWidget {
  @override
  _KayitEkraniState createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _adController = TextEditingController();
  final _epostaController = TextEditingController();
  final _sifreController = TextEditingController();
  
  bool _sifreGoster = false;
  
  bool _islemSuruyor = false; // Kullanıcı butona basınca dönen loading efekti için

  // Staj için şov noktası: Rol Seçimi
  String _secilenRol = "Müşteri"; 
  final List<String> _roller = ["Müşteri", "Restoran Sahibi", "Admin"];

  Future<void> _kayitOl() async {
    // 1. Alanların boş olup olmadığını kontrol et
    if (_adController.text.trim().isEmpty || _epostaController.text.trim().isEmpty || _sifreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!"), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() { _islemSuruyor = true; }); // Yükleniyor animasyonunu başlat

    try {
      // DİKKAT: Android emülatör üzerinden test ediyorsan localhost adresi 10.0.2.2 olmalıdır.
      // Kendi fiziksel telefonundan deniyorsan bilgisayarının Wi-Fi IPv4 adresini yazmalısın.
      var url = Uri.parse("http://localhost:5147/api/Auth/kayit"); // Kayıt için de /kayit olanı yap

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "adSoyad": _adController.text.trim(),
          "eposta": _epostaController.text.trim(),
          "sifreHash": _sifreController.text.trim(), // C# modelinde isim farklıysa burayı düzelt (örn: sadece "sifre")
          "rol": _secilenRol
        }),
      );

      setState(() { _islemSuruyor = false; }); // İşlem bitti, animasyonu durdur

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$_secilenRol olarak kaydoldunuz."), backgroundColor: Colors.green)
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GirisEkrani()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kayıt hatası: ${response.body}"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      setState(() { _islemSuruyor = false; });
      print("Bağlantı Hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sunucuya bağlanılamadı. API çalışıyor mu?"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Yeni Hesap Oluştur", style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                TextField(controller: _adController, decoration: const InputDecoration(labelText: "Ad Soyad", border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _epostaController, decoration: const InputDecoration(labelText: "E-Posta", border: OutlineInputBorder())),
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
                const SizedBox(height: 15),
                
                // --- ROL SEÇİMİ (DROPDOWN) ---
                DropdownButtonFormField<String>(
                  value: _secilenRol,
                  decoration: const InputDecoration(labelText: "Hesap Türü", border: OutlineInputBorder()),
                  items: _roller.map((String rol) {
                    return DropdownMenuItem<String>(
                      value: rol,
                      child: Text(
                        rol == "Müşteri" ? "Müşteri" : 
                        rol == "Restoran Sahibi" ? "Restoran Sahibi" : "Yönetici (Admin)"
                      ),
                    );
                  }).toList(),
                  onChanged: (yeniDeger) {
                    setState(() { _secilenRol = yeniDeger!; });
                  },
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: _islemSuruyor ? null : _kayitOl, // İşlem sürerken butonu kilitle
                    child: _islemSuruyor
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Kayıt Ol", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GirisEkrani())),
                  child: const Text("Zaten hesabın var mı? Giriş Yap", style: TextStyle(color: Colors.orange)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}