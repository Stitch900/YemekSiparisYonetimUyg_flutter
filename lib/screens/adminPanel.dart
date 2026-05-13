import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'girisEkrani.dart';
import 'menuYonetimi.dart';
 
class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}
 
class _AdminPanelState extends State<AdminPanel> {
  List<Map<String, dynamic>> restoranlar = [];
  List<Map<String, dynamic>> siparisler = [
    {"id": 101, "musteri": "Ali Yılmaz", "tutar": 300.0, "durum": "Hazırlanıyor"},
  ];
 
  @override
  void initState() {
    super.initState();
    _restoranlariGetir();
  }
 
  Future<Map<String, String>> _headerOlustur() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }
 
  Future<void> _restoranlariGetir() async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Restoranlar");
      var response = await http.get(url, headers: await _headerOlustur());
      if (response.statusCode == 200) {
        setState(() => restoranlar =
            List<Map<String, dynamic>>.from(jsonDecode(response.body)));
      }
    } catch (e) {
      print("Restoran getirme hatası: $e");
    }
  }
 
  Future<void> _restoranSil(int id) async {
    var url = Uri.parse("http://localhost:5147/api/Restoranlar/$id");
    var response =
        await http.delete(url, headers: await _headerOlustur());
    if (response.statusCode == 200) {
      setState(() =>
          restoranlar.removeWhere((r) => (r["restoranId"] ?? r["id"]) == id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Restoran silindi."),
          backgroundColor: Colors.green));
    }
  }
 
  void _restoranEkleGuncelleDialog({Map<String, dynamic>? restoran}) {
    bool isGuncelleme = restoran != null;
 
    final adController =
        TextEditingController(text: isGuncelleme ? restoran!["ad"] ?? "" : "");
    final logoUrlController = TextEditingController(
        text: isGuncelleme ? restoran!["logoUrl"] ?? "" : "");
    final adresController = TextEditingController(
        text: isGuncelleme ? restoran!["adres"] ?? "" : "");
    final puanController = TextEditingController(
        text: isGuncelleme
            ? (restoran!["puan"] != null
                ? restoran["puan"].toString()
                : "")
            : "");
    final aciklamaController = TextEditingController(
        text: isGuncelleme ? restoran!["aciklama"] ?? "" : "");
 
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              isGuncelleme ? "Restoran Güncelle" : "Yeni Restoran Ekle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Restoran Adı
                TextField(
                  controller: adController,
                  decoration:
                      const InputDecoration(labelText: "Restoran Adı *"),
                ),
                const SizedBox(height: 8),
 
                // Logo URL
                TextField(
                  controller: logoUrlController,
                  decoration: const InputDecoration(
                    labelText: "Logo URL",
                    hintText: "https://example.com/logo.png",
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),
 
                // Logo önizleme
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: logoUrlController,
                  builder: (context, value, child) {
                    final url = value.text.trim();
                    if (url.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text(
                            "Geçersiz logo URL",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
 
                // Adres
                TextField(
                  controller: adresController,
                  decoration:
                      const InputDecoration(labelText: "Adres *"),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
 
                // Puan (0.0 - 5.0)
                TextField(
                  controller: puanController,
                  decoration: const InputDecoration(
                    labelText: "Puan (0.0 - 5.0)",
                    hintText: "Örn: 4.5",
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
 
                // Açıklama
                TextField(
                  controller: aciklamaController,
                  decoration:
                      const InputDecoration(labelText: "Açıklama"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal")),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                // Zorunlu alan kontrolü
                if (adController.text.trim().isEmpty ||
                    adresController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Ad ve Adres zorunludur."),
                      backgroundColor: Colors.orange));
                  return;
                }
 
                int? resId = isGuncelleme
                    ? (restoran!["restoranId"] ?? restoran["id"])
                    : null;
 
                // Puanı double'a çevir
                double? puan = double.tryParse(puanController.text.trim());
 
                var gidecekVeri = jsonEncode({
                  if (isGuncelleme) "restoranId": resId,
                  "ad": adController.text.trim(),
                  "logoUrl": logoUrlController.text.trim().isEmpty
                      ? null
                      : logoUrlController.text.trim(),
                  "adres": adresController.text.trim(),
                  "puan": puan,
                  "aciklama": aciklamaController.text.trim().isEmpty
                      ? null
                      : aciklamaController.text.trim(),
                });
 
                http.Response response;
                if (isGuncelleme) {
                  var url = Uri.parse(
                      "http://localhost:5147/api/Restoranlar/$resId");
                  response = await http.put(url,
                      headers: await _headerOlustur(), body: gidecekVeri);
                } else {
                  var url =
                      Uri.parse("http://localhost:5147/api/Restoranlar");
                  response = await http.post(url,
                      headers: await _headerOlustur(), body: gidecekVeri);
                }
 
                if (response.statusCode == 200 ||
                    response.statusCode == 201) {
                  Navigator.pop(context);
                  _restoranlariGetir();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Kayıt başarılı!"),
                      backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Hata: ${response.statusCode} - ${response.body}"),
                      backgroundColor: Colors.red));
                }
              },
              child:
                  const Text("Kaydet", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
 
  Future<void> _cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => GirisEkrani()));
  }
 
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Yönetici Paneli",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _cikisYap)
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.store), text: "Restoranlar"),
              Tab(icon: Icon(Icons.list_alt), text: "Tüm Siparişler"),
            ],
          ),
        ),
        body: TabBarView(
            children: [_buildRestoranlarTab(), _buildSiparislerTab()]),
      ),
    );
  }
 
  Widget _buildRestoranlarTab() {
    return Scaffold(
      body: ListView.builder(
        itemCount: restoranlar.length,
        itemBuilder: (context, index) {
          var restoran = restoranlar[index];
          int resId = restoran["restoranId"] ?? restoran["id"] ?? 0;
          String? logoUrl = restoran["logoUrl"];
          double? puan = restoran["puan"] != null
              ? double.tryParse(restoran["puan"].toString())
              : null;
 
          return Card(
            margin:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuYonetimi(
                        restoranId: resId,
                        restoranAdi: restoran["ad"] ?? "Restoran"),
                  ),
                );
              },
              // Logo varsa göster, yoksa varsayılan ikon
              leading: logoUrl != null && logoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront,
                            color: Colors.purple,
                            size: 40),
                      ),
                    )
                  : const Icon(Icons.storefront,
                      color: Colors.purple, size: 40),
              title: Row(
                children: [
                  Expanded(
                    child: Text(restoran["ad"] ?? "İsimsiz",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // Puan rozeti
                  if (puan != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(puan.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                "${restoran["adres"] ?? ""}"
                "${restoran["aciklama"] != null && restoran["aciklama"].isNotEmpty ? "\n${restoran["aciklama"]}" : ""}",
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _restoranEkleGuncelleDialog(restoran: restoran)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _restoranSil(resId)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _restoranEkleGuncelleDialog(),
      ),
    );
  }
 
  Widget _buildSiparislerTab() {
    return ListView.builder(
      itemCount: siparisler.length,
      itemBuilder: (context, index) {
        var siparis = siparisler[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading:
                const Icon(Icons.delivery_dining, color: Colors.blue),
            title: Text(
                "Sipariş #${siparis["id"]} - ${siparis["musteri"]}"),
            subtitle: Text(
                "Tutar: ${siparis["tutar"]} TL - Durum: ${siparis["durum"]}"),
          ),
        );
      },
    );
  }
}
