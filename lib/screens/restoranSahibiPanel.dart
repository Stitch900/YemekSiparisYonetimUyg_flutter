import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // OTOMATİK YENİLEME İÇİN
import 'girisEkrani.dart';

class RestoranSahibiPanel extends StatefulWidget {
  @override
  _RestoranSahibiPanelState createState() => _RestoranSahibiPanelState();
}

class _RestoranSahibiPanelState extends State<RestoranSahibiPanel> {
  List<Map<String, dynamic>> urunler = [];
  Map<String, dynamic>? restoranBilgisi;
  int? aktifRestoranId;

  // Sipariş listesi başlangıçta boş, API'den dolacak
  List<Map<String, dynamic>> siparisler = [];

  Timer? _otomatikYenileyici; // ARKA PLAN RADARI

  Future<Map<String, String>> _headerOlustur() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // --- 1. AÇILIŞTA SIRAYLA YÜKLEME ---
  @override
  void initState() {
    super.initState();
    _tumVerileriSiraylaGetir();

    // HER 5 SANİYEDE BİR SİPARİŞLERİ KONTROL ET
    _otomatikYenileyici = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (aktifRestoranId != null) {
        _siparisleriGetir();
      }
    });
  }

  @override
  void dispose() {
    _otomatikYenileyici?.cancel(); // Sayfadan çıkınca radarı kapat
    super.dispose();
  }

  Future<void> _tumVerileriSiraylaGetir() async {
    await _restoranBilgisiniGetir();
    if (aktifRestoranId != null) {
      await _urunleriGetir();
      await _siparisleriGetir();
    }
  }

  // --- 2. RESTORANI DİNAMİK BUL ---
  Future<void> _restoranBilgisiniGetir() async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Restoranlar");
      var response = await http.get(url, headers: await _headerOlustur());

      if (response.statusCode == 200) {
        List asList = jsonDecode(response.body);
        if (asList.isNotEmpty) {
          setState(() {
            restoranBilgisi = asList.first; 
            aktifRestoranId = restoranBilgisi!["restoranId"] ?? restoranBilgisi!["id"];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hiç restoran bulunamadı. Lütfen Admin panelinden bir restoran ekleyin.")));
        }
      }
    } catch (e) {
      print("Restoran bilgisi getirilemedi: $e");
    }
  }

  // --- 3. RESTORAN BİLGİLERİNİ GÜNCELLE ---
  void _restoranBilgileriGuncelleDialog() {
    if (restoranBilgisi == null || aktifRestoranId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Restoranınız bulunamadı! Lütfen önce Admin panelinden bir restoran oluşturun.")));
      return;
    }

    final adController = TextEditingController(text: restoranBilgisi!["ad"] ?? "");
    final aciklamaController = TextEditingController(text: restoranBilgisi!["aciklama"] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Restoran Bilgilerimi Güncelle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: adController, decoration: const InputDecoration(labelText: "Restoran Adı")),
              TextField(controller: aciklamaController, decoration: const InputDecoration(labelText: "Açıklama / Slogan")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                var gidecekVeri = jsonEncode({
                  "restoranId": aktifRestoranId,
                  "ad": adController.text,
                  "aciklama": aciklamaController.text,
                  "adres": aciklamaController.text, // C# 'Adres' isteyebilir, garanti olsun.
                });

                var url = Uri.parse("http://localhost:5147/api/Restoranlar/$aktifRestoranId");
                var response = await http.put(url, headers: await _headerOlustur(), body: gidecekVeri);

                if (response.statusCode == 200 || response.statusCode == 204) {
                  Navigator.pop(context);
                  _restoranBilgisiniGetir(); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgileriniz güncellendi!"), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncelleme hatası."), backgroundColor: Colors.red));
                }
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  // --- 4. SADECE BU RESTORANA AİT ÜRÜNLERİ GETİR ---
  Future<void> _urunleriGetir() async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Menu/restoran/$aktifRestoranId");
      var response = await http.get(url, headers: await _headerOlustur());

      if (response.statusCode == 200) {
        setState(() {
          urunler = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  Future<void> _urunSil(int id) async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Menu/$id");
      var response = await http.delete(url, headers: await _headerOlustur());

      if (response.statusCode == 200) {
        setState(() => urunler.removeWhere((urun) => (urun["urunId"] ?? urun["id"]) == id));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ürün silindi."), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silme başarısız!"), backgroundColor: Colors.red));
      }
    } catch (e) {
      print(e);
    }
  }

  void _urunEkleGuncelleDialog({Map<String, dynamic>? urun}) {
    if (aktifRestoranId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Önce bir restoranınız olmalı!"), backgroundColor: Colors.red));
      return;
    }

    bool isGuncelleme = urun != null;
    final adController = TextEditingController(text: isGuncelleme ? urun!["ad"] : "");
    final fiyatController = TextEditingController(text: isGuncelleme ? urun!["fiyat"].toString() : "");
    final aciklamaController = TextEditingController(text: isGuncelleme ? urun!["aciklama"] : "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isGuncelleme ? "Ürün Güncelle" : "Yeni Ürün Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: adController, decoration: const InputDecoration(labelText: "Ürün Adı")),
                TextField(controller: fiyatController, decoration: const InputDecoration(labelText: "Fiyat (TL)"), keyboardType: TextInputType.number),
                TextField(controller: aciklamaController, decoration: const InputDecoration(labelText: "Açıklama")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                var gidecekVeri = jsonEncode({
                  if (isGuncelleme) "urunId": urun!["urunId"] ?? urun["id"],
                  "ad": adController.text,
                  "fiyat": double.tryParse(fiyatController.text) ?? 0.0,
                  "aciklama": aciklamaController.text,
                  "restoranId": aktifRestoranId
                });

                http.Response response;
                if (isGuncelleme) {
                  var url = Uri.parse("http://localhost:5147/api/Menu/${urun!["urunId"] ?? urun["id"]}");
                  response = await http.put(url, headers: await _headerOlustur(), body: gidecekVeri);
                } else {
                  var url = Uri.parse("http://localhost:5147/api/Menu");
                  response = await http.post(url, headers: await _headerOlustur(), body: gidecekVeri);
                }

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  _urunleriGetir();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bir hata oluştu."), backgroundColor: Colors.red));
                }
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  // --- 5. SİPARİŞLERİ API'DEN GETİR ---
  Future<void> _siparisleriGetir() async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Siparisler/restoran/$aktifRestoranId");
      var response = await http.get(url, headers: await _headerOlustur());

      if (response.statusCode == 200) {
        setState(() {
          siparisler = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      // Sessizce hatayı yut, çünkü 5 saniye sonra tekrar deneyecek
      // print("Sipariş getirme hatası: $e");
    }
  }

  // --- 6. SİPARİŞ DURUMU GÜNCELLE (API'YE GÖNDER) ---
  Future<void> _siparisDurumDegistir(int siparisId, String yeniDurum) async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Siparisler/$siparisId");
      
      var gidecekVeri = jsonEncode({
        "siparisId": siparisId,
        "durum": yeniDurum
      });

      var response = await http.put(url, headers: await _headerOlustur(), body: gidecekVeri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _siparisleriGetir(); // Başarılıysa listeyi anında yenile
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sipariş durumu '$yeniDurum' yapıldı!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Durum güncellenemedi!"), backgroundColor: Colors.red));
      }
    } catch (e) {
      print("Sipariş güncelleme hatası: $e");
    }
  }

  Future<void> _cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GirisEkrani()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(restoranBilgisi != null ? "${restoranBilgisi!["ad"]} Paneli" : "Restoran Sahibi Paneli", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(icon: const Icon(Icons.edit_note, color: Colors.white), tooltip: "Bilgilerimi Düzenle", onPressed: _restoranBilgileriGuncelleDialog),
            IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _cikisYap)
          ],
          bottom: const TabBar(
            labelColor: Colors.white, unselectedLabelColor: Colors.white70, indicatorColor: Colors.white,
            tabs: [Tab(icon: Icon(Icons.restaurant_menu), text: "Menüm"), Tab(icon: Icon(Icons.delivery_dining), text: "Siparişler")],
          ),
        ),
        body: TabBarView(children: [_buildUrunlerTab(), _buildSiparislerTab()]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _urunEkleGuncelleDialog(),
        ),
      ),
    );
  }

  Widget _buildUrunlerTab() {
    return urunler.isEmpty 
        ? const Center(child: Text("Menünüzde henüz bir ürün yok."))
        : ListView.builder(
            itemCount: urunler.length,
            itemBuilder: (context, index) {
              var urun = urunler[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.orange, size: 40),
                  title: Text(urun["ad"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${urun["aciklama"] ?? ""}\nFiyat: ${urun["fiyat"]} TL"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _urunEkleGuncelleDialog(urun: urun)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _urunSil(urun["urunId"] ?? urun["id"])),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildSiparislerTab() {
    return siparisler.isEmpty 
      ? const Center(child: Text("Şu an bekleyen siparişiniz yok."))
      : ListView.builder(
      itemCount: siparisler.length,
      itemBuilder: (context, index) {
        var siparis = siparisler[index];
        Color durumRengi = siparis["durum"] == "Teslim Edildi" ? Colors.green : (siparis["durum"] == "Yolda" ? Colors.blue : Colors.orange);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Müşteri" bilgisi C#'tan nasıl geliyorsa ona göre idare et
                Text("Sipariş #${siparis["siparisId"] ?? siparis["id"]} - ${siparis["musteri"] ?? "Müşteri"}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text("Tutar: ${siparis["toplamTutar"] ?? siparis["tutar"]} TL"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(label: Text(siparis["durum"] ?? "Bekliyor", style: const TextStyle(color: Colors.white)), backgroundColor: durumRengi),
                    Row(
                      children: [
                        if (siparis["durum"] == "Hazırlanıyor" || siparis["durum"] == "Bekliyor")
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), 
                            onPressed: () => _siparisDurumDegistir(siparis["siparisId"] ?? siparis["id"], "Yolda"), 
                            child: const Text("Yola Çıkar", style: TextStyle(color: Colors.white))
                          ),
                        if (siparis["durum"] == "Yolda")
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
                            onPressed: () => _siparisDurumDegistir(siparis["siparisId"] ?? siparis["id"], "Teslim Edildi"), 
                            child: const Text("Teslim Et", style: TextStyle(color: Colors.white))
                          ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}