-- =====================================================================
-- database/02_data_awal.sql
-- Data awal: lima kriteria dan bobot bawaan (README-PROJECT bagian 5).
-- Jalankan setelah 01_skema.sql.
--   cmd /c "mysql -u root NAMA_DATABASE < database\02_data_awal.sql"
-- =====================================================================
SET NAMES utf8mb4;

INSERT INTO kriteria (kode, nama, bobot, atribut) VALUES
('C1', 'Penghasilan orang tua/keluarga',        0.3000, 'Cost'),
('C2', 'Jumlah tanggungan keluarga',            0.2000, 'Benefit'),
('C3', 'Nilai akademik',                        0.2500, 'Benefit'),
('C4', 'Prestasi',                              0.1500, 'Benefit'),
('C5', 'Keaktifan organisasi/kegiatan sosial',  0.1000, 'Benefit');
