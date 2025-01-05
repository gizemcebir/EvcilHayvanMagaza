-- 1. ANA TABLOLAR
-- Ürün kategorilerini tutar (örn: Kedi, Köpek, Kuþ vb.)
CREATE TABLE Kategori (
    kategori_id INT PRIMARY KEY,
    kategori_adi VARCHAR(50) NOT NULL,
    ust_kategori_id INT,
    FOREIGN KEY (ust_kategori_id) REFERENCES Kategori(kategori_id)
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

-- Ürün-Tedarikçi iliþkisini tutar
CREATE TABLE UrunTedarikci (
    urun_tedarikci_id INT PRIMARY KEY,
    urun_id INT NOT NULL,
    tedarikci_id INT NOT NULL,
    tedarik_tarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id),
    FOREIGN KEY (tedarikci_id) REFERENCES Tedarikciler(tedarikci_id)
);

-- Müþteri bilgilerini tutar
CREATE TABLE Musteriler (
    musteri_id INT PRIMARY KEY,
    musteri_adi VARCHAR(50) NOT NULL,
    musteri_telefon_no VARCHAR(15),
    kayit_tarihi DATETIME DEFAULT GETDATE()
);

-- Müþteri adres bilgilerini tutar
CREATE TABLE Adresler (
    adres_id INT PRIMARY KEY,
    musteri_id INT NOT NULL,
    adres_detayi VARCHAR(100),
    sehir VARCHAR(50),
    posta_kodu VARCHAR(10),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id)
);

-- Çalýþan bilgilerini tutar
CREATE TABLE Calisanlar (
    calisan_id INT PRIMARY KEY,
    calisan_adi VARCHAR(50) NOT NULL,
    calisan_tel VARCHAR(15),
    calisan_maas DECIMAL(10, 2) CHECK (calisan_maas > 0),
    komisyon DECIMAL(5, 2) CHECK (komisyon BETWEEN 0 AND 100),
    ise_baslama_tarihi DATE DEFAULT GETDATE()
);

-- Sipariþ ana bilgilerini tutar
CREATE TABLE Siparisler (
    siparis_id INT IDENTITY(1,1) PRIMARY KEY,
    musteri_id INT NOT NULL,
    calisan_id INT NOT NULL,
    siparis_tarihi DATETIME DEFAULT GETDATE(),
    toplam_fiyat DECIMAL(10, 2) CHECK (toplam_fiyat >= 0),
    siparis_durumu VARCHAR(20) DEFAULT 'Beklemede' 
    CHECK (siparis_durumu IN ('Beklemede', 'Onaylandý', 'Hazýrlanýyor', 'Kargoda', 'Tamamlandý', 'Ýptal')),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id)
);

-- Sipariþ detaylarýný tutar
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
    kargo_durumu VARCHAR(50) CHECK (kargo_durumu IN ('Hazýrlanýyor', 'Gönderildi', 'Teslim Edildi', 'Ýptal')),
    kargo_takip_no VARCHAR(20),
    kargo_tarih DATETIME DEFAULT GETDATE(),
    teslim_tarihi DATETIME,
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id)
);

-- Çalýþan performans bilgilerini tutar
CREATE TABLE CalisanPerformansi (
    performans_id INT PRIMARY KEY,
    calisan_id INT NOT NULL,
    siparis_id INT NOT NULL,
    komisyon_tutar DECIMAL(10, 2) CHECK (komisyon_tutar >= 0),
    performans_tarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id)
);

-- Ürün yorumlarýný tutar
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

-- Ýade iþlemlerini tutar
CREATE TABLE IadeIslemleri (
    iade_id INT PRIMARY KEY,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    iade_tarihi DATETIME DEFAULT GETDATE(),
    iade_sebebi VARCHAR(100),
    iade_durumu VARCHAR(20) DEFAULT 'Beklemede' 
    CHECK (iade_durumu IN ('Beklemede', 'Onaylandý', 'Reddedildi', 'Tamamlandý')),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id)
);
GO

-- 2. SAKLI YORDAMLAR
-- Yeni sipariþ ekleme iþlemini gerçekleþtirir
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
            
            -- Sipariþ oluþturma
            INSERT INTO Siparisler (musteri_id, calisan_id, toplam_fiyat)
            VALUES (@musteri_id, @calisan_id, @toplam_fiyat);
            
            DECLARE @siparis_id INT = SCOPE_IDENTITY();
            
            -- Sipariþ detayý ekleme
            INSERT INTO SiparisDetay (siparis_detay_id, siparis_id, urun_id, urun_sayisi, birim_fiyat)
            VALUES (NEXT VALUE FOR SiparisDetaySeq, @siparis_id, @urun_id, @urun_sayisi, @birim_fiyat);
            
            -- Stok güncelleme
            UPDATE Urunler
            SET urun_stok = urun_stok - @urun_sayisi
            WHERE urun_id = @urun_id;
            
            -- Komisyon iþleme
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

-- Ürün iade iþlemini gerçekleþtirir
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
            -- Ýade talebini doðrulama
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
            
            -- Ýade kaydý oluþturma
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

-- 3. TETÝKLEYÝCÝLER (TRIGGERS)
-- Sipariþ detayý eklendiðinde stok kontrolü ve güncellemesi yapar
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

-- Kargo durumu güncellendiðinde sipariþ durumunu günceller
CREATE TRIGGER SiparisDurumuGuncelle
ON Kargo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET siparis_durumu = 
        CASE 
            WHEN i.kargo_durumu = 'Hazýrlanýyor' THEN 'Hazýrlanýyor'
            WHEN i.kargo_durumu = 'Gönderildi' THEN 'Kargoda'
            WHEN i.kargo_durumu = 'Teslim Edildi' THEN 'Tamamlandý'
            WHEN i.kargo_durumu = 'Ýptal' THEN 'Ýptal'
        END
    FROM Siparisler s
    JOIN inserted i ON s.siparis_id = i.siparis_id;
END;
GO

-- 4. ÖRNEK VERÝLER
-- Kategori verileri
INSERT INTO Kategori (kategori_id, kategori_adi, ust_kategori_id) VALUES 
(1, 'Kedi Ürünleri', NULL),
(2, 'Köpek Ürünleri', NULL),
(3, 'Kuþ Ürünleri', NULL),
(4, 'Kemirgen Ürünleri', NULL),
(5, 'Mama ve Besinler', 1),
(6, 'Kum ve Hijyen', 1),
(7, 'Oyuncaklar', 1),
(8, 'Mama ve Besinler', 2),
(9, 'Tasma ve Gezdirme', 2),
(10, 'Bakým Ürünleri', 2);

-- Ürünler
INSERT INTO Urunler (urun_id, urun_adi, urun_stok, urun_fiyat, kategori_id) VALUES 
(1, 'Premium Kedi Mamasý 1kg', 100, 150.00, 5),
(2, 'Kedi Kumu 10L', 75, 200.00, 6),
(3, 'Kedi Oyun Çubuðu', 50, 45.00, 7),
(4, 'Premium Köpek Mamasý 3kg', 80, 250.00, 8),
(5, 'Ayarlanabilir Köpek Tasmasý', 60, 120.00, 9),
(6, 'Köpek Þampuaný 500ml', 40, 85.00, 10),
(7, 'Kuþ Yemi 500g', 120, 45.00, 3),
(8, 'Hamster Yemi 250g', 90, 35.00, 4),
(9, 'Kedi Týrmalama Tahtasý', 30, 180.00, 7),
(10, 'Köpek Diþ Bakým Oyuncaðý', 45, 65.00, 10);

-- Tedarikçiler
INSERT INTO Tedarikciler (tedarikci_id, tedarikci_adi, adres, iletisim_no) VALUES 
(1, 'Pet Beslenme A.Þ.', 'Ýstanbul, Ataþehir', '5554443322'),
(2, 'Dostlar Pet Market', 'Ankara, Çankaya', '5553332211'),
(3, 'Global Pet Supplies', 'Ýzmir, Bornova', '5552221100'),
(4, 'Happy Pets Co.', 'Bursa, Nilüfer', '5551110099');

-- Müþteriler
INSERT INTO Musteriler (musteri_id, musteri_adi, musteri_telefon_no, kayit_tarihi) VALUES 
(1, 'Ahmet Yýlmaz', '5551234567', '2024-01-01'),
(2, 'Ayþe Demir', '5559876543', '2024-01-02'),
(3, 'Mehmet Kaya', '5557894561', '2024-01-03'),
(4, 'Fatma Þahin', '5553216547', '2024-01-04'),
(5, 'Ali Öztürk', '5552589631', '2024-01-05');

-- Adresler
INSERT INTO Adresler (adres_id, musteri_id, adres_detayi, sehir, posta_kodu) VALUES 
(1, 1, 'Atatürk Cad. No:123', 'Ýstanbul', '34100'),
(2, 2, 'Cumhuriyet Mah. 456. Sok.', 'Ankara', '06100'),
(3, 3, 'Barýþ Bulvarý No:789', 'Ýzmir', '35100'),
(4, 4, 'Yýldýz Sokak No:321', 'Bursa', '16100'),
(5, 5, 'Gül Caddesi No:654', 'Antalya', '07100');

-- Çalýþanlar
INSERT INTO Calisanlar (calisan_id, calisan_adi, calisan_tel, calisan_maas, komisyon, ise_baslama_tarihi) VALUES 
(1, 'Zeynep Aksoy', '5331234567', 12000.00, 5.00, '2023-06-15'),
(2, 'Murat Yýldýz', '5332345678', 11000.00, 4.50, '2023-07-01'),
(3, 'Elif Çelik', '5333456789', 11500.00, 4.75, '2023-08-15'),
(4, 'Can Demir', '5334567890', 10500.00, 4.25, '2023-09-01');

-- Sipariþler ve ilgili detaylar
INSERT INTO Siparisler (musteri_id, calisan_id, siparis_tarihi, toplam_fiyat, siparis_durumu) VALUES 
(1, 1, '2024-01-01', 350.00, 'Tamamlandý'),
(2, 2, '2024-01-02', 285.00, 'Kargoda'),
(3, 3, '2024-01-03', 200.00, 'Hazýrlanýyor'),
(4, 4, '2024-01-04', 165.00, 'Beklemede');

INSERT INTO SiparisDetay (siparis_detay_id, siparis_id, urun_id, urun_sayisi, birim_fiyat) VALUES 
(NEXT VALUE FOR SiparisDetaySeq, 1, 1, 2, 150.00),
(NEXT VALUE FOR SiparisDetaySeq, 1, 3, 1, 50.00),
(NEXT VALUE FOR SiparisDetaySeq, 2, 2, 1, 200.00),
(NEXT VALUE FOR SiparisDetaySeq, 2, 3, 2, 45.00);

-- Kargo bilgileri
INSERT INTO Kargo (kargo_id, siparis_id, kargo_durumu, kargo_takip_no, kargo_tarih, teslim_tarihi) VALUES 
(1, 1, 'Teslim Edildi', 'TR123456789', '2024-01-01', '2024-01-03'),
(2, 2, 'Gönderildi', 'TR987654321', '2024-01-02', NULL),
(3, 3, 'Hazýrlanýyor', 'TR456789123', '2024-01-03', NULL);

-- Çalýþan performans kayýtlarý
INSERT INTO CalisanPerformansi (performans_id, calisan_id, siparis_id, komisyon_tutar, performans_tarihi) VALUES 
(NEXT VALUE FOR PerformansSeq, 1, 1, 17.50, '2024-01-01'),
(NEXT VALUE FOR PerformansSeq, 2, 2, 12.83, '2024-01-02'),
(NEXT VALUE FOR PerformansSeq, 3, 3, 9.50, '2024-01-03');

-- Ürün yorumlarý
INSERT INTO UrunYorumlari (yorum_id, urun_id, musteri_id, yorum_metni, yorum_tarihi, puan) VALUES 
(1, 1, 1, 'Kedim bu mamayý çok seviyor', '2024-01-04', 5),
(2, 2, 2, 'Koku yapmýyor, memnunum', '2024-01-05', 4),
(3, 3, 3, 'Kaliteli malzeme kullanýlmýþ', '2024-01-06', 5),
(4, 4, 4, 'Köpeðim bayýldý', '2024-01-07', 5);

-- Ürün-Tedarikçi iliþkileri
INSERT INTO UrunTedarikci (urun_tedarikci_id, urun_id, tedarikci_id, tedarik_tarihi) VALUES 
(1, 1, 1, '2024-01-01'),
(2, 2, 2, '2024-01-01'),
(3, 3, 3, '2024-01-01'),
(4, 4, 1, '2024-01-02');
