import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MenuYonetimi extends StatefulWidget {
  final int restoranId;
  final String restoranAdi;

  // Admin panelinden tıklanan restoranın ID'sini bu sayede içeri alıyoruz
  const MenuYonetimi({Key? key, required this.restoranId, required this.restoranAdi}) : super(key: key);

  @override
  _MenuYonetimiState createState() => _MenuYonetimiState();
}

class _MenuYonetimiState extends State<MenuYonetimi> {
  List<Map<String, dynamic>> urunler = [];

  Future<Map<String, String>> _headerOlustur() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // SADECE İÇİNE GİRDİĞİMİZ RESTORANIN ÜRÜNLERİNİ GETİRİR
  Future<void> _urunleriGetir() async {
    try {
      var url = Uri.parse("http://localhost:5147/api/Menu/restoran/${widget.restoranId}");
      var response = await http.get(url, headers: await _headerOlustur());

      if (response.statusCode == 200) {
        setState(() {
          urunler = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      print("Menü hatası: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
  }

  Future<void> _urunSil(int id) async {
    var url = Uri.parse("http://localhost:5147/api/Menu/$id");
    var response = await http.delete(url, headers: await _headerOlustur());
    if (response.statusCode == 200) {
      setState(() => urunler.removeWhere((urun) => (urun["urunId"] ?? urun["id"]) == id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ürün silindi."), backgroundColor: Colors.green));
    }
  }

  void _urunEkleGuncelleDialog({Map<String, dynamic>? urun}) {
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                // DİKKAT: Ürün eklerken 1 numaraya değil, widget.restoranId'ye (yani tıkladığın restorana) ekliyor!
                var gidecekVeri = jsonEncode({
                  if (isGuncelleme) "urunId": urun!["urunId"] ?? urun["id"],
                  "ad": adController.text,
                  "fiyat": double.tryParse(fiyatController.text) ?? 0.0,
                  "aciklama": aciklamaController.text,
                  "restoranId": widget.restoranId 
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menüye Eklendi!"), backgroundColor: Colors.green));
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red));
                }
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.restoranAdi} Menüsü", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: urunler.isEmpty
          ? const Center(child: Text("Bu restoranda henüz ürün yok."))
          : ListView.builder(
              itemCount: urunler.length,
              itemBuilder: (context, index) {
                var urun = urunler[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.fastfood, color: Colors.purple, size: 40),
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
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _urunEkleGuncelleDialog(),
      ),
    );
  }
}