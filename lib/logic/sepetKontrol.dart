import '../models/urunler.dart';

class SepetKontrol {
  static List<Urun> sepetListesi = [];
  
  // YENİ EKLENEN SATIR: Siparişin anlık durumunu tutacak
  static String? aktifSiparisDurumu; 

  static double get toplamTutar {
    return sepetListesi.fold(0, (sum, item) => sum + item.fiyat);
  }

  static void temizle() {
    sepetListesi.clear();
  }
}