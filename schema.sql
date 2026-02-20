CREATE DATABASE IF NOT EXISTS hastane_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE hastane_db;

SET FOREIGN_KEY_CHECKS = 0;

-- branş tablosu
CREATE TABLE IF NOT EXISTS branslar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(100) NOT NULL UNIQUE,
  aciklama TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- poliklinik tablosu
CREATE TABLE IF NOT EXISTS poliklinikler (
  id INT AUTO_INCREMENT PRIMARY KEY,
  brans_id INT NOT NULL,
  ad VARCHAR(120) NOT NULL,
  aciklama TEXT,
  calisma_saatleri VARCHAR(100),
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (brans_id) REFERENCES branslar(id) ON DELETE RESTRICT ON UPDATE CASCADE
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- klinik tablosu
CREATE TABLE IF NOT EXISTS klinikler (
  id INT AUTO_INCREMENT PRIMARY KEY,
  brans_id INT NOT NULL,
  ad VARCHAR(120) NOT NULL,
  aciklama TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (brans_id) REFERENCES branslar(id) ON DELETE RESTRICT ON UPDATE CASCADE
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- doktor tablosu
CREATE TABLE IF NOT EXISTS doktorlar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(80) NOT NULL,
  soyad VARCHAR(80) NOT NULL,
  unvan VARCHAR(80),
  brans_id INT NOT NULL,
  telefon VARCHAR(30),
  eposta VARCHAR(120),
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (brans_id) REFERENCES branslar(id) ON DELETE RESTRICT ON UPDATE CASCADE
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- hasta tablosu (TC_NO CHAR(11) yapıldı, Adres parçalandı)
CREATE TABLE IF NOT EXISTS hastalar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tc_no CHAR(11) NOT NULL UNIQUE,
  ad VARCHAR(80) NOT NULL,
  soyad VARCHAR(80) NOT NULL,
  dogum_tarihi DATE,
  cinsiyet ENUM('Erkek','Kadın','Diğer') DEFAULT 'Diğer',
  telefon VARCHAR(30),
  il VARCHAR(50),
  ilce VARCHAR(50),
  acik_adres TEXT,
  kan_grubu VARCHAR(5),
  sigorta_sirketi VARCHAR(120),
  sigorta_no VARCHAR(80),
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- doktor dışı personel tablosu
CREATE TABLE IF NOT EXISTS personel_listesi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(80) NOT NULL,
  soyad VARCHAR(80) NOT NULL,
  gorev VARCHAR(100),
  departman VARCHAR(100),
  telefon VARCHAR(30),
  eposta VARCHAR(120),
  personel_no VARCHAR(50) UNIQUE,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- odaların tablosu
CREATE TABLE IF NOT EXISTS odalar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  klinik_id INT NOT NULL,
  oda_no VARCHAR(20) NOT NULL,
  yatak_sayisi INT DEFAULT 1,
  aciklama TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY (klinik_id, oda_no),
  FOREIGN KEY (klinik_id) REFERENCES klinikler(id) ON DELETE RESTRICT ON UPDATE CASCADE
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- randevu tablosu
CREATE TABLE IF NOT EXISTS randevular (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  doktor_id INT NOT NULL,
  poliklinik_id INT NOT NULL,
  baslangic DATETIME NOT NULL,
  bitis DATETIME,
  durum ENUM('bekliyor','onaylandı','iptal') DEFAULT 'bekliyor',
  neden TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doktor_id) REFERENCES doktorlar(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (poliklinik_id) REFERENCES poliklinikler(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_randevu_hasta (hasta_id),
  INDEX idx_randevu_doktor (doktor_id),
  INDEX idx_randevu_zaman (baslangic)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- acil servis kayıtlarının tablosu
CREATE TABLE IF NOT EXISTS acil_servis (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  gelis_saati DATETIME NOT NULL,
  triaj_seviyesi TINYINT,
  muayene_eden_doktor_id INT,
  ilk_tani TEXT,
  sonuc ENUM('taburcu','yatış','sevk','transfer') DEFAULT 'taburcu',
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (muayene_eden_doktor_id) REFERENCES doktorlar(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_acil_hasta (hasta_id),
  INDEX idx_acil_zaman (gelis_saati)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- yatan hasta kayıtlarının tablosu
CREATE TABLE IF NOT EXISTS yatislar (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  klinik_id INT NOT NULL,
  yatisi_baslatan_doktor_id INT,
  sorumlu_doktor_id INT,
  oda_id INT,
  yatak_no VARCHAR(20),
  yatma_tarihi DATETIME NOT NULL,
  cikis_tarihi DATETIME,
  neden TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (klinik_id) REFERENCES klinikler(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (yatisi_baslatan_doktor_id) REFERENCES doktorlar(id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (sorumlu_doktor_id) REFERENCES doktorlar(id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (oda_id) REFERENCES odalar(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_yatis_hasta (hasta_id),
  INDEX idx_yatis_tarih (yatma_tarihi, cikis_tarihi)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- teşhisler tablo
CREATE TABLE IF NOT EXISTS teshis (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  doktor_id INT NOT NULL,
  baglam ENUM('poliklinik','klinik','acil') NOT NULL,
  baglam_id BIGINT,
  teshis_metni TEXT NOT NULL,
  teshis_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doktor_id) REFERENCES doktorlar(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_teshis_hasta (hasta_id),
  INDEX idx_teshis_tarih (teshis_tarihi)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- tahlil türlerinin tablo
CREATE TABLE IF NOT EXISTS tahlil_turleri (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kod VARCHAR(50) UNIQUE,
  ad VARCHAR(150) NOT NULL,
  aciklama TEXT,
  ucret DECIMAL(10,2) DEFAULT 0.00,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- tahlil sonuçlarının tablosu (personel_listesi referansı düzeltildi)
CREATE TABLE IF NOT EXISTS tahlil_sonuclari (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  tahlil_turu_id INT NOT NULL,
  isteyen_doktor_id INT,
  yapan_personel_id INT,
  ornek_tarihi DATETIME,
  sonuc_tarihi DATETIME,
  sonuc_verisi TEXT,
  sonuc_metni TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (tahlil_turu_id) REFERENCES tahlil_turleri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (isteyen_doktor_id) REFERENCES doktorlar(id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (yapan_personel_id) REFERENCES personel_listesi(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_tahlil_hasta (hasta_id),
  INDEX idx_tahlil_tarih (ornek_tarihi, sonuc_tarihi)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ilaç tablosu
CREATE TABLE IF NOT EXISTS ilaclar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(200) NOT NULL,
  form VARCHAR(80),
  etken_madde VARCHAR(200),
  firma VARCHAR(150),
  fiyat DECIMAL(10,2) DEFAULT 0.00,
  olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_ilac (ad, etken_madde)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- reçete tablosu
CREATE TABLE IF NOT EXISTS receteler (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  yazan_doktor_id INT NOT NULL,
  baglam ENUM('poliklinik','klinik','acil') NOT NULL,
  baglam_id BIGINT,
  recete_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP,
  notlar TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (yazan_doktor_id) REFERENCES doktorlar(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_recete_hasta (hasta_id),
  INDEX idx_recete_tarih (recete_tarihi)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- reçete öğelerinin tablosu
CREATE TABLE IF NOT EXISTS recete_ogeleri (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  recete_id BIGINT NOT NULL,
  ilac_id INT NOT NULL,
  doz VARCHAR(80),
  doz_araliği VARCHAR(80),
  sure_gun INT,
  notlar TEXT,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (recete_id) REFERENCES receteler(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (ilac_id) REFERENCES ilaclar(id) ON DELETE RESTRICT ON UPDATE CASCADE
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- tedavi kayıtlarının tablosu
CREATE TABLE IF NOT EXISTS tedavi_kayitlari (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hasta_id INT NOT NULL,
  doktor_id INT NOT NULL,
  baglam ENUM('poliklinik','klinik','acil') NOT NULL,
  baglam_id BIGINT,
  tedavi_turu VARCHAR(150),
  aciklama TEXT,
  ucret DECIMAL(10,2),
  tarih DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hasta_id) REFERENCES hastalar(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doktor_id) REFERENCES doktorlar(id) ON DELETE RESTRICT ON UPDATE CASCADE
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- fiyat listesi tablosu
CREATE TABLE IF NOT EXISTS fiyat_listesi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kalem_turu ENUM('poliklinik_ucreti','tedavi_ucreti','oda_ucreti','tahlil_ucreti','ilac_ucreti') NOT NULL,
  referans_id INT,
  ad VARCHAR(200),
  fiyat DECIMAL(12,2) NOT NULL,
  para_birimi VARCHAR(5) DEFAULT 'TRY',
  baslangic_tarihi DATE,
  bitis_tarihi DATE,
  kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  referans_tablo ENUM('poliklinik','tedaviler','odalar','tahlil_turleri','ilaclar','diger') NULL,
  birim VARCHAR(20) DEFAULT 'adet',
  INDEX idx_fiyat_turu (kalem_turu, referans_id)
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
