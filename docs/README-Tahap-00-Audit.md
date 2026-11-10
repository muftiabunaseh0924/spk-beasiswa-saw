# README TAHAP 0 - AUDIT DAN PERSIAPAN PROYEK

**Proyek:** SPK Seleksi Penerima Beasiswa Metode SAW Berbasis Web (SDLC Waterfall)
**Tanggal pengerjaan:** 10 November 2026
**Lingkungan:** Windows, Laragon (Apache, MySQL 8.4.3), PHP, Git

---

## 1. Tujuan Tahap

Memeriksa kondisi awal proyek sebelum ada perubahan apa pun, agar tahap berikutnya dikerjakan di atas dasar yang diketahui dengan jelas. Pada tahap ini **tidak ada kode aplikasi atau database yang diubah**.

## 2. Ruang Lingkup

1. Memeriksa struktur folder dan source code PHP.
2. Memeriksa database dan struktur tabel.
3. Memeriksa konfigurasi koneksi database dan Laragon.
4. Membuat backup proyek dan database.
5. Menguji bahwa website dapat dibuka dan koneksi database berjalan.
6. Menyiapkan repository GitHub milik pengembang.

## 3. Persiapan

- Laragon (Apache dan MySQL aktif), PHP CLI, Git, PowerShell.
- Proyek berada di `D:\File Coding Random\A-decision-support-system`.
- Proyek dihubungkan ke Laragon dengan *junction* `C:\laragon\www\A-decision-support-system`, sehingga tidak ada salinan ganda.
- Repository GitHub kosong milik pengembang: `https://github.com/muftiabunaseh0924/spk-beasiswa-saw`.

## 4. Langkah Pengerjaan

1. Membaca README-PROJECT.md dan memetakan 10 tahap pengembangan.
2. Memetakan seluruh file proyek (28 file terlacak Git) dan riwayat commit.
3. Membaca konfigurasi koneksi (`assets/conn/config.php`), login (`index.php`), pengecekan sesi (`assets/conn/cek.php`), dan logika SAW lama (`admin/metode.php`).
4. Memeriksa `metode_saw.sql` dan membandingkannya dengan database yang benar-benar ada di MySQL lokal.
5. Memindai pola keamanan: query SQL, proteksi sesi, penanganan error, dependensi eksternal.
6. Membuat backup folder proyek dan database.
7. Menjalankan pengujian (bagian 8).
8. Memindahkan remote Git ke repository milik pengembang (bagian 11).

## 5. Hasil Audit

### 5.1 Kondisi Proyek

| Aspek | Temuan |
|---|---|
| Domain aplikasi | SPK pemilihan **santri** pesantren (bukan beasiswa) |
| Teknologi | PHP native, `mysqli`, Bootstrap 5.3.2 (CDN) dan `cosmo.min.css` |
| Jumlah file | 28 file terlacak: 22 file PHP di `admin/` dan `index.php`, 2 file konfigurasi, aset, SQL |
| Koneksi database | `assets/conn/config.php`, host `127.0.0.1`, user `root`, database `metode_saw` |
| Riwayat Git | 4 commit; kode asal berasal dari repository `bagasksm/penerapan-metode-saw` |
| README lama | Bahasa Inggris, merujuk XAMPP dan domain santri |

Catatan asal kode: proyek ini dikembangkan dari proyek PHP SAW milik pihak lain (`bagasksm/penerapan-metode-saw`). Atribusi sumber asli dipertahankan, dan pengembang memastikan penggunaannya diizinkan oleh pemilik aslinya.

### 5.2 Kondisi Database

Database `metode_saw` di MySQL lokal berisi **11 tabel dalam dua kelompok yang tidak saling terhubung**:

| Kelompok | Tabel | Dipakai kode aplikasi? | Penilaian awal |
|---|---|---|---|
| Santri (lama) | `tbl_alternatif`, `tbl_kriteria`, `tbl_subkriteria`, `tbl_nilai`, `hasil_saw` | Ya (kecuali `hasil_saw`) | Akan digantikan |
| Beasiswa (percobaan awal) | `periode`, `peserta`, `kriteria`, `penilaian`, `hasil_seleksi` | Hanya oleh draf `metode.php` lokal | Kerangka layak dipakai ulang |
| Akun | `tbl_akun` | Ya | Dipakai ulang, password harus di-hash |

Isi tabel beasiswa saat ini: `periode` 1 baris (kuota 3, berlabel simulasi), `kriteria` 5 baris (C1-C5, bobot dan atribut sudah sesuai README-PROJECT), `peserta` 5 baris data simulasi (target: 30), `penilaian` 5 baris, `hasil_seleksi` 0 baris.

Hal yang sudah baik pada tabel beasiswa: relasi kunci asing, `peserta.jenjang` ENUM SMA/SMK/D3/S1, `hasil_seleksi.status` ENUM Lolos/Tidak Lolos, `c3` bertipe `decimal(5,2)` (skala 0-100), `c4`/`c5` bertipe `tinyint` (skala 1-5), `no_pendaftaran` unik.

Kekurangan terhadap README-PROJECT (bahan Tahap 2-3):

- Belum ada tabel **dokumen persyaratan** (unggah dan verifikasi dokumen).
- `periode` belum punya status, tanggal, dan penanda **sudah diumumkan**.
- `peserta` belum menyimpan data pendaftaran lengkap dan catatan verifikasi.
- `penilaian` memakai kolom tetap `c1`-`c5` yang tidak terhubung ke tabel `kriteria`.
- `hasil_seleksi` belum punya batasan unik (periode, peserta), sehingga hasil bisa ganda.
- **`metode_saw.sql` di repository tidak sama dengan database lokal**: tabel beasiswa belum ada di file SQL. Orang yang meng-clone proyek tidak akan memperoleh database yang sama. Diperbaiki di Tahap 3.

### 5.3 Temuan Keamanan dan Kualitas

| # | Temuan | Dampak | Terbukti? | Tahap perbaikan |
|---|---|---|---|---|
| 1 | `cek.php` tidak memakai `exit` setelah redirect dan path redirect `../../index.php` salah (seharusnya `../index.php`). File `cetak_*.php` tidak memeriksa sesi sama sekali | Halaman admin dapat dibuka tanpa login | **Ya, diuji** (lihat 8.1) | 5 |
| 2 | Semua query menyisipkan input langsung ke SQL, termasuk login | Rentan SQL injection | Dari pembacaan kode | 5 |
| 3 | Password plaintext (`12345`), kolom `varchar(30)` | Tidak aman | Dari pembacaan kode dan SQL | 3 dan 5 |
| 4 | `error_reporting(0)` di `header.php` | Error tersembunyi | Dari pembacaan kode | 5 |
| 5 | `header.php` mengeluarkan HTML sebelum `header("location:...")` di file `*proses.php` | Redirect setelah simpan bisa gagal diam-diam | Dugaan, belum diuji | 5 |
| 6 | Perhitungan SAW dan penulisan ke database terjadi di halaman tampilan | Sulit diuji, berisiko | Dari pembacaan kode | 6 |
| 7 | Normalisasi dibulatkan `round(..., 2)` sebelum dikali bobot | Nilai preferensi tidak presisi | Dari pembacaan kode | 6 |
| 8 | Min/max diambil dari nilai skala sub-kriteria, bukan data peserta; belum ada penanganan nilai nol untuk Cost dan nilai seri; status Lolos hanya `ranking <= 1` | Tidak sesuai README-PROJECT | Dari pembacaan kode | 2 dan 6 |
| 9 | Draf `admin/metode.php` lokal (belum di-commit) memanggil `../koneksi.php` yang tidak ada, mengarahkan ke `login.php` yang tidak ada, dan memakai tabel beasiswa | Tidak dapat berjalan pada proyek saat ini | Bagian `require_once` terbukti ada dan file `koneksi.php` terbukti tidak ada; belum dibuka di browser | 5-6 |
| 10 | `metode_saw.sql` memuat akun dengan nama pengembang asli dan password `12345` | Bocor jika repository publik | Dari pembacaan SQL | 3 |

### 5.4 Draf `metode.php` Lokal sebagai Bahan Tahap 6

Draf lokal (versi beasiswa, belum di-commit) sudah memuat ide yang bagus dan akan dipertimbangkan di Tahap 6: *prepared statement*, token CSRF, transaksi database untuk penyimpanan hasil, penanganan penghasilan nol pada kriteria Cost (r = 1), deteksi nilai seri pada batas kuota, dan aturan *tie-break* (V menurun, penghasilan terendah, nilai akademik tertinggi, nomor pendaftaran). Aturan penghasilan nol dan *tie-break* ini **belum diputuskan secara resmi**; keputusannya ditetapkan di Tahap 2 sebelum kode dibuat, sesuai README-PROJECT bagian 6.

Kelemahan draf: bergantung pada file dan halaman yang tidak ada, pengecekan login longgar (menerima salah satu dari empat kunci sesi), tidak memakai `header.php`, dan menghapus hasil lama tanpa memeriksa apakah sudah diumumkan.

Sikap pada tahap ini: draf **tidak diubah dan tidak di-commit**. File asli tetap aman di `Backup-SPK\proyek-sebelum-tahap0` dan `Backup-SPK\metode-lokal.php`.

## 6. File yang Dibuat atau Diubah

| File | Aksi |
|---|---|
| `docs/README-Tahap-00-Audit.md` | Dibuat (dokumen ini) |
| `README-PROJECT.md` | Status Tahap 0 diubah menjadi Selesai |
| Kode aplikasi dan database | **Tidak diubah** |
| `admin/metode.php` (lokal) | Tidak diubah dan tidak di-commit |
| File sampah `ql  Select-Object...` | Dihapus (hasil paste perintah yang terpotong; bukan bagian proyek) |

Di luar repository: `D:\File Coding Random\Backup-SPK\` dan junction `C:\laragon\www\A-decision-support-system`.

## 7. Perintah yang Digunakan

```powershell
# Backup folder proyek (di luar folder proyek)
$src = "D:\File Coding Random\A-decision-support-system"
$bak = "D:\File Coding Random\Backup-SPK"
New-Item -ItemType Directory -Force $bak | Out-Null
Copy-Item -Recurse $src "$bak\proyek-sebelum-tahap0"

# Backup database dan struktur database
mysqldump -u root --result-file="$bak\metode_saw-sebelum-tahap0.sql" metode_saw
mysqldump -u root --no-data --result-file="$bak\struktur-db-saat-ini.sql" metode_saw

# Hubungkan proyek ke Laragon
New-Item -ItemType Junction -Path "C:\laragon\www\A-decision-support-system" -Target $src

# Pengujian sintaks dan isi database
Get-ChildItem -Recurse -Filter *.php | ForEach-Object { php -l $_.FullName }
mysql -u root -e "SHOW DATABASES"
mysql -u root metode_saw -e "SELECT * FROM periode; SELECT * FROM kriteria; SELECT * FROM peserta;"
```

Catatan: pada PowerShell, jangan memakai `>` untuk dump database karena dapat menyimpan file dalam UTF-16; gunakan `--result-file`.

## 8. Prosedur dan Hasil Pengujian

| No | Pengujian | Prosedur | Hasil |
|---|---|---|---|
| 1 | Sintaks PHP | `php -l` pada 24 file PHP | **Lolos**, tanpa error sintaks |
| 2 | Koneksi MySQL | `SHOW DATABASES` dan `SHOW TABLES` | **Berhasil**, database `metode_saw` terbaca (11 tabel) |
| 3 | Website dapat dibuka dan koneksi aplikasi berjalan | Membuka halaman login lalu login dengan akun lama | **Berhasil**, masuk dashboard |
| 4 | Backup folder proyek | Memeriksa isi `Backup-SPK` | **Berhasil** |
| 5 | Backup database | Memeriksa ukuran file dump | **Berhasil** (13.174 byte; struktur 8.815 byte) |
| 6 | Proteksi halaman admin tanpa login | Membuka halaman admin di jendela tanpa sesi login | **GAGAL diproteksi**: data tetap tampil |
| 7 | Keberadaan `koneksi.php` yang dirujuk draf `metode.php` lokal | `Test-Path koneksi.php` | `False` (tidak ada) |

### 8.1 Catatan Pengujian 6

Hasil ini mengonfirmasi temuan #1. Pengujian **tidak** dilakukan dengan menghapus atau mengubah data. Kemungkinan aksi tambah, ubah, dan hapus juga tidak terlindungi karena memakai mekanisme proteksi yang sama, tetapi hal itu tidak diuji. Kegagalan ini bukan penghambat Tahap 0 karena tahap ini hanya audit. Perbaikannya wajib selesai di Tahap 5 dan diuji ulang di Tahap 8.

## 9. Kendala dan Solusi

| Kendala | Solusi |
|---|---|
| Perintah awal memakai placeholder `<nama-folder>` dan folder `C:\laragon\backup` yang tidak ada | Memakai path sebenarnya di drive D: dan membuat folder `Backup-SPK` |
| Variabel PowerShell `$bak` kosong setelah sesi berganti, file struktur tersimpan di `D:\` | File dipindahkan ke `Backup-SPK`, ukuran diverifikasi |
| Proyek berada di drive D: sedangkan Laragon melayani `C:\laragon\www` | Dibuat *junction* ke folder proyek |
| Import `metode_saw.sql` berhenti pada error `hasil_saw already exists` | Tidak ada data berubah; database tidak diimpor ulang karena berisi tabel beasiswa yang tidak ada di file SQL |
| `metode.php` lokal berbeda dari versi Git | Diaudit terpisah; draf disimpan di backup dan tidak di-commit |
| Remote Git awal mengarah ke akun pihak lain (`bagasksm`) dengan penulisan salah (`..git`) | Remote dipindahkan ke repository milik pengembang (bagian 11) |
| File sampah hasil paste terminal di folder proyek | Dihapus sebelum commit |

## 10. Rekomendasi untuk Tahap Berikutnya

- **Tahap 1:** Analisis kebutuhan berdasarkan README-PROJECT; belum bergantung pada struktur database saat ini.
- **Tahap 2:** Putuskan secara resmi aturan penghasilan nol (Cost), aturan nilai seri pada batas kuota, dan apakah tabel `kriteria`/`penilaian` dipakai ulang atau dirancang ulang.
- **Tahap 3:** Satukan `metode_saw.sql` dengan skema beasiswa final, hapus tabel santri lama setelah ada persetujuan dan backup, hash password, dan ganti data akun dengan akun simulasi.
- **Tahap 5:** Perbaiki proteksi sesi, SQL injection, dan penanganan error.
- Pertimbangkan menjadikan repository **Private** sampai data akun dan password awal dibersihkan.

## 11. Informasi Commit Git

Remote dipindahkan ke repository milik pengembang:

```powershell
git remote set-url origin https://github.com/muftiabunaseh0924/spk-beasiswa-saw.git
```

Perintah commit dan push:

```powershell
git add README-PROJECT.md docs/README-Tahap-00-Audit.md
git commit -m "Tahap 0: audit dan persiapan proyek"
git push -u origin main
```

Hanya dua file yang ditambahkan secara eksplisit. `admin/metode.php` lokal sengaja **tidak** ikut di-commit.

| Item | Nilai |
|---|---|
| Pesan commit | `Tahap 0: audit dan persiapan proyek` |
| Repository | `https://github.com/muftiabunaseh0924/spk-beasiswa-saw` |
| Branch | `main` |
| Hash commit | Lihat dengan `git log --oneline -1` |

## 12. Status Penyelesaian

| Kegiatan | Status |
|---|---|
| Audit struktur, kode, dan database | Selesai |
| Backup proyek dan database | Selesai |
| Pengujian | Selesai (satu pengujian gagal sebagai temuan audit, dijadwalkan di Tahap 5) |
| README Tahap 0 | Selesai |
| Commit dan push ke GitHub | Dikerjakan pengembang sesuai bagian 11 |
| Verifikasi di GitHub | Setelah push |

**Tahap 0 dinyatakan selesai setelah push berhasil dan file terlihat di GitHub.**
