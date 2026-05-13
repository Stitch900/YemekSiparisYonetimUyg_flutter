import 'package:flutter/material.dart';
import '../models/restoran.dart';
 
class RestoranKutusu extends StatelessWidget {
  final Restoran restoran;
  final VoidCallback onTap;
 
  const RestoranKutusu({
    super.key,
    required this.restoran,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST: LOGO / BANNER ALANI
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: restoran.logoUrl != null && restoran.logoUrl!.isNotEmpty
                  ? Image.network(
                      restoran.logoUrl!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoYok(),
                    )
                  : _logoYok(),
            ),
 
            // ALT: BİLGİ ALANI
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ad + Puan rozeti
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restoran.ad,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (restoran.puan != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                restoran.puan!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
 
                  // Adres
                  if (restoran.adres != null && restoran.adres!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            restoran.adres!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
 
                  // Açıklama
                  if (restoran.aciklama != null &&
                      restoran.aciklama!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      restoran.aciklama!,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  // Logo yokken gösterilecek placeholder
  Widget _logoYok() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.orange.shade50,
      child: const Icon(Icons.restaurant, size: 60, color: Colors.orange),
    );
  }
}
