-- 1. ANA TABLOLAR
-- Ürün kategorilerini tutar (örn: Kedi, Köpek, Kuş vb.)
CREATE TABLE Kategori (
    kategori_id INT PRIMARY KEY,
    kategori_adi VARCHAR(50) NOT NULL,
    ust_kategori_id INT,
    FOREIGN KEY (ust_kategori_id) REFERENCES Kategori(kategori_id)
);

-- Alt kategorileri tutar (örn: Mama, Aksesuar vb.)
CREATE TABLE AltKategori (
    alt_kategori_id INT PRIMARY KEY,
    kategori_id INT NOT NULL,
    alt_kategori_adi VARCHAR(50) NOT NULL,
    FOREIGN KEY (kategori_id) REFERENCES Kategori(kategori_id)
);


-- Ürün bilgilerini tutar
CREATE TABLE Urunler (
    urun_id INT PRIMARY KEY,
    urun_adi VARCHAR(50) NOT NULL,
    urun_stok INT NOT NULL CHECK (urun_stok >= 0),
    urun_fiyat DECIMAL(10, 2) NOT NULL CHECK (urun_fiyat > 0),
    kategori_id INT NOT NULL,
    FOREIGN KEY (kategori_id) REFERENCES Kategori(kategori_id)
);

-- Tedarikçi bilgilerini tutar
CREATE TABLE Tedarikciler (
    tedarikci_id INT PRIMARY KEY,
    tedarikci_adi VARCHAR(50) NOT NULL,
    adres VARCHAR(100),
    iletisim_no VARCHAR(15)
);

-- Ürün-Tedarikçi ilişkisini tutar
CREATE TABLE UrunTedarikci (
    urun_tedarikci_id INT PRIMARY KEY,
    urun_id INT NOT NULL,
    tedarikci_id INT NOT NULL,
    tedarik_tarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id),
    FOREIGN KEY (tedarikci_id) REFERENCES Tedarikciler(tedarikci_id)
);

-- Müşteri bilgilerini tutar
CREATE TABLE Musteriler (
    musteri_id INT PRIMARY KEY,
    musteri_adi VARCHAR(50) NOT NULL,
    musteri_telefon_no VARCHAR(15),
    kayit_tarihi DATETIME DEFAULT GETDATE()
);

-- Müşteri adres bilgilerini tutar
CREATE TABLE Adresler (
    adres_id INT PRIMARY KEY,
    musteri_id INT NOT NULL,
    adres_detayi VARCHAR(100),
    sehir VARCHAR(50),
    posta_kodu VARCHAR(10),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id)
);

-- Çalışan bilgilerini tutar
CREATE TABLE Calisanlar (
    calisan_id INT PRIMARY KEY,
    calisan_adi VARCHAR(50) NOT NULL,
    calisan_tel VARCHAR(15),
    calisan_maas DECIMAL(10, 2) CHECK (calisan_maas > 0),
    komisyon DECIMAL(5, 2) CHECK (komisyon BETWEEN 0 AND 100),
    ise_baslama_tarihi DATE DEFAULT GETDATE()
);

-- Sipariş ana bilgilerini tutar
CREATE TABLE Siparisler (
    siparis_id INT IDENTITY(1,1) PRIMARY KEY,
    musteri_id INT NOT NULL,
    calisan_id INT NOT NULL,
    siparis_tarihi DATETIME DEFAULT GETDATE(),
    toplam_fiyat DECIMAL(10, 2) CHECK (toplam_fiyat >= 0),
    siparis_durumu VARCHAR(20) DEFAULT 'Beklemede' 
    CHECK (siparis_durumu IN ('Beklemede', 'Onaylandı', 'Hazırlanıyor', 'Kargoda', 'Tamamlandı', 'İptal')),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id)
);

-- Sipariş detaylarını tutar
CREATE TABLE SiparisDetay (
    siparis_detay_id INT PRIMARY KEY,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    urun_sayisi INT NOT NULL CHECK (urun_sayisi > 0),
    birim_fiyat DECIMAL(10, 2) NOT NULL CHECK (birim_fiyat > 0),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id)
);

-- Kargo bilgilerini tutar
CREATE TABLE Kargo (
    kargo_id INT PRIMARY KEY,
    siparis_id INT NOT NULL,
    kargo_durumu VARCHAR(50) CHECK (kargo_durumu IN ('Hazırlanıyor', 'Gönderildi', 'Teslim Edildi', 'İptal')),
    kargo_takip_no VARCHAR(20),
    kargo_tarih DATETIME DEFAULT GETDATE(),
    teslim_tarihi DATETIME,
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id)
);

-- Çalışan performans bilgilerini tutar
CREATE TABLE CalisanPerformansi (
    performans_id INT PRIMARY KEY,
    calisan_id INT NOT NULL,
    siparis_id INT NOT NULL,
    komisyon_tutar DECIMAL(10, 2) CHECK (komisyon_tutar >= 0),
    performans_tarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id)
);

-- Ürün yorumlarını tutar
CREATE TABLE UrunYorumlari (
    yorum_id INT PRIMARY KEY,
    urun_id INT NOT NULL,
    musteri_id INT NOT NULL,
    yorum_metni TEXT,
    yorum_tarihi DATETIME DEFAULT GETDATE(),
    puan INT CHECK (puan BETWEEN 1 AND 5),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id)
);

-- İade işlemlerini tutar
CREATE TABLE IadeIslemleri (
    iade_id INT PRIMARY KEY,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    iade_tarihi DATETIME DEFAULT GETDATE(),
    iade_sebebi VARCHAR(100),
    iade_durumu VARCHAR(20) DEFAULT 'Beklemede' 
    CHECK (iade_durumu IN ('Beklemede', 'Onaylandı', 'Reddedildi', 'Tamamlandı')),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id)
);
GO

-- 2. SAKLI YORDAMLAR
-- Yeni sipariş ekleme işlemini gerçekleştirir
CREATE PROCEDURE YeniSiparisEkle
    @musteri_id INT,
    @calisan_id INT,
    @urun_id INT,
    @urun_sayisi INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @toplam_fiyat DECIMAL(10, 2);
            DECLARE @birim_fiyat DECIMAL(10, 2);
            DECLARE @mevcut_stok INT;
            
            -- Stok kontrolü ve fiyat bilgisi alma
            SELECT @mevcut_stok = urun_stok, @birim_fiyat = urun_fiyat
            FROM Urunler WITH (UPDLOCK)
            WHERE urun_id = @urun_id;
            
            IF @mevcut_stok < @urun_sayisi
                THROW 50001, 'Yetersiz stok!', 1;
            
            SET @toplam_fiyat = @birim_fiyat * @urun_sayisi;
            
            -- Sipariş oluşturma
            INSERT INTO Siparisler (musteri_id, calisan_id, toplam_fiyat)
            VALUES (@musteri_id, @calisan_id, @toplam_fiyat);
            
            DECLARE @siparis_id INT = SCOPE_IDENTITY();
            
            -- Sipariş detayı ekleme
            INSERT INTO SiparisDetay (siparis_detay_id, siparis_id, urun_id, urun_sayisi, birim_fiyat)
            VALUES (NEXT VALUE FOR SiparisDetaySeq, @siparis_id, @urun_id, @urun_sayisi, @birim_fiyat);
            
            -- Stok güncelleme
            UPDATE Urunler
            SET urun_stok = urun_stok - @urun_sayisi
            WHERE urun_id = @urun_id;
            
            -- Komisyon işleme
            INSERT INTO CalisanPerformansi (performans_id, calisan_id, siparis_id, komisyon_tutar)
            SELECT 
                NEXT VALUE FOR PerformansSeq,
                @calisan_id,
                @siparis_id,
                (@toplam_fiyat * komisyon / 100)
            FROM Calisanlar
            WHERE calisan_id = @calisan_id;
            
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Ürün iade işlemini gerçekleştirir
CREATE PROCEDURE UrunIadeIslemi
    @siparis_id INT,
    @urun_id INT,
    @iade_miktar INT,
    @iade_sebebi VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            -- İade talebini doğrulama
            IF NOT EXISTS (
                SELECT 1 
                FROM SiparisDetay 
                WHERE siparis_id = @siparis_id 
                AND urun_id = @urun_id
                AND urun_sayisi >= @iade_miktar
            )
                THROW 50002, 'Geçersiz iade talebi', 1;
            
            -- Stok güncelleme
            UPDATE Urunler
            SET urun_stok = urun_stok + @iade_miktar
            WHERE urun_id = @urun_id;
            
            -- İade kaydı oluşturma
            INSERT INTO IadeIslemleri (iade_id, siparis_id, urun_id, iade_sebebi)
            VALUES (NEXT VALUE FOR IadeSeq, @siparis_id, @urun_id, @iade_sebebi);
            
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 3. TETİKLEYİCİLER (TRIGGERS)
-- Sipariş detayı eklendiğinde stok kontrolü ve güncellemesi yapar
CREATE TRIGGER StokGuncelle
ON SiparisDetay
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN Urunler u ON i.urun_id = u.urun_id
            WHERE u.urun_stok < i.urun_sayisi
        )
        BEGIN
            THROW 50003, 'Yetersiz stok!', 1;
            RETURN;
        END
        
        UPDATE u
        SET urun_stok = u.urun_stok - i.urun_sayisi
        FROM Urunler u
        JOIN inserted i ON u.urun_id = i.urun_id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Kargo durumu güncellendiğinde sipariş durumunu günceller
CREATE TRIGGER SiparisDurumuGuncelle
ON Kargo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET siparis_durumu = 
        CASE 
            WHEN i.kargo_durumu = 'Hazırlanıyor' THEN 'Hazırlanıyor'
            WHEN i.kargo_durumu = 'Gönderildi' THEN 'Kargoda'
            WHEN i.kargo_durumu = 'Teslim Edildi' THEN 'Tamamlandı'
            WHEN i.kargo_durumu = 'İptal' THEN 'İptal'
        END
    FROM Siparisler s
    JOIN inserted i ON s.siparis_id = i.siparis_id;
END;
GO

-- 4. ÖRNEK VERİLER
-- Temel kategori verileri
INSERT INTO Kategori (kategori_id, kategori_adi, ust_kategori_id) VALUES 
(1, 'Evcil Hayvanlar', NULL),
(2, 'Aksesuarlar', 1);

-- Alt kategori verileri
INSERT INTO AltKategori (alt_kategori_id, kategori_id, alt_kategori_adi) VALUES 
(1, 1, 'Kedi'),
(2, 2, 'Tasma');

-- Örnek ürünler
INSERT INTO Urunler (urun_id, urun_adi, urun_stok, urun_fiyat, kategori_id) VALUES 
(1, 'Kedi Maması', 100, 50.00, 1),
(2, 'Kedi Tasması', 50, 20.00, 2);

-- Örnek tedarikçi
INSERT INTO Tedarikciler (tedarikci_id, tedarikci_adi, adres, iletisim_no) VALUES 
(1, 'Hayvan Dünyası', 'İstanbul', '5554443322');
