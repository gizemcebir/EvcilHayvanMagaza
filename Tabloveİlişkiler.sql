-- 1. ANA TABLOLAR
-- �r�n kategorilerini tutar (�rn: Kedi, K�pek, Ku� vb.)
CREATE TABLE Kategori (
    kategori_id INT PRIMARY KEY,
    kategori_adi VARCHAR(50) NOT NULL,
    ust_kategori_id INT,
    FOREIGN KEY (ust_kategori_id) REFERENCES Kategori(kategori_id)
);

-- �r�n bilgilerini tutar
CREATE TABLE Urunler (
    urun_id INT PRIMARY KEY,
    urun_adi VARCHAR(50) NOT NULL,
    urun_stok INT NOT NULL CHECK (urun_stok >= 0),
    urun_fiyat DECIMAL(10, 2) NOT NULL CHECK (urun_fiyat > 0),
    kategori_id INT NOT NULL,
    FOREIGN KEY (kategori_id) REFERENCES Kategori(kategori_id)
);

-- Tedarik�i bilgilerini tutar
CREATE TABLE Tedarikciler (
    tedarikci_id INT PRIMARY KEY,
    tedarikci_adi VARCHAR(50) NOT NULL,
    adres VARCHAR(100),
    iletisim_no VARCHAR(15)
);

-- �r�n-Tedarik�i ili�kisini tutar
CREATE TABLE UrunTedarikci (
    urun_tedarikci_id INT PRIMARY KEY,
    urun_id INT NOT NULL,
    tedarikci_id INT NOT NULL,
    tedarik_tarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id),
    FOREIGN KEY (tedarikci_id) REFERENCES Tedarikciler(tedarikci_id)
);

-- M��teri bilgilerini tutar
CREATE TABLE Musteriler (
    musteri_id INT PRIMARY KEY,
    musteri_adi VARCHAR(50) NOT NULL,
    musteri_telefon_no VARCHAR(15),
    kayit_tarihi DATETIME DEFAULT GETDATE()
);

-- M��teri adres bilgilerini tutar
CREATE TABLE Adresler (
    adres_id INT PRIMARY KEY,
    musteri_id INT NOT NULL,
    adres_detayi VARCHAR(100),
    sehir VARCHAR(50),
    posta_kodu VARCHAR(10),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id)
);

-- �al��an bilgilerini tutar
CREATE TABLE Calisanlar (
    calisan_id INT PRIMARY KEY,
    calisan_adi VARCHAR(50) NOT NULL,
    calisan_tel VARCHAR(15),
    calisan_maas DECIMAL(10, 2) CHECK (calisan_maas > 0),
    komisyon DECIMAL(5, 2) CHECK (komisyon BETWEEN 0 AND 100),
    ise_baslama_tarihi DATE DEFAULT GETDATE()
);

-- Sipari� ana bilgilerini tutar
CREATE TABLE Siparisler (
    siparis_id INT IDENTITY(1,1) PRIMARY KEY,
    musteri_id INT NOT NULL,
    calisan_id INT NOT NULL,
    siparis_tarihi DATETIME DEFAULT GETDATE(),
    toplam_fiyat DECIMAL(10, 2) CHECK (toplam_fiyat >= 0),
    siparis_durumu VARCHAR(20) DEFAULT 'Beklemede' 
    CHECK (siparis_durumu IN ('Beklemede', 'Onayland�', 'Haz�rlan�yor', 'Kargoda', 'Tamamland�', '�ptal')),
    FOREIGN KEY (musteri_id) REFERENCES Musteriler(musteri_id),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id)
);

-- Sipari� detaylar�n� tutar
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
    kargo_durumu VARCHAR(50) CHECK (kargo_durumu IN ('Haz�rlan�yor', 'G�nderildi', 'Teslim Edildi', '�ptal')),
    kargo_takip_no VARCHAR(20),
    kargo_tarih DATETIME DEFAULT GETDATE(),
    teslim_tarihi DATETIME,
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id)
);

-- �al��an performans bilgilerini tutar
CREATE TABLE CalisanPerformansi (
    performans_id INT PRIMARY KEY,
    calisan_id INT NOT NULL,
    siparis_id INT NOT NULL,
    komisyon_tutar DECIMAL(10, 2) CHECK (komisyon_tutar >= 0),
    performans_tarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id)
);

-- �r�n yorumlar�n� tutar
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

-- �ade i�lemlerini tutar
CREATE TABLE IadeIslemleri (
    iade_id INT PRIMARY KEY,
    siparis_id INT NOT NULL,
    urun_id INT NOT NULL,
    iade_tarihi DATETIME DEFAULT GETDATE(),
    iade_sebebi VARCHAR(100),
    iade_durumu VARCHAR(20) DEFAULT 'Beklemede' 
    CHECK (iade_durumu IN ('Beklemede', 'Onayland�', 'Reddedildi', 'Tamamland�')),
    FOREIGN KEY (siparis_id) REFERENCES Siparisler(siparis_id),
    FOREIGN KEY (urun_id) REFERENCES Urunler(urun_id)
);
GO

-- 2. SAKLI YORDAMLAR
-- Yeni sipari� ekleme i�lemini ger�ekle�tirir
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
            
            -- Stok kontrol� ve fiyat bilgisi alma
            SELECT @mevcut_stok = urun_stok, @birim_fiyat = urun_fiyat
            FROM Urunler WITH (UPDLOCK)
            WHERE urun_id = @urun_id;
            
            IF @mevcut_stok < @urun_sayisi
                THROW 50001, 'Yetersiz stok!', 1;
            
            SET @toplam_fiyat = @birim_fiyat * @urun_sayisi;
            
            -- Sipari� olu�turma
            INSERT INTO Siparisler (musteri_id, calisan_id, toplam_fiyat)
            VALUES (@musteri_id, @calisan_id, @toplam_fiyat);
            
            DECLARE @siparis_id INT = SCOPE_IDENTITY();
            
            -- Sipari� detay� ekleme
            INSERT INTO SiparisDetay (siparis_detay_id, siparis_id, urun_id, urun_sayisi, birim_fiyat)
            VALUES (NEXT VALUE FOR SiparisDetaySeq, @siparis_id, @urun_id, @urun_sayisi, @birim_fiyat);
            
            -- Stok g�ncelleme
            UPDATE Urunler
            SET urun_stok = urun_stok - @urun_sayisi
            WHERE urun_id = @urun_id;
            
            -- Komisyon i�leme
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

-- �r�n iade i�lemini ger�ekle�tirir
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
            -- �ade talebini do�rulama
            IF NOT EXISTS (
                SELECT 1 
                FROM SiparisDetay 
                WHERE siparis_id = @siparis_id 
                AND urun_id = @urun_id
                AND urun_sayisi >= @iade_miktar
            )
                THROW 50002, 'Ge�ersiz iade talebi', 1;
            
            -- Stok g�ncelleme
            UPDATE Urunler
            SET urun_stok = urun_stok + @iade_miktar
            WHERE urun_id = @urun_id;
            
            -- �ade kayd� olu�turma
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

-- 3. TET�KLEY�C�LER (TRIGGERS)
-- Sipari� detay� eklendi�inde stok kontrol� ve g�ncellemesi yapar
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

-- Kargo durumu g�ncellendi�inde sipari� durumunu g�nceller
CREATE TRIGGER SiparisDurumuGuncelle
ON Kargo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET siparis_durumu = 
        CASE 
            WHEN i.kargo_durumu = 'Haz�rlan�yor' THEN 'Haz�rlan�yor'
            WHEN i.kargo_durumu = 'G�nderildi' THEN 'Kargoda'
            WHEN i.kargo_durumu = 'Teslim Edildi' THEN 'Tamamland�'
            WHEN i.kargo_durumu = '�ptal' THEN '�ptal'
        END
    FROM Siparisler s
    JOIN inserted i ON s.siparis_id = i.siparis_id;
END;
GO

-- 4. �RNEK VER�LER
-- Kategori verileri
INSERT INTO Kategori (kategori_id, kategori_adi, ust_kategori_id) VALUES 
(1, 'Kedi �r�nleri', NULL),
(2, 'K�pek �r�nleri', NULL),
(3, 'Ku� �r�nleri', NULL),
(4, 'Kemirgen �r�nleri', NULL),
(5, 'Mama ve Besinler', 1),
(6, 'Kum ve Hijyen', 1),
(7, 'Oyuncaklar', 1),
(8, 'Mama ve Besinler', 2),
(9, 'Tasma ve Gezdirme', 2),
(10, 'Bak�m �r�nleri', 2);

-- �r�nler
INSERT INTO Urunler (urun_id, urun_adi, urun_stok, urun_fiyat, kategori_id) VALUES 
(1, 'Premium Kedi Mamas� 1kg', 100, 150.00, 5),
(2, 'Kedi Kumu 10L', 75, 200.00, 6),
(3, 'Kedi Oyun �ubu�u', 50, 45.00, 7),
(4, 'Premium K�pek Mamas� 3kg', 80, 250.00, 8),
(5, 'Ayarlanabilir K�pek Tasmas�', 60, 120.00, 9),
(6, 'K�pek �ampuan� 500ml', 40, 85.00, 10),
(7, 'Ku� Yemi 500g', 120, 45.00, 3),
(8, 'Hamster Yemi 250g', 90, 35.00, 4),
(9, 'Kedi T�rmalama Tahtas�', 30, 180.00, 7),
(10, 'K�pek Di� Bak�m Oyunca��', 45, 65.00, 10);

-- Tedarik�iler
INSERT INTO Tedarikciler (tedarikci_id, tedarikci_adi, adres, iletisim_no) VALUES 
(1, 'Pet Beslenme A.�.', '�stanbul, Ata�ehir', '5554443322'),
(2, 'Dostlar Pet Market', 'Ankara, �ankaya', '5553332211'),
(3, 'Global Pet Supplies', '�zmir, Bornova', '5552221100'),
(4, 'Happy Pets Co.', 'Bursa, Nil�fer', '5551110099');

-- M��teriler
INSERT INTO Musteriler (musteri_id, musteri_adi, musteri_telefon_no, kayit_tarihi) VALUES 
(1, 'Ahmet Y�lmaz', '5551234567', '2024-01-01'),
(2, 'Ay�e Demir', '5559876543', '2024-01-02'),
(3, 'Mehmet Kaya', '5557894561', '2024-01-03'),
(4, 'Fatma �ahin', '5553216547', '2024-01-04'),
(5, 'Ali �zt�rk', '5552589631', '2024-01-05');

-- Adresler
INSERT INTO Adresler (adres_id, musteri_id, adres_detayi, sehir, posta_kodu) VALUES 
(1, 1, 'Atat�rk Cad. No:123', '�stanbul', '34100'),
(2, 2, 'Cumhuriyet Mah. 456. Sok.', 'Ankara', '06100'),
(3, 3, 'Bar�� Bulvar� No:789', '�zmir', '35100'),
(4, 4, 'Y�ld�z Sokak No:321', 'Bursa', '16100'),
(5, 5, 'G�l Caddesi No:654', 'Antalya', '07100');

-- �al��anlar
INSERT INTO Calisanlar (calisan_id, calisan_adi, calisan_tel, calisan_maas, komisyon, ise_baslama_tarihi) VALUES 
(1, 'Zeynep Aksoy', '5331234567', 12000.00, 5.00, '2023-06-15'),
(2, 'Murat Y�ld�z', '5332345678', 11000.00, 4.50, '2023-07-01'),
(3, 'Elif �elik', '5333456789', 11500.00, 4.75, '2023-08-15'),
(4, 'Can Demir', '5334567890', 10500.00, 4.25, '2023-09-01');

-- Sipari�ler ve ilgili detaylar
INSERT INTO Siparisler (musteri_id, calisan_id, siparis_tarihi, toplam_fiyat, siparis_durumu) VALUES 
(1, 1, '2024-01-01', 350.00, 'Tamamland�'),
(2, 2, '2024-01-02', 285.00, 'Kargoda'),
(3, 3, '2024-01-03', 200.00, 'Haz�rlan�yor'),
(4, 4, '2024-01-04', 165.00, 'Beklemede');

INSERT INTO SiparisDetay (siparis_detay_id, siparis_id, urun_id, urun_sayisi, birim_fiyat) VALUES 
(NEXT VALUE FOR SiparisDetaySeq, 1, 1, 2, 150.00),
(NEXT VALUE FOR SiparisDetaySeq, 1, 3, 1, 50.00),
(NEXT VALUE FOR SiparisDetaySeq, 2, 2, 1, 200.00),
(NEXT VALUE FOR SiparisDetaySeq, 2, 3, 2, 45.00);

-- Kargo bilgileri
INSERT INTO Kargo (kargo_id, siparis_id, kargo_durumu, kargo_takip_no, kargo_tarih, teslim_tarihi) VALUES 
(1, 1, 'Teslim Edildi', 'TR123456789', '2024-01-01', '2024-01-03'),
(2, 2, 'G�nderildi', 'TR987654321', '2024-01-02', NULL),
(3, 3, 'Haz�rlan�yor', 'TR456789123', '2024-01-03', NULL);

-- �al��an performans kay�tlar�
INSERT INTO CalisanPerformansi (performans_id, calisan_id, siparis_id, komisyon_tutar, performans_tarihi) VALUES 
(NEXT VALUE FOR PerformansSeq, 1, 1, 17.50, '2024-01-01'),
(NEXT VALUE FOR PerformansSeq, 2, 2, 12.83, '2024-01-02'),
(NEXT VALUE FOR PerformansSeq, 3, 3, 9.50, '2024-01-03');

-- �r�n yorumlar�
INSERT INTO UrunYorumlari (yorum_id, urun_id, musteri_id, yorum_metni, yorum_tarihi, puan) VALUES 
(1, 1, 1, 'Kedim bu mamay� �ok seviyor', '2024-01-04', 5),
(2, 2, 2, 'Koku yapm�yor, memnunum', '2024-01-05', 4),
(3, 3, 3, 'Kaliteli malzeme kullan�lm��', '2024-01-06', 5),
(4, 4, 4, 'K�pe�im bay�ld�', '2024-01-07', 5);

-- �r�n-Tedarik�i ili�kileri
INSERT INTO UrunTedarikci (urun_tedarikci_id, urun_id, tedarikci_id, tedarik_tarihi) VALUES 
(1, 1, 1, '2024-01-01'),
(2, 2, 2, '2024-01-01'),
(3, 3, 3, '2024-01-01'),
(4, 4, 1, '2024-01-02');
