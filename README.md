Yemek Sipariş Sistemi - Mobil ve Frontend Projesi

Bu proje, bir yemek sipariş sisteminin kullanıcı arayüzü ve mobil uygulama süreçlerini kapsayan Flutter tabanlı bir çalışmadır. Uygulama; müşteri, restoran ve sipariş yönetimi süreçlerini uçtan uca yönetmek üzere tasarlanmıştır.

SQ Server, swagger ve flutter gibi teknolojiler kullanılmıştır.

Proje Kapsamı ve İşlevsellik

Uygulama aşağıdaki ana modülleri içermektedir:
1. Kimlik Doğrulama ve Kullanıcı Yönetimi

    Giriş ve Kayıt Sayfası: Kullanıcıların sisteme dahil olabilmesi için gerekli olan form yapılarını içerir.

    JWT Entegrasyonu: Backend servisleri ile güvenli iletişim sağlamak amacıyla JWT (JSON Web Token) tabanlı kimlik doğrulama yapısı kullanılır.

    Kullanıcı Bilgileri: Profil sayfası üzerinden kullanıcı bilgilerinin düzenlenmesine olanak tanır.

2. Restoran Arama ve Listeleme

    Ana Sayfa: Sistemde kayıtlı restoranların listelendiği ana ekrandır.

    Arama ve Listeleme: Kullanıcıların restoran adı ile arama yapabilmesini ve puanlarına göre sıralama yapılması gibi dinamikleri barındırır.

    Navigasyon: Seçilen restoranın detay sayfasına ve menü içeriğine yönlendirme sağlar.

3. Menü ve Sepet Yönetimi

    Restoran Detay: İlgili restorana ait menü öğelerini gösterir.

    Sepet İşlemleri: Ürünlerin sepete eklenmesi, çıkarılması ve miktar güncellenmesi işlevlerini yerine getirir.

    Sipariş Özeti: Ödeme öncesinde sepetteki ürünlerin dökümünü ve toplam tutarı görüntüler.

4. Sipariş ve Geçmiş Takibi

    Sipariş Oluşturma: Sepet onaylandığında Backend API'sine POST isteği göndererek sipariş sürecini başlatır.

    Sipariş Geçmişi: Kullanıcının profil sekmesi üzerinden geçmiş siparişlerini incelemesine imkan tanır.

   Ödeme Simülasyonu

    Basit sahte ödeme API’si üzerinden işlemin "ödendi" veya "başarısız" olarak sonuçlandırılması.

5. Ek Özellikler (Opsiyonel)

    Restoran ve ürün bazlı yorum/puanlama sistemi.

    Restoran veya ürün adına göre basit arama ve filtreleme işlevleri.

6. Gelişmiş Sıralama Algoritmaları

    Restoranların puan ortalamalarına göre büyükten küçüğe veya küçükten büyüğe dinamik olarak sıralanması.

    Kullanıcı arayüzü üzerinden sıralama yönünün anlık olarak değiştirilebilmesi.

7. Veritabanı ve API Mimari Yapılandırması (SQL Server & Swagger)

    Microsoft SQL Server üzerinde ilişkisel veritabanı tasarımı ve veri modellerinin oluşturulması.

    Visual Studio ortamında Swagger (OpenAPI) entegrasyonu ile tüm API uç noktalarının (endpoints) dökümantasyonu ve test edilebilirliği.

8. Kapsamlı Rol ve Yetki Denetimi

    Admin, restoran sahibi ve müşteri rolleri için sunucu tarafında özelleştirilmiş erişim kısıtlamaları.

    JWT (JSON Web Token) tabanlı kimlik doğrulama kontrollerinin her istekte sunucu tarafında doğrulanması.

9. Durum Yönetimi ve Canlı Veri Takibi

    Sipariş durumlarının (hazırlanıyor, yolda, teslim edildi) veritabanı üzerinden anlık güncellenmesi ve kullanıcı arayüzüne yansıtılması.

    Uygulama içi asenkron veri çekme işlemleri ile dinamik liste güncellemeleri.

10. Teknik Detaylar

    Framework: Flutter

    Dil: Dart

    Mimari: Katmanlı Mimari (Data, UI, Service)

    İletişim: REST API

Bu README dosyası, uygulamanın hem web/frontend hem de mobil (Android & iOS) platformlardaki işlevsel gereksinimlerini tek bir dokümanda birleştirmektedir.
