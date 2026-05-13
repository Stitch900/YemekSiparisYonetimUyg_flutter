 import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


import 'package:uyg_yemek_siparis/screens/profilEkrani.dart';

import 'package:uyg_yemek_siparis/screens/girisEkrani.dart';


import '../services/apiVeriCekme.dart';

import '../models/restoran.dart';

import '../widgets/restoranKutusu.dart';

import '../logic/sepetKontrol.dart';

import 'restoranDetayEkrani.dart';

import 'sepetEkrani.dart';


class AnasayfaEkrani extends StatefulWidget {

  @override

  _AnasayfaEkraniState createState() => _AnasayfaEkraniState();

}


class _AnasayfaEkraniState extends State<AnasayfaEkrani> {

  final _apiServis = ApiVeriCekme();


  // --- VERİ VE ARAMA YÖNETİMİ ---

  List<Restoran> _tumRestoranlar = [];

  List<Restoran> _filtrelenmisRestoranlar = [];


  final TextEditingController _aramaController =

      TextEditingController();


  bool _yukleniyor = true;
  // Restoran ID'lerini ve Puanlarını eşleştirip tutacağımız sözlük (Map)
  Map<int, double> restoranPuanlari = {};
  bool _yuksektenDusuge = true; // Sıralama yönünü takip edecek (Varsayılan: Büyükten küçüğe)


  @override

  void initState() {

    super.initState();

    _verileriGetir();

  }


  // API'DEN VERİLERİ ÇEK

  // API'DEN VERİLERİ ÇEK VE PUANA GÖRE SIRALA
  // 1. API'DEN VERİLERİ ÇEK
  Future<void> _verileriGetir() async {
    try {
      final data = await _apiServis.restoranlariGetir();

      for (var restoran in data) {
        // Not: Senin modelinde id değişkeni "restoranId" ise restoran.restoranId yaz.
        int id = restoran.restoranId; 
        double puan = await _apiServis.puanOrtalamasiGetir(id);
        restoranPuanlari[id] = puan;
      }

      setState(() {
        _tumRestoranlar = data;
        _filtrelenmisRestoranlar = List.from(data); 
        _listeyiSirala(); // Veri gelir gelmez ilk sıralamayı yap
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() => _yukleniyor = false);
      print("Hata: $e");
    }
  }

  // 2. LİSTEYİ DİZME MOTORU
  void _listeyiSirala() {
    _filtrelenmisRestoranlar.sort((a, b) {
      double puanA = restoranPuanlari[a.restoranId] ?? 0.0;
      double puanB = restoranPuanlari[b.restoranId] ?? 0.0;
      
      if (_yuksektenDusuge) {
        return puanB.compareTo(puanA); // Büyükten küçüğe (5 -> 1)
      } else {
        return puanA.compareTo(puanB); // Küçükten büyüğe (1 -> 5)
      }
    });
  }

  // 3. BUTONA BASILINCA ÇALIŞACAK TETİKLEYİCİ
  void _siralamayiDegistir() {
    setState(() {
      _yuksektenDusuge = !_yuksektenDusuge; // Yönü tersine çevir (True ise False yap)
      _listeyiSirala(); // Listeyi yeni yöne göre anında tekrar diz
    });
  }

  // ARAMA

  void _aramaYap(String aranan) {

    setState(() {

      _filtrelenmisRestoranlar = _tumRestoranlar

          .where(

            (r) => r.ad

                .toLowerCase()

                .contains(aranan.toLowerCase()),

          )

          .toList();

    });

  }


  // SİPARİŞ DURUMU İLERLET

  void _durumuIlerlet() {

    setState(() {

      if (SepetKontrol.aktifSiparisDurumu!

          .contains("Hazırlanıyor")) {

        SepetKontrol.aktifSiparisDurumu =

            "Sipariş Yolda 🛵";

      } else if (SepetKontrol.aktifSiparisDurumu!

          .contains("Yolda")) {

        SepetKontrol.aktifSiparisDurumu =

            "Teslim Edildi ✅";

      } else {

        SepetKontrol.aktifSiparisDurumu = null;

      }

    });

  }


  // ÇIKIŞ YAP

  Future<void> _cikisYap() async {

    final prefs = await SharedPreferences.getInstance();


    await prefs.remove("token");


    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (context) => GirisEkrani(),

      ),

      (route) => false,

    );

  }


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Restoranlar",

          style: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,

          ),

        ),


        backgroundColor: Colors.orange,


        leading: IconButton(

          icon: const Icon(

            Icons.account_circle,

            size: 30,

            color: Colors.white,

          ),

          onPressed: () => Navigator.push(

            context,

            MaterialPageRoute(

              builder: (context) => ProfilEkrani(),

            ),

          ),

        ),


        actions: [

          // ÇIKIŞ BUTONU

          IconButton(

            icon: const Icon(

              Icons.logout,

              color: Colors.white,

            ),

            onPressed: _cikisYap,

          ),


          // SEPET BUTONU

          IconButton(

            icon: const Icon(

              Icons.shopping_cart,

              color: Colors.white,

            ),

            onPressed: () async {

              await Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (context) => SepetEkrani(),

                ),

              );


              print(

                "🔵 ANASAYFA setState ÇAĞRILDI, durum: ${SepetKontrol.aktifSiparisDurumu}",

              );


              setState(() {});

            },

          ),

        ],

      ),


      body: _yukleniyor

          ? const Center(

              child: CircularProgressIndicator(

                color: Colors.orange,

              ),

            )

          : Column(

              children: [

                // ARAMA KUTUSU

               // ARAMA VE SIRALAMA KUTUSU
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Arama Çubuğu
                      Expanded(
                        child: TextField(
                          controller: _aramaController,
                          onChanged: _aramaYap,
                          decoration: InputDecoration(
                            hintText: "Restoran ara...",
                            prefixIcon: const Icon(Icons.search, color: Colors.orange),
                            suffixIcon: _aramaController.text.isNotEmpty 
                              ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _aramaController.clear(); _aramaYap(""); }) 
                              : null,
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // O MEŞHUR SIRALAMA BUTONU
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          // Yöne göre ikon değişecek (Aşağı Ok / Yukarı Ok)
                          icon: Icon(
                            _yuksektenDusuge ? Icons.arrow_upward : Icons.arrow_downward, 
                            color: Colors.white
                          ),
                          onPressed: _siralamayiDegistir,
                          tooltip: "Puana Göre Sırala",
                        ),
                      ),
                    ],
                  ),
                ),


                // SİPARİŞ DURUM KUTUSU

                if (SepetKontrol.aktifSiparisDurumu != null)

                  GestureDetector(

                    onTap: _durumuIlerlet,


                    child: Container(

                      width: double.infinity,


                      margin: const EdgeInsets.symmetric(

                        horizontal: 10,

                        vertical: 5,

                      ),


                      padding: const EdgeInsets.symmetric(

                        vertical: 15,

                        horizontal: 20,

                      ),


                      decoration: BoxDecoration(

                        color: Colors.green.shade100,


                        borderRadius:

                            BorderRadius.circular(10),


                        border: Border.all(

                          color: Colors.green.shade500,

                          width: 2,

                        ),

                      ),


                      child: Row(

                        mainAxisAlignment:

                            MainAxisAlignment.spaceBetween,


                        children: [

                          const Icon(

                            Icons.info_outline,

                            color: Colors.green,

                          ),


                          Text(

                            SepetKontrol

                                .aktifSiparisDurumu!,


                            style: TextStyle(

                              fontSize: 16,

                              fontWeight: FontWeight.bold,

                              color:

                                  Colors.green.shade800,

                            ),

                          ),


                          const Icon(

                            Icons.arrow_forward_ios,

                            color: Colors.green,

                            size: 16,

                          ),

                        ],

                      ),

                    ),

                  ),


                // RESTORAN LİSTESİ

                Expanded(

                  child: _filtrelenmisRestoranlar.isEmpty

                      ? const Center(

                          child: Text(

                            "Sonuç bulunamadı.",

                          ),

                        )

                      : ListView.builder(

                          itemCount:

                              _filtrelenmisRestoranlar

                                  .length,


                          itemBuilder: (context, index) {

                            return RestoranKutusu(

                              restoran:

                                  _filtrelenmisRestoranlar[

                                      index],


                              onTap: () async {

                                await Navigator.push(

                                  context,


                                  MaterialPageRoute(

                                    builder: (context) =>

                                        RestoranDetayEkrani(

                                      restoran:

                                          _filtrelenmisRestoranlar[

                                              index],

                                    ),

                                  ),

                                );


                                setState(() {});

                              },

                            );

                          },

                        ),

                ),

              ],

            ),

    );

  }

} 