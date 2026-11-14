-- =====================================================================
-- database/01_skema.sql
-- Skema database SPK Seleksi Penerima Beasiswa (metode SAW)
-- Rancangan: docs/README-Tahap-02-Perancangan.md (bagian 9)
-- Target   : MySQL 8.4 (memakai CHECK dan kolom turunan)
--
-- PERINGATAN: skrip ini MENGHAPUS lalu membuat ulang 9 tabel sistem beasiswa
--   (admin, periode, kriteria, periode_kriteria, peserta, dokumen,
--    penilaian, hasil_seleksi, log_aktivitas).
--   Tabel lama sistem santri (tbl_*) dan hasil_saw TIDAK disentuh.
--   Jalankan dulu pada database uji (metode_saw_uji), bukan langsung pada
--   database utama. Buat backup sebelum menjalankannya pada database utama.
--
-- Penggunaan (PowerShell):
--   cmd /c "mysql -u root NAMA_DATABASE < database\01_skema.sql"
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS log_aktivitas;
DROP TABLE IF EXISTS hasil_seleksi;
DROP TABLE IF EXISTS penilaian;
DROP TABLE IF EXISTS dokumen;
DROP TABLE IF EXISTS peserta;
DROP TABLE IF EXISTS periode_kriteria;
DROP TABLE IF EXISTS kriteria;
DROP TABLE IF EXISTS periode;
DROP TABLE IF EXISTS admin;

-- ---------------------------------------------------------------------
CREATE TABLE admin (
  id_admin       INT NOT NULL AUTO_INCREMENT,
  username       VARCHAR(50)  NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  nama_lengkap   VARCHAR(100) NOT NULL,
  dibuat_pada    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  login_terakhir TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id_admin),
  UNIQUE KEY uq_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- terbuka_unik bernilai 1 hanya saat status 'Terbuka' dan NULL selain itu.
-- Indeks UNIQUE padanya menjamin paling banyak satu periode berstatus
-- Terbuka pada satu waktu (aturan R2).
CREATE TABLE periode (
  id_periode        INT NOT NULL AUTO_INCREMENT,
  nama_periode      VARCHAR(100) NOT NULL,
  tahun             SMALLINT NOT NULL,
  tanggal_buka      DATE NULL,
  tanggal_tutup     DATE NULL,
  kuota             INT NOT NULL DEFAULT 0,
  status            ENUM('Draf','Terbuka','Tertutup','Diumumkan') NOT NULL DEFAULT 'Draf',
  counter_nomor     INT NOT NULL DEFAULT 0,
  seri_dikonfirmasi TINYINT(1) NOT NULL DEFAULT 0,
  hasil_usang       TINYINT(1) NOT NULL DEFAULT 0,
  tanggal_diumumkan DATETIME NULL,
  is_simulasi       TINYINT(1) NOT NULL DEFAULT 1,
  dibuat_pada       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  terbuka_unik      TINYINT GENERATED ALWAYS AS (IF(status = 'Terbuka', 1, NULL)) STORED,
  PRIMARY KEY (id_periode),
  UNIQUE KEY uq_periode_terbuka (terbuka_unik),
  CONSTRAINT chk_periode_kuota   CHECK (kuota >= 0),
  CONSTRAINT chk_periode_tanggal CHECK (tanggal_buka IS NULL OR tanggal_tutup IS NULL OR tanggal_tutup >= tanggal_buka)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE kriteria (
  id_kriteria INT NOT NULL AUTO_INCREMENT,
  kode        VARCHAR(5)   NOT NULL,
  nama        VARCHAR(100) NOT NULL,
  bobot       DECIMAL(5,4) NOT NULL,
  atribut     ENUM('Cost','Benefit') NOT NULL,
  PRIMARY KEY (id_kriteria),
  UNIQUE KEY uq_kriteria_kode (kode),
  CONSTRAINT chk_kriteria_bobot CHECK (bobot > 0 AND bobot <= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE periode_kriteria (
  id_periode  INT NOT NULL,
  id_kriteria INT NOT NULL,
  bobot       DECIMAL(5,4) NOT NULL,
  atribut     ENUM('Cost','Benefit') NOT NULL,
  PRIMARY KEY (id_periode, id_kriteria),
  CONSTRAINT fk_pk_periode  FOREIGN KEY (id_periode)  REFERENCES periode (id_periode)   ON DELETE CASCADE,
  CONSTRAINT fk_pk_kriteria FOREIGN KEY (id_kriteria) REFERENCES kriteria (id_kriteria)  ON DELETE RESTRICT,
  CONSTRAINT chk_pk_bobot CHECK (bobot > 0 AND bobot <= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE peserta (
  id_peserta           INT NOT NULL AUTO_INCREMENT,
  id_periode           INT NOT NULL,
  no_pendaftaran       VARCHAR(30)  NOT NULL,
  nomor_identitas      VARCHAR(20)  NOT NULL,
  nama                 VARCHAR(100) NOT NULL,
  jenjang              ENUM('SMA','SMK','D3','S1') NOT NULL,
  asal_institusi       VARCHAR(100) NOT NULL,
  no_hp                VARCHAR(20)  NOT NULL,
  email                VARCHAR(100) NULL,
  penghasilan_input    DECIMAL(15,2) NOT NULL,
  tanggungan_input     TINYINT UNSIGNED NOT NULL,
  skala_nilai          ENUM('Rapor100','IPK4') NOT NULL,
  nilai_akademik_input DECIMAL(5,2) NOT NULL,
  ket_prestasi         TEXT NULL,
  ket_organisasi       TEXT NULL,
  status_verifikasi    ENUM('Menunggu','Terverifikasi','Ditolak') NOT NULL DEFAULT 'Menunggu',
  catatan_verifikasi   TEXT NULL,
  id_admin_verifikator INT NULL,
  diverifikasi_pada    DATETIME NULL,
  tanggal_daftar       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_simulasi          TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_peserta),
  UNIQUE KEY uq_peserta_no (no_pendaftaran),
  UNIQUE KEY uq_peserta_identitas (id_periode, nomor_identitas),
  KEY idx_peserta_status (id_periode, status_verifikasi),
  CONSTRAINT fk_peserta_periode     FOREIGN KEY (id_periode)           REFERENCES periode (id_periode) ON DELETE RESTRICT,
  CONSTRAINT fk_peserta_verifikator FOREIGN KEY (id_admin_verifikator) REFERENCES admin (id_admin)     ON DELETE SET NULL,
  CONSTRAINT chk_peserta_skala CHECK (
       (jenjang IN ('SMA','SMK') AND skala_nilai = 'Rapor100')
    OR (jenjang IN ('D3','S1')   AND skala_nilai = 'IPK4')),
  CONSTRAINT chk_peserta_nilai CHECK (
       (skala_nilai = 'Rapor100' AND nilai_akademik_input BETWEEN 0 AND 100)
    OR (skala_nilai = 'IPK4'     AND nilai_akademik_input BETWEEN 0 AND 4)),
  CONSTRAINT chk_peserta_penghasilan CHECK (penghasilan_input >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE dokumen (
  id_dokumen     INT NOT NULL AUTO_INCREMENT,
  id_peserta     INT NOT NULL,
  jenis          ENUM('KK','Penghasilan','Akademik','Prestasi','Organisasi') NOT NULL,
  nama_asli      VARCHAR(255) NOT NULL,
  nama_tersimpan VARCHAR(64)  NOT NULL,
  mime_type      VARCHAR(50)  NOT NULL,
  ukuran_byte    INT UNSIGNED NOT NULL,
  status         ENUM('Menunggu','Valid','Tidak Valid') NOT NULL DEFAULT 'Menunggu',
  catatan        VARCHAR(255) NULL,
  diunggah_pada  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_dokumen),
  UNIQUE KEY uq_dokumen_jenis (id_peserta, jenis),
  UNIQUE KEY uq_dokumen_file (nama_tersimpan),
  CONSTRAINT fk_dokumen_peserta FOREIGN KEY (id_peserta) REFERENCES peserta (id_peserta) ON DELETE CASCADE,
  CONSTRAINT chk_dokumen_ukuran CHECK (ukuran_byte > 0 AND ukuran_byte <= 2097152)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE penilaian (
  id_peserta       INT NOT NULL,
  c1               DECIMAL(15,2) NULL,
  c2               TINYINT UNSIGNED NULL,
  c3               DECIMAL(5,2) NULL,
  c4               TINYINT NULL,
  c5               TINYINT NULL,
  catatan_koreksi  VARCHAR(255) NULL,
  id_admin_penilai INT NULL,
  dinilai_pada     DATETIME NULL,
  PRIMARY KEY (id_peserta),
  CONSTRAINT fk_penilaian_peserta FOREIGN KEY (id_peserta)       REFERENCES peserta (id_peserta) ON DELETE CASCADE,
  CONSTRAINT fk_penilaian_penilai FOREIGN KEY (id_admin_penilai) REFERENCES admin (id_admin)     ON DELETE SET NULL,
  CONSTRAINT chk_penilaian_c1 CHECK (c1 IS NULL OR c1 >= 0),
  CONSTRAINT chk_penilaian_c3 CHECK (c3 IS NULL OR (c3 >= 0 AND c3 <= 100)),
  CONSTRAINT chk_penilaian_c4 CHECK (c4 IS NULL OR (c4 >= 1 AND c4 <= 5)),
  CONSTRAINT chk_penilaian_c5 CHECK (c5 IS NULL OR (c5 >= 1 AND c5 <= 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE hasil_seleksi (
  id_hasil         INT NOT NULL AUTO_INCREMENT,
  id_periode       INT NOT NULL,
  id_peserta       INT NOT NULL,
  nilai_preferensi DECIMAL(10,6) NOT NULL,
  peringkat        INT NOT NULL,
  status           ENUM('Lolos','Tidak Lolos') NOT NULL,
  dihitung_pada    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_admin         INT NULL,
  PRIMARY KEY (id_hasil),
  UNIQUE KEY uq_hasil_peserta   (id_periode, id_peserta),
  UNIQUE KEY uq_hasil_peringkat (id_periode, peringkat),
  CONSTRAINT fk_hasil_periode FOREIGN KEY (id_periode) REFERENCES periode (id_periode) ON DELETE RESTRICT,
  CONSTRAINT fk_hasil_peserta FOREIGN KEY (id_peserta) REFERENCES peserta (id_peserta) ON DELETE RESTRICT,
  CONSTRAINT fk_hasil_admin   FOREIGN KEY (id_admin)   REFERENCES admin (id_admin)     ON DELETE SET NULL,
  CONSTRAINT chk_hasil_peringkat CHECK (peringkat >= 1),
  CONSTRAINT chk_hasil_nilai     CHECK (nilai_preferensi >= 0 AND nilai_preferensi <= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
CREATE TABLE log_aktivitas (
  id_log     INT NOT NULL AUTO_INCREMENT,
  id_admin   INT NULL,
  aksi       VARCHAR(50)  NOT NULL,
  keterangan VARCHAR(255) NULL,
  waktu      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_log),
  CONSTRAINT fk_log_admin FOREIGN KEY (id_admin) REFERENCES admin (id_admin) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;
