# README TAHAP 3 - PERSIAPAN DATABASE DAN DATASET

**Proyek:** SPK Seleksi Penerima Beasiswa Metode SAW Berbasis Web (SDLC Waterfall)
**Tahap:** 3 dari 9
**Lingkungan:** Windows, Laragon, MySQL 8.4.3
**Database:** `metode_saw` (utama) dan `metode_saw_uji` (uji)

---

## 1. Tujuan Tahap

Menyiapkan penyimpanan data sistem beasiswa sesuai rancangan Tahap 2, beserta dataset simulasi yang memuat kasus tepi untuk menguji perhitungan SAW di Tahap 6.

## 2. Ruang Lingkup

1. Mengevaluasi database lama.
2. Menentukan tabel yang dapat digunakan kembali.
3. Membuat tabel.
4. Membuat relasi antar tabel.
5. Memasukkan kriteria dan bobot.
6. Membuat 30 data peserta simulasi.
7. Menyiapkan data penilaian.

Di luar ruang lingkup: perubahan kode aplikasi (Tahap 4 sampai 7), pembuatan akun admin (Tahap 5), dan penghapusan tabel santri lama (Tahap 5).

## 3. Persiapan

- Rancangan database Tahap 2 (bagian 9) dan keputusan D1-D8, R1-R8.
- Backup baru sebelum menyentuh database: `Backup-SPK\metode_saw-sebelum-tahap3.sql` (13.174 byte).
- Database uji terpisah `metode_saw_uji` agar skema diuji sebelum diterapkan ke database utama.

## 4. Evaluasi Database Lama dan Keputusan

Kondisi `metode_saw` sebelum Tahap 3 (11 tabel):

| Tabel | Isi | Keputusan |
|---|---|---|
| `periode`, `peserta`, `kriteria`, `penilaian`, `hasil_seleksi` (percobaan beasiswa) | 1, 5, 5, 5, 0 baris | **Diganti** dengan skema Tahap 2. Kerangkanya dipakai sebagai acuan, tetapi kolom dan batasannya dirapikan |
| `tbl_akun`, `tbl_alternatif`, `tbl_kriteria`, `tbl_subkriteria`, `tbl_nilai`, `hasil_saw` (santri) | 2, 5, 5, 24, 25, 0 baris | **Dipertahankan** sampai Tahap 5, karena halaman admin lama masih memakainya |

Alasan menunda penghapusan tabel `tbl_*`: D4 mensyaratkan penghapusan hanya setelah backup dan persetujuan pengembang. Menghapusnya di Tahap 3 akan merusak halaman admin lama sebelum penggantinya ada (Tahap 5). Penerapan skema baru dilakukan setelah persetujuan pengembang dan hanya menghapus lima tabel beasiswa percobaan, yang isinya sudah tersimpan di backup.

## 5. Struktur Database

Rancangan kolom lengkap ada di `docs/README-Tahap-02-Perancangan.md` bagian 9. Berikut ringkasan hasil implementasi.

| Tabel | Fungsi | Baris awal |
|---|---|---:|
| `admin` | Akun admin (password di-hash; diisi di Tahap 5) | 0 |
| `periode` | Periode seleksi, kuota, status, penghitung nomor | 2 |
| `kriteria` | Master lima kriteria dan bobot bawaan | 5 |
| `periode_kriteria` | Salinan bobot dan atribut per periode (R1) | 10 |
| `peserta` | Data pendaftar dan status verifikasi | 30 |
| `dokumen` | Metadata dokumen persyaratan | 134 |
| `penilaian` | Nilai C1-C5 per peserta | 27 |
| `hasil_seleksi` | Hasil SAW (diisi di Tahap 6) | 0 |
| `log_aktivitas` | Catatan aksi admin | 0 |

Skrip pembuatan tabel: `database/01_skema.sql`.

### 5.1 Relasi (11 foreign key)

| Tabel anak | Kolom | Tabel induk | Aksi hapus |
|---|---|---|---|
| `periode_kriteria` | `id_periode` | `periode` | CASCADE |
| `periode_kriteria` | `id_kriteria` | `kriteria` | RESTRICT |
| `peserta` | `id_periode` | `periode` | RESTRICT |
| `peserta` | `id_admin_verifikator` | `admin` | SET NULL |
| `dokumen` | `id_peserta` | `peserta` | CASCADE |
| `penilaian` | `id_peserta` | `peserta` | CASCADE |
| `penilaian` | `id_admin_penilai` | `admin` | SET NULL |
| `hasil_seleksi` | `id_periode` | `periode` | RESTRICT |
| `hasil_seleksi` | `id_peserta` | `peserta` | RESTRICT |
| `hasil_seleksi` | `id_admin` | `admin` | SET NULL |
| `log_aktivitas` | `id_admin` | `admin` | SET NULL |

### 5.2 Batasan Integritas

| Aturan | Diwujudkan oleh |
|---|---|
| Satu nomor identitas satu kali per periode (A1) | `UNIQUE (id_periode, nomor_identitas)` pada `peserta` |
| Nomor pendaftaran unik (FS-01) | `UNIQUE (no_pendaftaran)` |
| Paling banyak satu periode Terbuka (R2) | Kolom turunan `terbuka_unik` dengan indeks UNIQUE pada `periode` |
| Satu berkas per jenis dokumen (R7) | `UNIQUE (id_peserta, jenis)` pada `dokumen` |
| Skala nilai sesuai jenjang (R6) | CHECK `chk_peserta_skala` dan `chk_peserta_nilai` |
| Rentang nilai C1, C3, C4, C5 | CHECK pada `penilaian` |
| Ukuran dokumen maksimum 2 MB | CHECK `chk_dokumen_ukuran` |
| Bobot di antara 0 dan 1 | CHECK pada `kriteria` dan `periode_kriteria` |
| Kuota tidak negatif dan tanggal tutup tidak sebelum tanggal buka | CHECK pada `periode` |
| Hasil unik per peserta dan per peringkat | `UNIQUE (id_periode, id_peserta)` dan `UNIQUE (id_periode, peringkat)` |
| Peserta yang sudah memiliki hasil tidak bisa terhapus | FK RESTRICT pada `hasil_seleksi` |

Total ada 14 batasan CHECK. Jumlah bobot per periode harus 1: MySQL tidak dapat memeriksa jumlah antarbaris, sehingga dicek oleh pengujian di database dan oleh aplikasi (Tahap 5 dan 6).

### 5.3 Perbedaan terhadap Rancangan Tahap 2

| Perubahan | Alasan |
|---|---|
| Kolom `id_admin` ditambahkan pada `hasil_seleksi` | Mencatat siapa yang menjalankan perhitungan (keterlacakan) |
| Kolom turunan `terbuka_unik` pada `periode` | Mewujudkan aturan R2 langsung di database |
| Batasan CHECK diberi nama (`chk_...`) | Pesan galat MySQL menyebut batasan yang dilanggar sehingga pengujian dapat membedakan penyebabnya |

## 6. Kriteria dan Bobot

Skrip: `database/02_data_awal.sql`.

| Kode | Kriteria | Bobot | Atribut |
|---|---|---:|---|
| C1 | Penghasilan orang tua/keluarga | 0,30 | Cost |
| C2 | Jumlah tanggungan keluarga | 0,20 | Benefit |
| C3 | Nilai akademik | 0,25 | Benefit |
| C4 | Prestasi | 0,15 | Benefit |
| C5 | Keaktifan organisasi/kegiatan sosial | 0,10 | Benefit |

Total bobot = 1,00. Bobot ini disalin ke `periode_kriteria` untuk setiap periode (R1).

## 7. Dataset Simulasi

Skrip: `database/03_dataset_simulasi.sql`. Semua data adalah **simulasi** (`is_simulasi = 1`). Nama, nomor identitas, nomor HP, dan email bersifat fiktif (nomor identitas berawalan `99` atau `SIM`, email `@example.com`, institusi bertanda "Simulasi").

### 7.1 Periode

| Periode | Status | Kuota | Peserta | Kegunaan |
|---|---|---:|---:|---|
| Seleksi Beasiswa 2026 (Simulasi) | Tertutup | 6 | 30 | Pengujian SAW (Tahap 6) |
| Seleksi Beasiswa 2027 (Simulasi) | Terbuka | 5 | 0 | Pengujian pendaftaran publik (Tahap 4) |

### 7.2 Komposisi Peserta Periode 2026

| Kelompok | Jumlah |
|---|---:|
| SMA / SMK / D3 / S1 | 10 / 10 / 5 / 5 |
| Terverifikasi | 27 |
| Menunggu | 1 |
| Ditolak | 2 |
| Layak dihitung SAW (Terverifikasi dengan C1-C5 lengkap) | 25 |

### 7.3 Kasus Uji yang Sengaja Dibuat

| Kasus | Peserta | Tujuan |
|---|---|---|
| Penghasilan 0 | BSW-2026-004, -012, -023 | Menguji aturan D1 (r = 1) |
| Tanggungan 0 | BSW-2026-009 | Menguji normalisasi Benefit dengan nilai 0 |
| Belum dinilai (C4/C5 kosong) | BSW-2026-014, -027 | Menguji B2: tidak ikut perhitungan |
| Ditolak | BSW-2026-007, -019 | Menguji B3: tidak ikut perhitungan |
| Menunggu | BSW-2026-030 | Belum diverifikasi |
| Seri sempurna di batas kuota 6 | BSW-2026-003 (SMA) dan BSW-2026-022 (D3) | Menguji D2: peringatan seri dan aturan urutan; nilai C1-C5 sama persis, lintas jenjang (rapor 84,50 dan IPK 3,38 × 25) |

### 7.3.1 Peringkat Acuan untuk Tahap 6

Dihitung di luar database dengan aritmetika pecahan eksak sesuai rancangan Tahap 2 (bagian 10). Hasil SAW di aplikasi pada Tahap 6 harus sama.

| Peringkat | No. Pendaftaran | Jenjang | V (6 desimal) | Status (kuota 6) |
|---:|---|---|---:|---|
| 1 | BSW-2026-012 | SMA | 0,850895 | Lolos |
| 2 | BSW-2026-004 | SMA | 0,825714 | Lolos |
| 3 | BSW-2026-005 | S1 | 0,719492 | Lolos |
| 4 | BSW-2026-029 | SMK | 0,699912 | Lolos |
| 5 | BSW-2026-006 | SMA | 0,695206 | Lolos |
| 6 | BSW-2026-003 | SMA | 0,677784 | Lolos |
| 7 | BSW-2026-022 | D3 | 0,677784 | Tidak Lolos |
| 8 | BSW-2026-015 | D3 | 0,670766 | Tidak Lolos |
| 9 | BSW-2026-011 | SMK | 0,637253 | Tidak Lolos |
| 10 | BSW-2026-025 | S1 | 0,631900 | Tidak Lolos |

Peringkat 6 dan 7 seri; urutannya ditentukan oleh aturan terakhir (nomor pendaftaran terawal), dan sistem wajib memberi peringatan seri.

### 7.4 Data Penilaian

27 baris `penilaian`: 25 lengkap (C1-C5) dan 2 belum dinilai (C4 dan C5 kosong). Nilai C1-C3 mengikuti aturan R4 (terisi dari isian pendaftar). C3 untuk D3/S1 adalah IPK × 25.

### 7.5 Dokumen

134 baris `dokumen`. Peserta Terverifikasi memiliki tiga dokumen wajib berstatus Valid (R3). Berkas fisik **tidak ada**; barisnya hanya data simulasi. Tahap 5 perlu menangani berkas yang tidak ditemukan dengan pesan yang wajar.

## 8. File yang Dibuat atau Diubah

| File | Aksi |
|---|---|
| `database/01_skema.sql` | Dibuat |
| `database/02_data_awal.sql` | Dibuat |
| `database/03_dataset_simulasi.sql` | Dibuat |
| `database/uji_database.ps1` | Dibuat (58 pengujian otomatis) |
| `docs/README-Tahap-03-Database.md` | Dibuat (dokumen ini) |
| `README-PROJECT.md` | Status Tahap 3 menjadi Selesai |
| `metode_saw.sql` (root) | **Tidak diubah**: dibiarkan sebagai berkas lama sampai halaman lama diganti (Tahap 5) |
| Kode aplikasi PHP | Tidak diubah |
| Database `metode_saw` | Lima tabel beasiswa lama diganti; sembilan tabel baru dibuat; `tbl_*` dan `hasil_saw` tidak berubah |

## 9. Perintah yang Digunakan

```powershell
# Backup sebelum perubahan
mysqldump -u root --result-file="$bak\metode_saw-sebelum-tahap3.sql" metode_saw

# Database uji, lalu penerapan berurutan
mysql -u root -e "CREATE DATABASE metode_saw_uji CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
cmd /c "mysql -u root metode_saw_uji < database\01_skema.sql"
cmd /c "mysql -u root metode_saw_uji < database\02_data_awal.sql"
cmd /c "mysql -u root metode_saw_uji < database\03_dataset_simulasi.sql"

# Pengujian otomatis
powershell -NoProfile -ExecutionPolicy Bypass -File .\database\uji_database.ps1 -Database metode_saw_uji

# Penerapan ke database utama (setelah lolos uji dan disetujui), lalu pengujian ulang
cmd /c "mysql -u root metode_saw < database\01_skema.sql"
cmd /c "mysql -u root metode_saw < database\02_data_awal.sql"
cmd /c "mysql -u root metode_saw < database\03_dataset_simulasi.sql"
powershell -NoProfile -ExecutionPolicy Bypass -File .\database\uji_database.ps1 -Database metode_saw
```

Catatan: `01_skema.sql` menghapus dan membuat ulang sembilan tabel sistem. Menjalankannya ulang pada database yang sudah berisi akun admin akan menghapus akun tersebut.

## 10. Prosedur dan Hasil Pengujian

Skrip `uji_database.ps1` menjalankan 58 pengujian. Pengujian yang mengubah data dibungkus transaksi dan di-ROLLBACK, sehingga isi database tidak berubah. Pengujian "ditolak" memeriksa kode galat MySQL yang spesifik, sehingga penolakan karena alasan yang salah (misalnya salah sintaks) tidak dihitung lolos.

### 10.1 Hasil per Kelompok

| Kelompok | Uji | Hasil pada `metode_saw_uji` | Hasil pada `metode_saw` |
|---|---:|---|---|
| Koneksi dan struktur (tabel, mesin InnoDB, 11 FK, 14 CHECK) | 5 | 5 lolos | 5 lolos |
| Data dan integritas (kriteria, bobot, komposisi, aturan R3 dan R4, konversi C3, nomor pendaftaran, data yatim) | 22 | 22 lolos | 22 lolos |
| Tambah, tampil, ubah, hapus (termasuk CASCADE) | 7 | 7 lolos | 7 lolos |
| Batasan yang harus menolak data salah | 24 | 24 lolos | 24 lolos |
| **Total** | **58** | **58 lolos, 0 gagal** | **58 lolos, 0 gagal** |

### 10.2 Pengujian Sesuai Ketentuan README-PROJECT

| Ketentuan | Bukti | Hasil |
|---|---|---|
| Pengujian koneksi database | Uji 1; `SHOW TABLES` pada kedua database | Lolos |
| Pengujian tambah, tampil, ubah, hapus | Tampil: uji 13-18 dan 25-27; tambah: uji 28, 32, 33; ubah: uji 29; hapus: uji 30 dan 31 | Lolos |
| Pengujian relasi tabel | Uji 4, 30, 31, 37, 55-57 | Lolos |
| Pengujian integritas data | Uji 19-27, 35-54, 58 | Lolos |
| Pemeriksaan total bobot kriteria | Uji 8 (master) dan 10 (tiap periode) | Lolos, total = 1 |

### 10.3 Pengujian Tambahan

| Pengujian | Hasil |
|---|---|
| Batasan `chk_peserta_skala` berdiri sendiri: siswa SMA diberi skala IPK dengan nilai 3,00 (nilai sah menurut skala IPK) | Ditolak dengan `ERROR 3819 ... chk_peserta_skala`. Dilakukan karena uji 39 pada skrip ditolak oleh `chk_peserta_nilai` (membalik skala melanggar kedua batasan sekaligus), sehingga batasan skala belum terbukti terpisah |
| Tabel lama tidak berubah setelah penerapan (jumlah baris `tbl_akun` 2, `tbl_alternatif` 5, `tbl_kriteria` 5, `tbl_subkriteria` 24, `tbl_nilai` 25, `hasil_saw` 0 sebelum dan sesudah) | Identik ("TABEL LAMA TIDAK BERUBAH") |
| `SHOW TABLES` pada `metode_saw` setelah penerapan | 15 tabel: 9 baru, 5 `tbl_*`, `hasil_saw` |
| Aplikasi lama tetap berjalan: login dan halaman data lama | Berhasil (dikonfirmasi pengembang) |

### 10.4 Verifikasi Tambahan di Luar Laragon

Sebelum dijalankan di MySQL, daftar uji yang sama diverifikasi pada SQLite (54 uji portabel lolos), sehingga logika skema dan dataset sudah teruji sebelum sintaks MySQL dibuktikan. Pengujian di MySQL pada Laragon tetap menjadi bukti utama.

## 11. Kendala dan Solusi

| Kendala | Solusi |
|---|---|
| Database `metode_saw_uji` sudah ada saat dibuat (`ERROR 1007`) | Diperiksa dulu isinya (kosong), lalu dibuat ulang; database lain tidak disentuh |
| Berkas kosong `database\metode_saw_uji.sql` (0 byte) muncul di folder proyek | Dihapus dengan perintah yang hanya menghapus berkas berukuran 0 |
| Uji penolakan skala nilai ternyata ditolak oleh batasan lain | Dibuktikan terpisah dengan data yang hanya melanggar `chk_peserta_skala` (bagian 10.3) |
| Uji hitung FK dan CHECK dapat ikut menghitung tabel `tbl_*` pada `metode_saw` | Kueri dibatasi pada sembilan tabel sistem; terbukti benar pada database utama (11 FK dan 14 CHECK) |
| PowerShell tidak mendukung tanda `<` untuk memasukkan berkas SQL | Memakai `cmd /c "mysql ... < berkas"` |
| Kebijakan eksekusi PowerShell dapat memblokir skrip `.ps1` | Skrip dijalankan dengan `-ExecutionPolicy Bypass` hanya untuk sekali jalan |

## 12. Catatan dan Risiko untuk Tahap Berikutnya

| Topik | Catatan | Tahap |
|---|---|---|
| Tabel santri lama (`tbl_*`, `hasil_saw`) | Masih ada; dihapus bersama penggantian halaman admin lama, setelah backup dan persetujuan | 5 |
| Akun admin | Tabel `admin` kosong; akun dibuat bersama kode login, dengan `password_hash` | 5 |
| `metode_saw.sql` di root repository | Masih berisi skema santri lama, termasuk akun lama dengan password `12345`. Diganti dengan skema baru saat halaman lama diganti, dan sebelum repository dibuka ke publik | 5 dan 9 |
| Berkas dokumen fisik | Tidak ada untuk data simulasi; fitur unduh harus menangani berkas hilang | 5 |
| Penerapan ulang skema | `01_skema.sql` menghapus sembilan tabel sistem; jangan dijalankan ulang pada database yang sudah berisi data nyata | semua |
| Pemulihan | Jika skema perlu dibatalkan, database dapat dipulihkan dari `Backup-SPK\metode_saw-sebelum-tahap3.sql` (tidak dijalankan pada tahap ini karena tidak diperlukan) | - |

## 13. Status Penyelesaian

| Kegiatan | Status |
|---|---|
| Evaluasi database lama dan keputusan tabel | Selesai |
| Pembuatan tabel dan relasi | Selesai, 9 tabel, 11 FK, 14 CHECK |
| Kriteria dan bobot | Selesai, total = 1 |
| Dataset 30 peserta dan data penilaian | Selesai |
| Pengujian pada database uji dan database utama | Selesai, 58 dari 58 lolos pada keduanya |
| Aplikasi lama tetap berjalan | Terkonfirmasi |
| README Tahap 3 | Selesai |
| Commit dan push ke GitHub | Dikerjakan pengembang (bagian 14) |
| Verifikasi di GitHub | Setelah push |

**Tahap 3 dinyatakan selesai setelah push berhasil dan file terlihat di GitHub.**

## 14. Informasi Commit Git

```powershell
git add database/01_skema.sql database/02_data_awal.sql database/03_dataset_simulasi.sql database/uji_database.ps1 docs/README-Tahap-03-Database.md README-PROJECT.md
git commit -m "Tahap 3: database dan dataset simulasi"
git push
```

| Item | Nilai |
|---|---|
| Pesan commit | `Tahap 3: database dan dataset simulasi` |
| Repository | `muftiabunaseh0924/spk-beasiswa-saw` (Private) |
| Branch | `main` |
| Hash commit | Lihat dengan `git log --oneline -1` |
