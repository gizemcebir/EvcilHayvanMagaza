# Evcil Hayvan Mağazası Veritabanı Yönetim Sistemi

## Proje Ekibindeki Kişiler:
- Gizem Cebir-235260146  
- Zehra Nur Öztürk  
- Toprak Henaz-225260106     

## Dönem Projesi Gereksinimleri

Bu proje, bir mağaza yönetim sistemi olarak kapsamlı bir şekilde tasarlanmıştır ve farklı kullanıcı türlerinin ihtiyaçlarını karşılayacak şekilde yapılandırılmıştır. Bu sistem, bir mağazadaki iş süreçlerini dijitalleştirip verimli hale getirerek sipariş yönetiminden çalışan performans takibine kadar çeşitli fonksiyonları içerir. Sistemdeki kullanıcı rollerine göre işlevler şu şekilde belirlenmiştir:

### Müşteri İşlemleri:

- Müşteriler, mağazanın ürünlerini inceleyebilir, ürünlerin kategorilere göre ayrılmış listelerine erişebilir ve fiyat, stok durumu gibi ürün bilgilerini görüntüleyebilir.
- Ürünleri sepete ekleyerek sipariş oluşturabilirler.
- Sipariş sürecinde müşteri bilgileri, iletişim numaraları ve sipariş detayları sisteme kaydedilir.
- Sipariş oluşturulduktan sonra kargo takibi yapılabilir.
- Müşteriler, siparişlerinin durumunu ve tahmini teslim tarihini görebilirler.

### Çalışan İşlemleri:

- Çalışanlar, mağazaya gelen siparişlerin işlenmesi ve hazırlık süreçlerinden sorumludur.
- Bu süreçte siparişlerin doğru ve zamanında hazırlanması için çalışanlar, sipariş detaylarını görebilmeli ve işleyebilmelidir.
- Çalışan performanslarının takibi yapılır.
-  Sipariş başına komisyon hesaplanır ve bu sayede çalışanların performans değerlendirmesi yapılabilir.
-  Çalışanlar kendi performans verilerine erişebilir, işledikleri sipariş sayısını ve elde ettikleri komisyonları görebilir.

### Yönetici İşlemleri:

- Yöneticiler, ürünlerin güncellenmesi, stok seviyelerinin düzenlenmesi ve yeni ürünlerin sisteme eklenmesi gibi mağazanın envanter yönetiminden sorumludur.
- Sipariş yönetimi ve çalışan performanslarının analiz edilmesi ile çalışanların komisyon oranlarını ayarlayabilirler.
- Ayrıca, tedarikçilerle ilgili tüm bilgileri yönetebilirler; hangi tedarikçilerin hangi ürünleri sağladığı gibi verilere erişip güncellemeler yapabilirler.
- Yönetici, kargo süreçlerini de izleyerek teslimat süreçlerinin aksamadan yürütülmesini sağlar.

## Veritabanı Fonksiyonları
Sistem; sipariş yönetimi, stok kontrolü, kargo ve teslimat takibi, çalışan performans ölçümü, müşteri ve tedarikçi yönetimi gibi birçok işlevi içermektedir:

### Sipariş Yönetimi: 
- Siparişler, müşterilerin taleplerine göre oluşturulur ve sipariş detayları kayıt altına alınır. Siparişlere ait ürünler, miktarlar ve birim fiyatlar kaydedilir.
### Stok Kontrolü: 
- Ürün stok seviyeleri sürekli izlenir. Stok seviyesinin yetersiz olması durumunda tedarikçilere bilgi verilebilir veya yönetici gerekli işlemleri yapabilir.
### Kargo ve Teslimat Takibi:
- Her sipariş için bir kargo kaydı oluşturulur, kargo durumu ve teslimat tarihi gibi bilgiler güncellenir. Müşteriler ve çalışanlar, kargo durumunu sistem üzerinden izleyebilir.
### Çalışan Performansı:
- Çalışanların işledikleri siparişler ve kazandıkları komisyonlar üzerinden performansları ölçülür. Bu veriler, çalışanların değerlendirilmesi ve ödüllendirilmesi için kullanılabilir.
### Müşteri Yönetimi:
- Müşteriler, iletişim bilgileri ve sipariş geçmişi ile sistemde kayıt altına alınır. Bu sayede müşteri ilişkileri yönetimi daha etkin hale getirilir.
### Tedarikçi Yönetimi: 
- Tedarikçiler, sağladıkları ürünler ve iletişim bilgileri ile sistemde kayıt altındadır. Tedarikçilerle ilişkiler bu sistem üzerinden yönetilerek ürün tedariği optimize edilir.
  
Bu şekilde, mağaza yönetim sistemi veritabanı; müşteri, çalışan ve yönetici gibi farklı kullanıcıların ihtiyaçlarını karşılayacak şekilde yapılandırılmış ve mağazanın operasyonel süreçlerini verimli hale getirecek şekilde tasarlanmıştır.

## Varlıklar ve Nitelikleri

### Kategori:
- kategori_id: Kategorinin benzersiz kimliği (birincil anahtar).
- kategori_adi: Kategorinin adı.
- Bir kategoride birden fazla alt kategori olabilir (1:n ilişkisi).
  
### AltKategori:
- alt_kategori_id: Alt kategorinin benzersiz kimliği (birincil anahtar).
- kategori_id: Bu alt kategorinin ait olduğu kategoriye referans (yabancı anahtar).
- alt_kategori_adi: Alt kategorinin adı.
- Bir alt kategori, bir kategoriye ait olmak zorundadır(1:1 ilişkisi).
  
### Urunler:
- urun_id: Ürünün benzersiz kimliği (birincil anahtar).
- urun_adi: Ürünün adı.
- urun_stok: Ürünün stok durumu.
- urun_fiyat: Ürünün fiyatı.
- kategori_id: Ürünün bağlı olduğu kategoriye referans (yabancı anahtar).
Bir kategori birden fazla ürüne sahip olabilir (1:n ilişkisi).

### Siparisler:
- siparis_id: Siparişin benzersiz kimliği (birincil anahtar).
- musteri_id: Siparişi veren müşteriye referans (yabancı anahtar).
- calisan_id: Siparişi işleyen çalışana referans (yabancı anahtar).
- toplam_fiyat: Siparişin toplam tutarı.
- Bir müşteri birden fazla sipariş verebilir, ancak her sipariş tek bir müşteri tarafından yapılabilir (1:n 1ilişkisi).
  
### SiparisDetayi:

- siparis_detay_id: Sipariş detayının benzersiz kimliği (birincil anahtar).
- siparis_id: Siparişe referans (yabancı anahtar).
- urun_id: Sipariş edilen ürüne referans (yabancı anahtar).
- urun_sayisi: Sipariş edilen ürün sayısı.
- birim_fiyat: Ürünün birim fiyatı.
- Bir sipariş birden fazla üründen oluşabilir (1:n ilişkisi).
  
### Müşteriler:

- musteri_id: Müşterinin benzersiz kimliği (birincil anahtar).
- musteri_adi: Müşterinin adı.
- musteri_telefon_no: Müşterinin telefon numarası.
- Bir müşteri birden fazla sipariş verebilir (1:n ilişkisi).

### Çalışanlar:

- calisan_id: Çalışanın benzersiz kimliği (birincil anahtar).
- calisan_adi: Çalışanın adı.
- calisan_tel: Çalışanın telefon numarası.
- calisan_maas: Çalışanın maaşı.
- komisyon: Çalışanın sipariş başına aldığı komisyon oranı.
- Bir çalışan birden fazla sipariş işleyebilir (1:n ilişkisi).

### çalışan Performansı:

- performans_id: Performans kaydının benzersiz kimliği (birincil anahtar).
- calisan_id: Çalışana referans (yabancı anahtar).
- siparis_id: İşlem yapılan siparişe referans (yabancı anahtar).
- komisyon_tutar: Çalışanın bu siparişten aldığı komisyon miktarı.
- Her performans kaydı bir çalışana bağlıdır (n:1 ilişkisi).
  
### Kargo:

- kargo_id: Kargonun benzersiz kimliği (birincil anahtar).
- siparis_id: Kargonun bağlı olduğu siparişe referans (yabancı anahtar).
- kargo_durumu: Kargonun mevcut durumu.
- kargo_tarih: Kargonun gönderim tarihi.
- Her siparişin bir kargo kaydı olabilir, her kargo bir siparişe bağlıdır (1:1 ilişkisi).
  
### Tedarikçiler:

- tedarikci_id: Tedarikçinin benzersiz kimliği (birincil anahtar).
- tedarikci_adi: Tedarikçinin adı.
- adres: Tedarikçinin adresi.
- iletisim_no: Tedarikçinin iletişim numarası.
- Bir tedarikçi birden fazla ürün sağlayabilir (1:n ilişkisi).

### Ürün Tedarikçi:

- urun_tedarikci_id: Ürün-tedarikçi ilişkisinin benzersiz kimliği (birincil anahtar).
- urun_id: Ürüne referans (yabancı anahtar).
- tedarikci_id: Tedarikçiye referans (yabancı anahtar).
- Bir ürün birden fazla tedarikçi tarafından sağlanabilir, bir tedarikçi birden fazla ürüne sahip olabilir (n:n ilişkisi).

## İlişkilerde Sayısal Kısıtlamalar

- Müşteri-Sipariş İlişkisi: Bir müşteri birden fazla sipariş verebilir, fakat her sipariş sadece bir müşteri tarafından verilebilir (1:n).
- Sipariş-Çalışan İlişkisi: Her sipariş tek bir çalışan tarafından işlenir, fakat bir çalışan birden fazla sipariş işleyebilir (1:1).
- Sipariş-Sipariş Detayı İlişkisi: Bir sipariş birden fazla sipariş detayına sahip olabilir, her sipariş detayı ise bir siparişe aittir (1:n).
- Ürün-Tedarikçi İlişkisi: Bir ürün birden fazla tedarikçiden sağlanabilir ve bir tedarikçi birden fazla ürüne sahip olabilir (n:n).
- Sipariş-Kargo İlişkisi: Her sipariş için bir kargo kaydı bulunabilir ve her kargo bir siparişe bağlıdır (1:1).
