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

### Tablolar ve Açıklamaları

#### **1. Kategoriler**
- **kategoriler_id**: Kategorinin benzersiz kimliği.
- **kategori_adi**: Kategorinin adı.
- **ust_kategori_id**: Alt kategoriler için üst kategoriyi temsil eden sütun.

#### **2. Ürünler**
- **urun_id**: Ürünün benzersiz kimliği.
- **urun_adi**: Ürünün adı.
- **urun_stok**: Mevcut stok miktarı.
- **urun_fiyat**: Ürünün fiyatı.
- **kategori_id**: Ürünün bağlı olduğu kategorinin ID’si.

#### **3. Tedarikçiler**
- **tedarikci_id**: Tedarikçinin benzersiz kimliği.
- **tedarikci_adi**: Tedarikçinin adı.
- **adres**: Tedarikçi adresi.
- **iletisim_no**: Tedarikçi iletişim numarası.

#### **4. Ürün Tedarikçi**
- **urun_tedarikci_id**: Ürün ve tedarikçi ilişkisini temsil eden benzersiz kimlik.
- **urun_id**: İlgili ürünün ID’si.
- **tedarikci_id**: İlgili tedarikçinin ID’si.

#### **5. Siparişler**
- **siparis_id**: Siparişin benzersiz kimliği.
- **musteri_id**: Siparişi veren müşterinin kimliği.
- **calisan_id**: Siparişi işleyen çalışanın kimliği.
- **toplam_fiyat**: Siparişin toplam tutarı.

#### **6. Sipariş Detay**
- **siparis_detay_id**: Sipariş detayının benzersiz kimliği.
- **siparis_id**: İlgili siparişin kimliği.
- **urun_id**: Siparişte yer alan ürünün kimliği.
- **urun_sayisi**: Sipariş edilen ürün miktarı.
- **birim_fiyat**: Ürünün birim fiyatı.

#### **7. Müşteriler**
- **musteri_id**: Müşterinin benzersiz kimliği.
- **musteri_adi**: Müşterinin adı.
- **musteri_telefon**: Müşterinin telefon numarası.

#### **8. Adresler**
- **adres_id**: Adresin benzersiz kimliği.
- **musteri_id**: Adresin sahibi müşterinin kimliği.
- **adres_detayi**: Adres bilgisi.
- **sehir**: Şehir adı.
- **posta_kodu**: Posta kodu.

#### **9. Çalışanlar**
- **calisan_id**: Çalışanın benzersiz kimliği.
- **calisan_adi**: Çalışanın adı.
- **calisan_tel**: Çalışanın telefon numarası.
- **calisan_maas**: Çalışanın maaşı.
- **komisyon**: Çalışanın siparişlerden kazandığı komisyon oranı.

#### **10. Çalışan Performansı**
- **performans_id**: Performans kaydının benzersiz kimliği.
- **calisan_id**: İlgili çalışanın kimliği.
- **siparis_id**: Çalışanın işlediği siparişin kimliği.
- **komisyon_tutar**: İşlenen siparişten kazanılan komisyon.

#### **11. İade İşlemleri**
- **iade_id**: İade işleminin benzersiz kimliği.
- **siparis_id**: İade edilen siparişin kimliği.
- **urun_id**: İade edilen ürünün kimliği.
- **iade_tarihi**: İade işlemi tarihi.
- **iade_sebebi**: İade nedeni.

#### **12. Kargo**
- **kargo_id**: Kargo işleminin benzersiz kimliği.
- **siparis_id**: Kargo edilen siparişin kimliği.
- **kargo_durumu**: Kargonun mevcut durumu.
- **kargo_tarih**: Kargonun teslim tarihi.

#### **13. Ürün Yorumları**
- **yorum_id**: Yorumun benzersiz kimliği.
- **urun_id**: Yorum yapılan ürünün kimliği.
- **musteri_id**: Yorumu yapan müşterinin kimliği.
- **yorum_metin**: Yorumun içeriği.
- **yorum_tarihi**: Yorumun yapıldığı tarih.
- **puan**: Ürün için verilen puan.

---

## İlişkiler
- **Kategoriler** ile **Ürünler** arasında birden çoğa ilişki.
- **Ürünler** ile **Sipariş Detay** arasında birden çoğa ilişki.
- **Müşteriler** ile **Adresler** arasında bire bir ilişki.
- **Çalışanlar** ile **Çalışan Performansı** arasında birden çoğa ilişki.
- **Tedarikçiler** ile **Ürün Tedarikçi** arasında birden çoğa ilişki.
- **Siparişler** ile **Sipariş Detay**, **Kargo** ve **İade İşlemleri** arasında bire bir ilişkiler.

## Teknik Gereksinimler ve Yöntemler

1. **Veritabanı Platformu**:  
   SQL Server kullanılacaktır.

2. **Transaction Yönetimi**:  
   Sipariş ve iade işlemlerinin atomik olarak işlenmesi sağlanacak.

3. **Tetikleyiciler ve Saklı Yordamlar**:  
   - Tetikleyici: Sipariş eklendiğinde stok miktarının otomatik güncellenmesi.
   - Saklı Yordam: Çalışan performans raporları oluşturulması.

4. **Örnek Veri Seti**:  
   Tabloların işlevselliğini test etmek için örnek veriler eklenecektir.

5. **Güncelleme ve Sorgulama İşlevleri**:  
   Kullanıcı, ürün ve sipariş detaylarına yönelik CRUD işlemleri desteklenecektir.
