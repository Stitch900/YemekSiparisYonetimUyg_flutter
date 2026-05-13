import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiVeriCekme.dart';
import '../models/siparislerVeDetaylar.dart';

class ProfilEkrani extends StatefulWidget {
  @override
  _ProfilEkraniState createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final _apiServis = ApiVeriCekme();
  final _adController = TextEditingController();
  final _mailController = TextEditingController();

  bool _yukleniyor = true;
  bool _duzenlemeModu = false; // Kutuların kilitli/açık olma durumu
  int _kullaniciId = 1; // Varsayılan, hafızadan güncellenecek

  @override
  void initState() {
    super.initState();
    _kullaniciBilgileriniYukle();
  }

  // TELEFON HAFIZASINDAN AKTİF KULLANICIYI ÇEKİYORUZ
  Future<void> _kullaniciBilgileriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kullaniciId = prefs.getInt('kullaniciId') ?? 1; 
      _adController.text = prefs.getString('adSoyad') ?? "Kullanıcı Adı Bulunamadı";
      _mailController.text = prefs.getString('eposta') ?? "eposta@bulunamadi.com";
      _yukleniyor = false;
    });
  }

  // DÜZENLE VE KAYDET BUTONUNUN ORTAK FONKSİYONU
  void _butonAksiyonu() async {
    if (!_duzenlemeModu) {
      setState(() {
        _duzenlemeModu = true;
      });
    } else {
      setState(() { _yukleniyor = true; });
      
      bool sonuc = await _apiServis.kullaniciGuncelle(_kullaniciId, _adController.text, _mailController.text);
      
      if (sonuc) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('adSoyad', _adController.text);
        await prefs.setString('eposta', _mailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bilgileriniz başarıyla güncellendi!"), backgroundColor: Colors.green),
        );
        
        setState(() { _duzenlemeModu = false; });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Güncelleme başarısız oldu."), backgroundColor: Colors.red),
        );
      }
      setState(() { _yukleniyor = false; });
    }
  }

 // TAMAMEN GERÇEK VE BAĞLI ŞİFRE DEĞİŞTİRME PENCERESİ
  void _sifreDegistirDialogGoster() {
    final eskiSifreController = TextEditingController();
    bool eskiSifreGoster = false;
    final yeniSifreController = TextEditingController();
    bool yeniSifreGoster = false;
    bool isRequesting = false; // Butona üst üste basılmasını önler

    showDialog(
  context: context,
  builder: (dialogContext) {

    bool eskiSifreGoster = false;
    bool yeniSifreGoster = false;

    return StatefulBuilder(
      builder: (context, setStateDialog) {

        return AlertDialog(
          title: const Text(
            "Şifre Değiştir",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              // ESKİ ŞİFRE
              TextField(
                controller: eskiSifreController,

                obscureText: !eskiSifreGoster,

                decoration: InputDecoration(
                  labelText: "Eski Şifre",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      eskiSifreGoster
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {
                      setStateDialog(() {
                        eskiSifreGoster =
                            !eskiSifreGoster;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // YENİ ŞİFRE
              TextField(
                controller: yeniSifreController,

                obscureText: !yeniSifreGoster,

                decoration: InputDecoration(
                  labelText: "Yeni Şifre",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(
                    icon: Icon(
                      yeniSifreGoster
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {
                      setStateDialog(() {
                        yeniSifreGoster =
                            !yeniSifreGoster;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          actions: [

            // İPTAL
            TextButton(
              onPressed: isRequesting
                  ? null
                  : () => Navigator.pop(dialogContext),

              child: const Text(
                "İptal",
                style: TextStyle(color: Colors.red),
              ),
            ),

            // GÜNCELLE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),

              onPressed: isRequesting
                  ? null
                  : () async {

                      // BOŞ KONTROL
                      if (eskiSifreController
                              .text
                              .isEmpty ||
                          yeniSifreController
                              .text
                              .isEmpty) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Lütfen tüm alanları doldurun!",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );

                        return;
                      }

                      // LOADING
                      setStateDialog(() {
                        isRequesting = true;
                      });

                      // API
                      bool sifreSonuc =
                          await _apiServis
                              .sifreDegistir(
                        _kullaniciId,
                        eskiSifreController.text,
                        yeniSifreController.text,
                      );

                      // LOADING DURDUR
                      setStateDialog(() {
                        isRequesting = false;
                      });

                      if (sifreSonuc) {

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Şifreniz başarıyla değiştirildi!",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                      } else {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Şifre değiştirilemedi. Eski şifrenizi kontrol edin.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },

              child: isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Şifreyi Güncelle",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
      appBar: AppBar(title: const Text("Profilim", style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            
            // AD SOYAD KUTUSU
            TextField(
              controller: _adController, 
              enabled: _duzenlemeModu, 
              decoration: const InputDecoration(labelText: "Ad Soyad", border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge))
            ),
            const SizedBox(height: 15),
            
            // E-POSTA KUTUSU
            TextField(
              controller: _mailController, 
              enabled: _duzenlemeModu, 
              decoration: const InputDecoration(labelText: "E-posta", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))
            ),
            const SizedBox(height: 25),
            
            // DİNAMİK BİLGİLERİ DÜZENLE/KAYDET BUTONU
            ElevatedButton.icon(
              onPressed: _butonAksiyonu, 
              icon: Icon(_duzenlemeModu ? Icons.save : Icons.edit, color: Colors.white),
              label: Text(_duzenlemeModu ? "Bilgileri Kaydet" : "Bilgileri Düzenle", style: const TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _duzenlemeModu ? Colors.green : Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),

            // YENİ EKLENEN: ŞİFRE DEĞİŞTİR BUTONU
            OutlinedButton.icon(
              onPressed: _sifreDegistirDialogGoster,
              icon: const Icon(Icons.lock_reset, color: Colors.red),
              label: const Text("Şifre Değiştir", style: TextStyle(color: Colors.red, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            
            const Divider(height: 50, thickness: 2),
            const Row(
              children: [
                Icon(Icons.history, color: Colors.orange),
                SizedBox(width: 10),
                Text("Geçmiş Siparişlerim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            
            // GEÇMİŞ SİPARİŞLER LİSTESİ
            FutureBuilder<List<Siparis>>(
              future: _apiServis.siparisGecmisiGetir(_kullaniciId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Henüz siparişiniz bulunmamaktadır.", style: TextStyle(fontStyle: FontStyle.italic));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final siparis = snapshot.data![index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.restaurant, color: Colors.white, size: 20)),
                        title: Text("Sipariş #${siparis.siparisId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Tutar: ${siparis.toplamTutar.toStringAsFixed(2)} TL\nDurum: ${siparis.durum}"),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}