-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: localhost:3306:3306
-- Üretim Zamanı: 31 Ara 2024, 17:05:59
-- Sunucu sürümü: 9.0.1
-- PHP Sürümü: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `veritabaniodev`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `DoktorTecrubeListele` ()   BEGIN
    SELECT DoktorAd, DoktorUzmanlikAlani, DoktorTecrubeYillari
    FROM doktorlar
    WHERE DoktorTecrubeYillari >= 20;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GeriAlHastaDegisiklikler` (IN `baslangicTarihi` DATETIME, IN `bitisTarihi` DATETIME)   BEGIN
    -- Değişiklikleri geri alabilmek için cursor oluşturma
    DECLARE done INT DEFAULT 0;
    DECLARE v_HastaSSN INT;
    DECLARE v_Ozellik VARCHAR(50);
    DECLARE v_EskiDeger VARCHAR(255);
    DECLARE v_YeniDeger VARCHAR(255);

    -- Cursor'ı tanımlıyoruz: HastaDegisiklik tablosunda yapılan değişiklikleri alıyoruz
    DECLARE cur CURSOR FOR
        SELECT HastaSSN, Ozellik, EskiDeger, YeniDeger
        FROM HastaDegisiklik
        WHERE DegisimZamani BETWEEN baslangicTarihi AND bitisTarihi;

    -- Handler'ı tanımlıyoruz
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Cursor'ı açıyoruz
    OPEN cur;

    -- Cursor'dan gelen her bir değişiklik için işlemleri geri alıyoruz
    read_loop: LOOP
        FETCH cur INTO v_HastaSSN, v_Ozellik, v_EskiDeger, v_YeniDeger;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Değişikliklere göre geri alma işlemi
        IF v_Ozellik = 'HastaAd' THEN
            UPDATE hastalar SET HastaAd = v_EskiDeger WHERE HastaSSN = v_HastaSSN;
        ELSEIF v_Ozellik = 'HastaAdres' THEN
            UPDATE hastalar SET HastaAdres = v_EskiDeger WHERE HastaSSN = v_HastaSSN;
        ELSEIF v_Ozellik = 'HastaYas' THEN
            UPDATE hastalar SET HastaYas = v_EskiDeger WHERE HastaSSN = v_HastaSSN;
        ELSEIF v_Ozellik = 'birincil_doktor_id' THEN
            UPDATE hastalar SET birincil_doktor_id = v_EskiDeger WHERE HastaSSN = v_HastaSSN;
        END IF;

    END LOOP;

    -- Cursor'ı kapatıyoruz
    CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ListeleUzmanDoktorlar` ()   BEGIN
    SELECT Ad, Uzmanlik, TecrubeYillari
    FROM Doktor
    WHERE TecrubeYillari >= 20;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YasGrubuListele` ()   BEGIN
    SELECT HastaSSN, HastaAd, HastaAdres
    FROM hastalar
    WHERE HastaYas >= 65;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `doktorhastailiski`
--

CREATE TABLE `doktorhastailiski` (
  `DoktorSSN` int NOT NULL,
  `HastaSSN` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `doktorlar`
--

CREATE TABLE `doktorlar` (
  `DoktorSSN` int NOT NULL,
  `DoktorAd` varchar(50) NOT NULL,
  `DoktorUzmanlikAlani` varchar(100) NOT NULL,
  `DoktorTecrubeYillari` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `doktorlar`
--

INSERT INTO `doktorlar` (`DoktorSSN`, `DoktorAd`, `DoktorUzmanlikAlani`, `DoktorTecrubeYillari`) VALUES
(1, 'Dr. Ahmet Yılmaz', 'Genel Cerrahi', 15),
(123456789, 'Ahmet', 'Kardiyoloji', 25),
(234567890, 'Fatma', 'Dahiliye', 15),
(345678901, 'Ali', 'Göz', 18),
(456789123, 'Mehmet', 'Ortopedi', 22),
(987654321, 'Ayşe', 'Nöroloji', 30);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `eczaneler`
--

CREATE TABLE `eczaneler` (
  `eczane_id` int NOT NULL,
  `eczane_ad` varchar(100) NOT NULL,
  `eczane_adres` varchar(150) NOT NULL,
  `eczane_telefon` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `eczaneler`
--

INSERT INTO `eczaneler` (`eczane_id`, `eczane_ad`, `eczane_adres`, `eczane_telefon`) VALUES
(1, 'Eczane A', 'İstanbul, Beyoğlu', '0212-1234567'),
(2, 'Eczane B', 'Ankara, Çankaya', '0312-9876543');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `eczane_ilac_fiyatlar`
--

CREATE TABLE `eczane_ilac_fiyatlar` (
  `eczane_id` int NOT NULL,
  `ticari_ad` varchar(100) NOT NULL,
  `firma_ad` varchar(100) NOT NULL,
  `fiyat` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `eczane_ilac_fiyatlar`
--

INSERT INTO `eczane_ilac_fiyatlar` (`eczane_id`, `ticari_ad`, `firma_ad`, `fiyat`) VALUES
(1, 'Paracetamol', 'ABC İlaç', 12.50);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hastadegisiklik`
--

CREATE TABLE `hastadegisiklik` (
  `DegisiklikID` int NOT NULL,
  `HastaSSN` int DEFAULT NULL,
  `DegisenAlan` varchar(50) DEFAULT NULL,
  `EskiDeger` varchar(255) DEFAULT NULL,
  `YeniDeger` varchar(255) DEFAULT NULL,
  `DegisiklikTarihi` datetime DEFAULT CURRENT_TIMESTAMP,
  `Ozellik` varchar(50) DEFAULT NULL,
  `DegisimZamani` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `hastadegisiklik`
--

INSERT INTO `hastadegisiklik` (`DegisiklikID`, `HastaSSN`, `DegisenAlan`, `EskiDeger`, `YeniDeger`, `DegisiklikTarihi`, `Ozellik`, `DegisimZamani`) VALUES
(1, 123456789, NULL, 'Ayşe Yılmaz', 'Ali Veli', '2024-12-31 18:25:49', 'HastaAd', '2024-12-31 18:25:49'),
(2, 123456789, NULL, 'Ankara, Çankaya', 'Yeni Adres, İstanbul', '2024-12-31 18:25:49', 'HastaAdres', '2024-12-31 18:25:49'),
(3, 123456789, NULL, 'Ahmet Yılmaz', 'Ali Veli', '2024-12-31 18:48:00', 'HastaAd', '2024-05-01 10:00:00'),
(4, 123456789, NULL, 'Eski Adres', 'Yeni Adres', '2024-12-31 18:48:00', 'HastaAdres', '2024-06-01 11:00:00');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hastalar`
--

CREATE TABLE `hastalar` (
  `HastaSSN` int NOT NULL,
  `HastaAd` varchar(50) NOT NULL,
  `HastaAdres` varchar(150) NOT NULL,
  `HastaYas` int DEFAULT NULL,
  `birincil_doktor_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `hastalar`
--

INSERT INTO `hastalar` (`HastaSSN`, `HastaAd`, `HastaAdres`, `HastaYas`, `birincil_doktor_id`) VALUES
(1, 'Ali Can', 'Örnek Mah. No:10, İstanbul', 30, 1),
(111223344, 'Ali Veli', 'İstanbul, Kadıköy', 70, 1),
(123456789, 'Ahmet Yılmaz', 'Eski Adres', 80, 2),
(456789012, 'Hasan Demir', 'Antalya, Muratpaşa', 90, 5),
(567890123, 'Fatma Arslan', 'İzmir, Konak', 55, 4),
(987654321, 'Mehmet Kaya', 'Bursa, Nilüfer', 67, 3);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `ilacfirmalari`
--

CREATE TABLE `ilacfirmalari` (
  `firma_ad` varchar(100) NOT NULL,
  `telefon_no` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `ilacfirmalari`
--

INSERT INTO `ilacfirmalari` (`firma_ad`, `telefon_no`) VALUES
('ABC İlaç', '0123456789'),
('ABD İlaç', '0212-1234567'),
('Akif İlaç', '0232-4589236'),
('Anadolu İlaç', '0224-6743289'),
('BioMed', '0312-2233445'),
('Biyo İlaç', '0222-1597530'),
('DEF İlaç', '0987654321'),
('Farmak', '0232-6587412'),
('GaleniX', '0216-8654310'),
('İlaçsan', '0216-1239876'),
('İstanbul Farma', '0216-6748321'),
('Max Farma', '0312-2231889'),
('Medikal Farma', '0312-4782639'),
('Nobel İlaç', '0212-1237654'),
('Novartis İlaç', '0216-1234560'),
('Optima İlaç', '0224-3579846'),
('Penta Farma', '0221-1236547'),
('Sifa İlaç', '0224-8991234'),
('Süper Farma', '0216-3589746'),
('UltraFarm', '0312-5862387'),
('VitaFarm', '0312-3344556'),
('XYZ İlaç', '0212-7654321');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `ilacfirmasieczanesozlesmeleri`
--

CREATE TABLE `ilacfirmasieczanesozlesmeleri` (
  `sozlesme_id` int NOT NULL,
  `firma_ad` varchar(100) NOT NULL,
  `eczane_id` int NOT NULL,
  `sozlesme_baslangic_tarihi` date NOT NULL,
  `sozlesme_bitis_tarihi` date NOT NULL,
  `sozlesme_metni` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `ilaclar`
--

CREATE TABLE `ilaclar` (
  `ticari_ad` varchar(100) NOT NULL,
  `formül` varchar(255) NOT NULL,
  `firma_ad` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `ilaclar`
--

INSERT INTO `ilaclar` (`ticari_ad`, `formül`, `firma_ad`) VALUES
('Aerius', 'C19H22ClN3O2', 'BioMed'),
('Amoksisilin', 'C16H19N3O5S', 'Farmak'),
('Antibiotik', 'C15H21NO3', 'Optima İlaç'),
('Aspirin', 'C9H8O4', 'DEF İlaç'),
('Aspirin', 'C9H8O4', 'İlaçsan'),
('Deksametazon', 'C22H29FO5', 'Sifa İlaç'),
('Fluoxetine', 'C17H18F3NO', 'Max Farma'),
('Hidroklorotiazid', 'C7H8ClN3O4S2', 'İstanbul Farma'),
('Ibuprofen', 'C13H18O2', 'ABC İlaç'),
('Ibuprofen', 'C13H18O2', 'XYZ İlaç'),
('Kalsiyum', 'Ca', 'Novartis İlaç'),
('Lisinopril', 'C9H15N2O5', 'Anadolu İlaç'),
('Lisinopril', 'C9H15N2O5', 'Süper Farma'),
('Loratadin', 'C22H23ClN2O2', 'Penta Farma'),
('Metformin', 'C4H11N5', 'Biyo İlaç'),
('Metoprolol', 'C15H25NO3', 'Akif İlaç'),
('Paracetamol', 'C8H9NO2', 'ABC İlaç'),
('Parol', 'C10H11NO3', 'GaleniX'),
('Prednol', 'C21H28O5', 'VitaFarm'),
('Prilosec', 'C17H18N3O3S', 'UltraFarm'),
('Simvastatin', 'C25H38O5', 'Nobel İlaç'),
('Vitamin C', 'C6H8O6', 'Medikal Farma');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `receteler`
--

CREATE TABLE `receteler` (
  `DoktorSSN` int NOT NULL,
  `HastaSSN` int NOT NULL,
  `ticari_ad` varchar(100) NOT NULL,
  `firma_ad` varchar(100) NOT NULL,
  `tarih` date NOT NULL,
  `miktar` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `doktorhastailiski`
--
ALTER TABLE `doktorhastailiski`
  ADD PRIMARY KEY (`DoktorSSN`,`HastaSSN`),
  ADD KEY `HastaSSN` (`HastaSSN`);

--
-- Tablo için indeksler `doktorlar`
--
ALTER TABLE `doktorlar`
  ADD PRIMARY KEY (`DoktorSSN`);

--
-- Tablo için indeksler `eczaneler`
--
ALTER TABLE `eczaneler`
  ADD PRIMARY KEY (`eczane_id`);

--
-- Tablo için indeksler `eczane_ilac_fiyatlar`
--
ALTER TABLE `eczane_ilac_fiyatlar`
  ADD PRIMARY KEY (`eczane_id`,`ticari_ad`,`firma_ad`),
  ADD KEY `ticari_ad` (`ticari_ad`,`firma_ad`);

--
-- Tablo için indeksler `hastadegisiklik`
--
ALTER TABLE `hastadegisiklik`
  ADD PRIMARY KEY (`DegisiklikID`);

--
-- Tablo için indeksler `hastalar`
--
ALTER TABLE `hastalar`
  ADD PRIMARY KEY (`HastaSSN`);

--
-- Tablo için indeksler `ilacfirmalari`
--
ALTER TABLE `ilacfirmalari`
  ADD PRIMARY KEY (`firma_ad`);

--
-- Tablo için indeksler `ilacfirmasieczanesozlesmeleri`
--
ALTER TABLE `ilacfirmasieczanesozlesmeleri`
  ADD PRIMARY KEY (`sozlesme_id`),
  ADD KEY `firma_ad` (`firma_ad`),
  ADD KEY `eczane_id` (`eczane_id`);

--
-- Tablo için indeksler `ilaclar`
--
ALTER TABLE `ilaclar`
  ADD PRIMARY KEY (`ticari_ad`,`firma_ad`),
  ADD KEY `firma_ad` (`firma_ad`);

--
-- Tablo için indeksler `receteler`
--
ALTER TABLE `receteler`
  ADD PRIMARY KEY (`DoktorSSN`,`HastaSSN`,`ticari_ad`,`firma_ad`),
  ADD KEY `HastaSSN` (`HastaSSN`),
  ADD KEY `ticari_ad` (`ticari_ad`,`firma_ad`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `doktorlar`
--
ALTER TABLE `doktorlar`
  MODIFY `DoktorSSN` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=987654322;

--
-- Tablo için AUTO_INCREMENT değeri `eczaneler`
--
ALTER TABLE `eczaneler`
  MODIFY `eczane_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `hastadegisiklik`
--
ALTER TABLE `hastadegisiklik`
  MODIFY `DegisiklikID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `hastalar`
--
ALTER TABLE `hastalar`
  MODIFY `HastaSSN` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=987654322;

--
-- Tablo için AUTO_INCREMENT değeri `ilacfirmasieczanesozlesmeleri`
--
ALTER TABLE `ilacfirmasieczanesozlesmeleri`
  MODIFY `sozlesme_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `doktorhastailiski`
--
ALTER TABLE `doktorhastailiski`
  ADD CONSTRAINT `doktorhastailiski_ibfk_1` FOREIGN KEY (`DoktorSSN`) REFERENCES `doktorlar` (`DoktorSSN`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `doktorhastailiski_ibfk_2` FOREIGN KEY (`HastaSSN`) REFERENCES `hastalar` (`HastaSSN`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Tablo kısıtlamaları `eczane_ilac_fiyatlar`
--
ALTER TABLE `eczane_ilac_fiyatlar`
  ADD CONSTRAINT `eczane_ilac_fiyatlar_ibfk_1` FOREIGN KEY (`eczane_id`) REFERENCES `eczaneler` (`eczane_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eczane_ilac_fiyatlar_ibfk_2` FOREIGN KEY (`ticari_ad`,`firma_ad`) REFERENCES `ilaclar` (`ticari_ad`, `firma_ad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Tablo kısıtlamaları `ilacfirmasieczanesozlesmeleri`
--
ALTER TABLE `ilacfirmasieczanesozlesmeleri`
  ADD CONSTRAINT `ilacfirmasieczanesozlesmeleri_ibfk_1` FOREIGN KEY (`firma_ad`) REFERENCES `ilacfirmalari` (`firma_ad`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ilacfirmasieczanesozlesmeleri_ibfk_2` FOREIGN KEY (`eczane_id`) REFERENCES `eczaneler` (`eczane_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Tablo kısıtlamaları `ilaclar`
--
ALTER TABLE `ilaclar`
  ADD CONSTRAINT `ilaclar_ibfk_1` FOREIGN KEY (`firma_ad`) REFERENCES `ilacfirmalari` (`firma_ad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Tablo kısıtlamaları `receteler`
--
ALTER TABLE `receteler`
  ADD CONSTRAINT `receteler_ibfk_1` FOREIGN KEY (`DoktorSSN`) REFERENCES `doktorlar` (`DoktorSSN`) ON DELETE CASCADE,
  ADD CONSTRAINT `receteler_ibfk_2` FOREIGN KEY (`HastaSSN`) REFERENCES `hastalar` (`HastaSSN`) ON DELETE CASCADE,
  ADD CONSTRAINT `receteler_ibfk_3` FOREIGN KEY (`ticari_ad`,`firma_ad`) REFERENCES `ilaclar` (`ticari_ad`, `firma_ad`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
