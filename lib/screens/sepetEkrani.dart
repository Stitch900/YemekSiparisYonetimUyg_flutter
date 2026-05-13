 import 'package:flutter/material.dart';

import '../logic/sepetKontrol.dart';

import '../services/apiVeriCekme.dart';

import '../models/siparislerVeDetaylar.dart';


class SepetEkrani extends StatefulWidget {

  @override

  _SepetEkraniState createState() => _SepetEkraniState();

}


class _SepetEkraniState extends State<SepetEkrani> {

  final _apiServis = ApiVeriCekme();

  bool _islemSuruyor = false;


void _odemeYap() async {

  if (SepetKontrol.sepetListesi.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sepetiniz boş!")));

    return;

  }


  setState(() { _islemSuruyor = true; });


  await Future.delayed(const Duration(seconds: 2));


  final restoranId = SepetKontrol.sepetListesi.first.restoranId;

  Siparis yeniSiparis = Siparis(

    siparisId: 0,

    kullaniciId: 1,

    restoranId: restoranId,

    toplamTutar: SepetKontrol.toplamTutar,

    durum: "Hazırlanıyor",

    tarih: DateTime.now(),

    detaylar: SepetKontrol.sepetListesi.map((urun) => SiparisDetay(

      yemekId: urun.yemekId,

      adet: 1,

      birimFiyat: urun.fiyat

    )).toList(),

  );


  bool sonuc = await _apiServis.siparisGonder(yeniSiparis);


  setState(() { _islemSuruyor = false; });


  if (sonuc) {

    SepetKontrol.aktifSiparisDurumu = "Sipariş Hazırlanıyor 👨‍🍳";

    print("🟢 DURUM SET EDİLDİ: ${SepetKontrol.aktifSiparisDurumu}");

   

    Navigator.pop(context, true); // ← ÖNCE çık

    SepetKontrol.temizle();       // ← SONRA temizle

   

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text("Ödeme Tamamlandı!"), backgroundColor: Colors.green),

    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text("Ödeme başarısız oldu!"), backgroundColor: Colors.red),

    );

  }

}


  @override

  Widget build(BuildContext context) {

    final sepet = SepetKontrol.sepetListesi;


    return Scaffold(

      appBar: AppBar(title: const Text("Sepet & Ödeme", style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),

      body: sepet.isEmpty

          ? const Center(child: Text("Sepetiniz şu an boş.", style: TextStyle(fontSize: 18)))

          : ListView(

              padding: const EdgeInsets.all(15),

              children: [

                // 1. SEPET LİSTESİ

                const Text("Sipariş Özeti", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                ListView.builder(

                  shrinkWrap: true, // ListView içinde ListView kullanmak için şart

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: sepet.length,

                  itemBuilder: (context, index) {

                    final urun = sepet[index];

                    return ListTile(

                      contentPadding: EdgeInsets.zero,

                      title: Text(urun.ad),

                      subtitle: Text("${urun.fiyat} TL", style: const TextStyle(color: Colors.orange)),

                      trailing: IconButton(

                        icon: const Icon(Icons.delete, color: Colors.red),

                        onPressed: () => setState(() => sepet.removeAt(index)),

                      ),

                    );

                  },

                ),

                const Divider(thickness: 2),

               

                // 2. TOPLAM TUTAR

                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    const Text("Toplam:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    Text("${SepetKontrol.toplamTutar.toStringAsFixed(2)} TL", style: const TextStyle(fontSize: 22, color: Colors.orange, fontWeight: FontWeight.bold)),

                  ],

                ),

                const SizedBox(height: 30),


                // 3. ÖDEME BİLGİLERİ KISMI

                const Text("Ödeme Bilgileri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 15),

                const TextField(decoration: InputDecoration(labelText: "Kart Üzerindeki İsim", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),

                const SizedBox(height: 10),

                const TextField(decoration: InputDecoration(labelText: "Kart Numarası", border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card)), keyboardType: TextInputType.number),

                const SizedBox(height: 10),

                Row(

                  children: [

                    const Expanded(child: TextField(decoration: InputDecoration(labelText: "AA/YY", border: OutlineInputBorder()))),

                    const SizedBox(width: 10),

                    const Expanded(child: TextField(decoration: InputDecoration(labelText: "CVV", border: OutlineInputBorder()), obscureText: true)),

                  ],

                ),

                const SizedBox(height: 30),


                // 4. ÖDEME YAP BUTONU

                _islemSuruyor

                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))

                    : ElevatedButton(

                        style: ElevatedButton.styleFrom(

                          minimumSize: const Size(double.infinity, 55),

                          backgroundColor: Colors.green,

                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                        ),

                        onPressed: _odemeYap,

                        child: const Text("Ödeme Yap", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),

                      ),

              ],

            ),

    );

  }

}