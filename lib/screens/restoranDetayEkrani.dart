import 'package:flutter/material.dart';
import '../models/restoran.dart';
import '../models/urunler.dart';
import '../models/yorumlar.dart';
import '../services/apiVeriCekme.dart';
import '../logic/sepetKontrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestoranDetayEkrani extends StatefulWidget {
  final Restoran restoran;
  const RestoranDetayEkrani({super.key, required this.restoran});

  @override
  State<RestoranDetayEkrani> createState() => _RestoranDetayEkraniState();
}

class _RestoranDetayEkraniState extends State<RestoranDetayEkrani> {
  final _apiServis = ApiVeriCekme();

  // Yorumları yeniden yüklemek için key kullanıyoruz
  Key _yorumKey = UniqueKey();

  void _yorumYapPenceresiGoster() {
    int _verilenPuan = 5;
    TextEditingController _yorumController = TextEditingController();
    bool _islemSuruyor = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text("Puan Ver & Yorum Yap",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _verilenPuan ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 36,
                        ),
                        onPressed: () => setStateDialog(() => _verilenPuan = index + 1),
                      );
                    }),
                  ),
                  Text("Puanınız: $_verilenPuan / 5",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _yorumController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Bu restoran hakkında ne düşünüyorsunuz?",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _islemSuruyor ? null : () => Navigator.pop(dialogContext),
                  child: const Text("İptal", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _islemSuruyor
                      ? null
                      : () async {
                          if (_yorumController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Lütfen bir yorum yazın!"),
                                backgroundColor: Colors.red));
                            return;
                          }
                          setStateDialog(() => _islemSuruyor = true);

                          final prefs = await SharedPreferences.getInstance();
                          int userId = prefs.getInt('kullaniciId') ?? 1;

                          bool basarili = await _apiServis.yorumGonder(
                            userId,
                            widget.restoran.restoranId,
                            null,
                            _verilenPuan,
                            _yorumController.text,
                          );

                          setStateDialog(() => _islemSuruyor = false);

                          if (basarili) {
                            Navigator.pop(dialogContext);
                            // Yorumları ve puanı yenile
                            setState(() => _yorumKey = UniqueKey());
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Yorumunuz eklendi!"),
                                backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Yorum eklenirken hata oluştu."),
                                backgroundColor: Colors.red));
                          }
                        },
                  child: _islemSuruyor
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Gönder", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restoran.ad, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // PUAN ORTALAMASI BAŞLIK
          FutureBuilder<double>(
            key: _yorumKey,
            future: _apiServis.puanOrtalamasiGetir(widget.restoran.restoranId),
            builder: (context, snapshot) {
              double puan = snapshot.data ?? 0.0;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < puan.round() ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 24,
                    )),
                    const SizedBox(width: 8),
                    Text(
                      puan == 0.0 ? "Henüz yorum yok" : "$puan / 5 ortalama puan",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),

          // MENÜ LİSTESİ
          Expanded(
            child: FutureBuilder<List<Urun>>(
              future: _apiServis.menuyuGetir(widget.restoran.restoranId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Bu restoranın henüz menüsü yok."));
                }
                final yemekler = snapshot.data!;
                return ListView.builder(
                  itemCount: yemekler.length,
                  itemBuilder: (context, index) => UrunKarti(urun: yemekler[index]),
                );
              },
            ),
          ),

          // YORUMLAR BÖLÜMÜ
          Container(
            height: 220,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Yorumlar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _yorumYapPenceresiGoster,
                        icon: const Icon(Icons.rate_review, color: Colors.orange),
                        label: const Text("Yorum Yap",
                            style: TextStyle(color: Colors.orange)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Yorum>>(
                    key: _yorumKey,
                    future: _apiServis.yorumlariGetir(restoranId: widget.restoran.restoranId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Henüz yorum yok. İlk yorumu siz yapın!",
                                style: TextStyle(color: Colors.grey)));
                      }
                      final yorumlar = snapshot.data!;
                      return ListView.builder(
                        itemCount: yorumlar.length,
                        itemBuilder: (context, index) {
                          final yorum = yorumlar[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                yorum.adSoyad.isNotEmpty ? yorum.adSoyad[0] : "?",
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(yorum.adSoyad,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(width: 8),
                                ...List.generate(5, (i) => Icon(
                                  i < yorum.puan ? Icons.star : Icons.star_border,
                                  color: Colors.orange,
                                  size: 13,
                                )),
                              ],
                            ),
                            subtitle: Text(yorum.metin),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// UrunKarti aynı kalıyor
class UrunKarti extends StatefulWidget {
  final Urun urun;
  const UrunKarti({super.key, required this.urun});

  @override
  State<UrunKarti> createState() => _UrunKartiState();
}

class _UrunKartiState extends State<UrunKarti> {
  int get _sepettekiAdet => SepetKontrol.sepetListesi
      .where((item) => item.ad == widget.urun.ad)
      .length;

  void _sepeteEkle() => setState(() => SepetKontrol.sepetListesi.add(widget.urun));

  void _sepettenCikar() {
    if (_sepettekiAdet > 0) {
      setState(() {
        SepetKontrol.sepetListesi.remove(
          SepetKontrol.sepetListesi.firstWhere((item) => item.ad == widget.urun.ad),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int adet = _sepettekiAdet;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.urun.ad,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${widget.urun.fiyat} TL",
                      style: const TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            adet == 0
                ? ElevatedButton(
                    onPressed: _sepeteEkle,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Ekle", style: TextStyle(color: Colors.white)),
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.remove, color: Colors.green),
                            onPressed: _sepettenCikar),
                        Text("$adet",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: _sepeteEkle),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}