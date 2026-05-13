import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/girisEkrani.dart'; // Giriş ekranını import et



void main() {
 
  runApp(const YemekSiparisApp());
}

class YemekSiparisApp extends StatelessWidget {
  const YemekSiparisApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yemek Sipariş',
      debugShowCheckedModeBanner: false, // Sağ üstteki kırmızı debug yazısını kaldırır
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      // UYGULAMA ARTIK GİRİŞ EKRANINDAN BAŞLAYACAK
      home: GirisEkrani(), 
    );
  }
}