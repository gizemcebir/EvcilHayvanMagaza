# Evcil Hayvan Mağazası Veritabanı Yönetim Sistemi

## Proje Ekibindeki Kişiler:
- Gizem Cebir-235260146  
- Zehra Nur Öztürk-225260068  
- Toprak Henaz-225260106     

## Dönem Projesi Gereksinimleri

Bu proje, bir mağaza yönetim sistemi olarak kapsamlı bir şekilde tasarlanmıştır ve farklı kullanıcı türlerinin ihtiyaçlarını karşılayacak şekilde yapılandırılmıştır. Bu sistem, bir mağazadaki iş süreçlerini dijitalleştirip verimli hale getirerek sipariş yönetiminden çalışan performans takibine kadar çeşitli fonksiyonları içerir. Sistemdeki kullanıcı rollerine göre işlevler şu şekilde belirlenmiştir:

### Müşteri İşlemleri:

- Müşteriler, mağazanın ürünlerini inceleyebilir, ürünlerin kategorilere göre ayrılmış listelerine erişebilir ve fiyat, stok durumu gibi ürün bilgilerini görüntüleyebilir.
- Ürünleri sepete ekleyerek sipariş oluşturabilirler.
- Sipariş sürecinde müşteri bilgileri, iletişim numaraları ve sipariş detayları sisteme kaydedilir.
- Sipariş oluşturulduktan sonra kargo takibi yapılabilir.
- Müşteriler, siparişlerinin durumunu ve tahmini teslim tarihini görebilirler.
- Müşteriler, sipariş verdikleri ürünler hakkında yorum yapabilir, bu yorumlar "Ürün Yorumları" tablosunda saklanarak müşteri memnuniyeti analizi için kullanılabilir.
- Müşterilerin birden fazla adres kaydetmesine olanak tanınır; böylece her sipariş için farklı adres seçme imkânı sunulmuş olur.

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
- İade işlemleri yönetici tarafından takip edilir; müşterilerin yaptığı iade talepleri kaydedilir ve uygun işlemler yapılır.
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



