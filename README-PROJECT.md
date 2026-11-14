# README PROJECT
# SISTEM PENDUKUNG KEPUTUSAN SELEKSI PENERIMA BEASISWA

## 1. Informasi Proyek

**Judul Penelitian:**

Implementasi Sistem Pendukung Keputusan (SPK) Seleksi Penerima Beasiswa Menggunakan Metode SAW Berbasis Web dengan Pendekatan SDLC Waterfall.

**Metode Pengambilan Keputusan:** Simple Additive Weighting (SAW)

**Metode Pengembangan Sistem:** SDLC Waterfall

**Teknologi yang Digunakan:**
- PHP
- MySQL/MariaDB
- HTML
- CSS
- JavaScript
- Bootstrap (jika sesuai dengan proyek)
- Laragon
- Git dan GitHub

**Lingkungan Pengembangan:** Windows

## 2. Deskripsi Proyek

Proyek ini bertujuan membangun Sistem Pendukung Keputusan (SPK) berbasis web untuk membantu proses seleksi penerima beasiswa bagi pelajar dan mahasiswa.

Sistem menggunakan metode Simple Additive Weighting (SAW) untuk melakukan perhitungan berdasarkan beberapa kriteria yang telah ditentukan.

Pengembangan sistem menggunakan pendekatan SDLC Waterfall, yaitu proses pengembangan perangkat lunak yang dilakukan secara bertahap mulai dari analisis kebutuhan, perancangan, implementasi, pengujian, hingga pemeliharaan dan dokumentasi.

Aplikasi dikembangkan berdasarkan proyek PHP yang sudah tersedia, kemudian disesuaikan dengan kebutuhan sistem seleksi penerima beasiswa.

## 3. Tujuan Proyek

1. Membangun aplikasi SPK seleksi penerima beasiswa berbasis web.
2. Mengimplementasikan metode SAW untuk membantu proses penilaian.
3. Mempermudah pengelolaan data pendaftar dan dokumen persyaratan.
4. Membantu admin melakukan verifikasi dan penilaian peserta.
5. Menghasilkan keputusan seleksi berdasarkan bobot kriteria dan kuota.
6. Menyediakan informasi hasil seleksi secara transparan melalui nomor pendaftaran.

## 4. Ruang Lingkup Sistem

### 4.1 Pengguna Sistem

**Admin**
- Login ke sistem.
- Mengelola periode seleksi.
- Mengatur kuota penerima beasiswa.
- Mengelola data peserta.
- Memverifikasi dokumen.
- Mengelola kriteria dan bobot.
- Memberikan nilai kriteria.
- Melakukan perhitungan SAW.
- Melihat hasil perangkingan.
- Mengumumkan hasil seleksi.
- Membuat laporan.

**Pendaftar**
- Melihat informasi beasiswa.
- Melihat persyaratan.
- Melakukan pendaftaran.
- Mengunggah dokumen persyaratan.
- Mendapatkan nomor pendaftaran.
- Memeriksa status seleksi menggunakan nomor pendaftaran.

Pendaftar tidak memerlukan akun login. Pengelolaan sistem dilakukan oleh admin.

### 4.2 Jenjang Pendidikan

Sistem mencakup:
- SMA
- SMK
- D3
- S1

### 4.3 Jumlah Data Pengujian

Direncanakan menggunakan 30 data peserta simulasi:

| Jenjang | Jumlah |
|---|---:|
| SMA | 10 |
| SMK | 10 |
| D3 | 5 |
| S1 | 5 |
| Total | 30 |

Data tersebut merupakan data simulasi untuk kebutuhan pengembangan dan pengujian, bukan data penerima beasiswa sebenarnya.

## 5. Kriteria dan Bobot Metode SAW

Sistem menggunakan lima kriteria berikut:

| Kode | Kriteria | Bobot | Atribut |
|---|---|---:|---|
| C1 | Penghasilan orang tua/keluarga | 30% | Cost |
| C2 | Jumlah tanggungan keluarga | 20% | Benefit |
| C3 | Nilai akademik | 25% | Benefit |
| C4 | Prestasi akademik/nonakademik | 15% | Benefit |
| C5 | Keaktifan organisasi/kegiatan sosial | 10% | Benefit |
| | Total | 100% | |

### 5.1 Aturan Penilaian

**C1 - Penghasilan**
- Menggunakan nominal penghasilan bulanan dalam rupiah.
- Termasuk kriteria Cost.
- Semakin rendah penghasilan, semakin tinggi prioritasnya.
- Penanganan penghasilan nol harus ditetapkan secara khusus sebelum implementasi rumus.

**C2 - Jumlah Tanggungan**
- Menggunakan jumlah tanggungan keluarga.
- Termasuk kriteria Benefit.
- Semakin banyak tanggungan, semakin tinggi nilai prioritas.

**C3 - Nilai Akademik**
- SMA/SMK menggunakan rata-rata nilai rapor skala 0–100.
- D3/S1 menggunakan IPK yang dikonversi ke skala 0–100.
- Jika IPK menggunakan skala 4, konversi yang digunakan adalah IPK dikalikan 25 (diubah pada Tahap 2, lihat docs/README-Tahap-02-Perancangan.md).
- Termasuk kriteria Benefit.

**C4 - Prestasi**
- Skala penilaian 1–5.
- 1: Tidak memiliki prestasi.
- 2: Tingkat sekolah/kampus.
- 3: Tingkat kota/kabupaten.
- 4: Tingkat provinsi.
- 5: Tingkat nasional/internasional.

**C5 - Keaktifan**
- Skala penilaian 1–5.
- 1: Tidak aktif.
- 2: Pernah mengikuti kegiatan.
- 3: Aktif sebagai anggota.
- 4: Aktif sebagai pengurus.
- 5: Memimpin atau menginisiasi kegiatan.

Nilai prestasi dan keaktifan diberikan oleh admin berdasarkan bukti yang telah diverifikasi.

## 6. Rumus Metode SAW

### 6.1 Normalisasi

Kriteria Benefit:

r_ij = x_ij / max(x_j)

Kriteria Cost:

r_ij = min(x_j) / x_ij

### 6.2 Perhitungan Nilai Preferensi

V_i = Σ(w_j × r_ij)

Keterangan:
- V_i = nilai preferensi peserta.
- w_j = bobot kriteria.
- r_ij = nilai hasil normalisasi.
- x_ij = nilai awal peserta.

Bobot yang digunakan:

- C1 = 0,30
- C2 = 0,20
- C3 = 0,25
- C4 = 0,15
- C5 = 0,10

Hasil preferensi diurutkan dari nilai tertinggi ke nilai terendah.

Peserta yang dinyatakan lolos ditentukan berdasarkan kuota pada periode seleksi yang sedang berlangsung.

Ketentuan khusus untuk nilai nol pada kriteria Cost dan aturan jika terjadi nilai seri pada batas kuota harus ditetapkan pada tahap perancangan sebelum kode perhitungan dibuat.

## 7. Rencana Tahapan Pengembangan

Pengembangan menggunakan pendekatan SDLC Waterfall dan dibagi menjadi sepuluh tahap.

### TAHAP 0 - Audit dan Persiapan Proyek

Tujuan:
Memeriksa kondisi awal proyek sebelum melakukan perubahan.

Aktivitas:
1. Memeriksa struktur folder proyek.
2. Memeriksa source code PHP.
3. Memeriksa database lama.
4. Memeriksa struktur tabel.
5. Memeriksa konfigurasi koneksi database.
6. Memeriksa konfigurasi Laragon.
7. Membuat backup proyek dan database.

Pengujian:
- Memastikan website dapat dibuka.
- Memastikan koneksi database berjalan.
- Memastikan tidak ada kesalahan awal yang menghambat pengembangan.

Output:
- Hasil audit proyek.
- Backup proyek.
- Dokumentasi struktur database.
- README-Tahap-00-Audit.md.

### TAHAP 1 - Analisis Kebutuhan Sistem

Tujuan:
Menentukan kebutuhan dan fungsi aplikasi beasiswa.

Aktivitas:
1. Menentukan kebutuhan pengguna.
2. Menentukan kebutuhan fungsional.
3. Menentukan kebutuhan nonfungsional.
4. Menentukan alur pendaftaran.
5. Menentukan alur verifikasi.
6. Menentukan alur penilaian.
7. Menentukan alur seleksi dan pengumuman.

Pengujian:
- Memeriksa kelengkapan kebutuhan.
- Memeriksa kesesuaian fitur dengan tujuan penelitian.

Output:
- Dokumen analisis kebutuhan.
- Daftar fitur sistem.
- README-Tahap-01-Analisis.md.

### TAHAP 2 - Perancangan Sistem

Tujuan:
Membuat rancangan sistem sebelum implementasi.

Aktivitas:
1. Membuat Use Case Diagram.
2. Membuat Activity Diagram.
3. Membuat Entity Relationship Diagram (ERD).
4. Merancang struktur database.
5. Merancang alur metode SAW.
6. Merancang halaman publik.
7. Merancang halaman admin.

Pengujian:
- Memeriksa alur proses.
- Memeriksa relasi database.
- Memeriksa kesesuaian rancangan dengan kebutuhan.

Output:
- Diagram sistem.
- Rancangan database.
- Rancangan antarmuka.
- README-Tahap-02-Perancangan.md.

### TAHAP 3 - Persiapan Database dan Dataset

Tujuan:
Menyiapkan penyimpanan data sistem.

Aktivitas:
1. Mengevaluasi database lama.
2. Menentukan tabel yang dapat digunakan kembali.
3. Membuat atau menyesuaikan tabel.
4. Membuat relasi antar tabel.
5. Memasukkan kriteria dan bobot.
6. Membuat 30 data peserta simulasi.
7. Menyiapkan data penilaian.

Pengujian:
- Pengujian koneksi database.
- Pengujian tambah, tampil, ubah, dan hapus data.
- Pengujian relasi tabel.
- Pengujian integritas data.
- Pemeriksaan total bobot kriteria.

Output:
- Database sistem beasiswa.
- Dataset simulasi.
- Dokumentasi struktur tabel.
- README-Tahap-03-Database.md.

### TAHAP 4 - Implementasi Halaman Publik

Tujuan:
Membangun antarmuka yang digunakan pendaftar.

Aktivitas:
1. Membuat halaman beranda.
2. Membuat informasi beasiswa.
3. Membuat halaman persyaratan.
4. Membuat formulir pendaftaran.
5. Membuat fitur unggah dokumen.
6. Membuat nomor pendaftaran otomatis.
7. Membuat halaman cek status seleksi.

Pengujian:
- Menguji formulir pendaftaran.
- Menguji validasi input.
- Menguji unggah dokumen.
- Menguji pembuatan nomor pendaftaran.
- Menguji pencarian status.

Output:
- Halaman publik.
- Formulir pendaftaran.
- Fitur cek status.
- README-Tahap-04-Halaman-Publik.md.

### TAHAP 5 - Implementasi Halaman Admin

Tujuan:
Membangun panel pengelolaan sistem.

Aktivitas:
1. Membuat login admin.
2. Membuat dashboard.
3. Membuat pengelolaan periode seleksi.
4. Membuat pengaturan kuota.
5. Membuat pengelolaan peserta.
6. Membuat verifikasi dokumen.
7. Membuat pengelolaan kriteria.
8. Membuat halaman penilaian peserta.

Pengujian:
- Menguji login dan logout.
- Menguji hak akses.
- Menguji pengelolaan peserta.
- Menguji pengaturan kuota.
- Menguji verifikasi dokumen.
- Menguji penyimpanan nilai.

Output:
- Dashboard admin.
- Fitur pengelolaan data.
- Fitur verifikasi dan penilaian.
- README-Tahap-05-Admin.md.

### TAHAP 6 - Implementasi Metode SAW

Tujuan:
Mengimplementasikan perhitungan SAW ke dalam aplikasi.

Aktivitas:
1. Mengambil peserta yang telah diverifikasi.
2. Mengambil nilai kriteria.
3. Membentuk matriks keputusan.
4. Melakukan normalisasi.
5. Menghitung nilai preferensi.
6. Mengurutkan hasil perhitungan.
7. Menentukan hasil berdasarkan kuota.

Pengujian:
- Menghitung data secara manual.
- Membandingkan perhitungan manual dengan aplikasi.
- Menguji kriteria Benefit.
- Menguji kriteria Cost.
- Menguji penghasilan nol.
- Menguji nilai seri.
- Menguji perubahan kuota.

Output:
- Modul perhitungan SAW.
- Hasil normalisasi.
- Hasil preferensi.
- Hasil perangkingan.
- README-Tahap-06-Metode-SAW.md.

### TAHAP 7 - Hasil Seleksi dan Pengumuman

Tujuan:
Menyediakan fitur pengumuman hasil seleksi.

Aktivitas:
1. Membuat halaman hasil perangkingan admin.
2. Membuat persetujuan pengumuman.
3. Membuat halaman pengumuman publik.
4. Menampilkan status Lolos atau Tidak Lolos.
5. Membatasi akses sebelum pengumuman.
6. Membuat laporan hasil seleksi.

Pengujian:
- Menguji penentuan peserta berdasarkan kuota.
- Menguji status seleksi.
- Menguji pencarian nomor pendaftaran.
- Menguji pembatasan hasil sebelum diumumkan.
- Menguji laporan seleksi.

Output:
- Halaman hasil seleksi.
- Halaman pengumuman.
- Laporan seleksi.
- README-Tahap-07-Hasil-Seleksi.md.

### TAHAP 8 - Pengujian Sistem dan Keamanan

Tujuan:
Memastikan sistem berjalan sesuai kebutuhan.

Aktivitas:
1. Menguji setiap fitur.
2. Menguji integrasi antar fitur.
3. Menguji alur sistem secara menyeluruh.
4. Menguji validasi input.
5. Menguji autentikasi admin.
6. Menguji keamanan unggahan dokumen.
7. Memperbaiki kesalahan yang ditemukan.

Metode pengujian:
- Black Box Testing.
- Integration Testing.
- Pengujian perhitungan SAW.
- Pengujian hak akses.
- User Acceptance Testing (UAT), jika tersedia pengguna penguji.

Output:
- Tabel hasil pengujian.
- Daftar kesalahan dan perbaikan.
- README-Tahap-08-Pengujian.md.

### TAHAP 9 - Finalisasi dan Dokumentasi

Tujuan:
Menyelesaikan aplikasi dan menyiapkan dokumentasi akhir.

Aktivitas:
1. Memeriksa seluruh fitur.
2. Merapikan struktur proyek.
3. Memperbarui README utama.
4. Membuat petunjuk instalasi.
5. Mengumpulkan screenshot aplikasi.
6. Menyusun dokumentasi pengujian.
7. Menyiapkan dokumentasi untuk laporan penelitian.

Pengujian:
- Mencoba instalasi dari awal.
- Menguji aplikasi secara menyeluruh.
- Memastikan dokumentasi instalasi sesuai kondisi sebenarnya.

Output:
- Aplikasi final.
- Dokumentasi instalasi.
- Dokumentasi pengujian.
- README-Final.md.

## 8. Standar Penyelesaian Setiap Tahap

Setiap tahap wajib mengikuti prosedur berikut:

1. Menjelaskan tujuan dan ruang lingkup tahap.
2. Menjelaskan langkah pengerjaan secara rinci.
3. Menjelaskan file yang dibuat atau diubah.
4. Memberikan perintah yang perlu dijalankan.
5. Menjelaskan fungsi perubahan.
6. Melakukan pengujian.
7. Memperbaiki kesalahan jika ditemukan.
8. Membuat README tahap.
9. Melakukan Git commit.
10. Melakukan Git push.
11. Memverifikasi perubahan pada GitHub.

Tahap dinyatakan selesai hanya jika seluruh pekerjaan dan pengujian yang diwajibkan telah dilakukan.

Jika terdapat pengujian gagal, tahap harus diperbaiki sebelum melanjutkan.

## 9. Standar Dokumentasi README

Setiap README tahap minimal memuat:

- Nama dan tujuan tahap.
- Ruang lingkup pekerjaan.
- Persiapan yang diperlukan.
- Langkah pengerjaan.
- File yang dibuat atau diubah.
- Perintah yang digunakan.
- Penjelasan implementasi.
- Prosedur pengujian.
- Hasil pengujian.
- Kendala dan solusi.
- Status penyelesaian.
- Informasi commit Git.

README utama ini menjadi panduan keseluruhan proyek, sedangkan README setiap tahap menjelaskan proses pengerjaan secara lebih rinci.

## 10. Standar Git dan GitHub

Setiap tahap yang telah selesai harus disimpan ke GitHub.

Contoh perintah:

```bash
git status
git add .
git commit -m "Tahap 1: analisis kebutuhan sistem"
git push origin main
```

Catatan:
- Repository GitHub harus milik pengembang atau repository yang memiliki izin akses.
- Jangan melakukan push ke repository asli milik orang lain tanpa izin.
- Periksa perubahan sebelum melakukan commit.
- Jangan memasukkan password, API key, file rahasia, atau konfigurasi sensitif.
- File database backup dan dokumen yang berisi data pribadi harus dikelola secara aman.
- Pastikan README tahap sudah tersedia sebelum push.

## 11. Rencana Struktur Dokumentasi

```text
A-decision-support-system/
│
├── README.md
├── README-PROJECT.md
│
├── docs/
│   ├── README-Tahap-00-Audit.md
│   ├── README-Tahap-01-Analisis.md
│   ├── README-Tahap-02-Perancangan.md
│   ├── README-Tahap-03-Database.md
│   ├── README-Tahap-04-Halaman-Publik.md
│   ├── README-Tahap-05-Admin.md
│   ├── README-Tahap-06-Metode-SAW.md
│   ├── README-Tahap-07-Hasil-Seleksi.md
│   ├── README-Tahap-08-Pengujian.md
│   └── README-Final.md
│
├── admin/
├── assets/
├── index.php
└── metode_saw.sql
```

Struktur di atas merupakan rancangan dokumentasi. Struktur kode yang sudah ada tidak akan diubah sebelum dilakukan audit.

## 12. Ketentuan Pengembangan

1. Metode pengambilan keputusan tetap menggunakan SAW.
2. Metode pengembangan tetap menggunakan SDLC Waterfall.
3. Sistem ditujukan untuk pendaftar jenjang SMA, SMK, D3, dan S1.
4. Peserta melakukan pendaftaran melalui halaman publik.
5. Admin bertanggung jawab atas verifikasi dokumen dan penilaian.
6. Kuota dapat diatur berdasarkan periode seleksi.
7. Hasil publik hanya menampilkan status Lolos atau Tidak Lolos.
8. Hasil tidak dipublikasikan sebelum disetujui admin.
9. Data simulasi harus dibedakan dari data nyata.
10. Setiap tahap harus memiliki dokumentasi dan pengujian.
11. Setiap tahap yang selesai harus disimpan ke GitHub.
12. Tidak melakukan penghapusan database atau perubahan besar tanpa backup dan persetujuan.

## 13. Status Proyek

| Tahap | Nama Tahap | Status |
|---|---|---|
| 0 | Audit dan Persiapan Proyek | Selesai |
| 1 | Analisis Kebutuhan Sistem | Selesai |
| 2 | Perancangan Sistem | Selesai |
| 3 | Persiapan Database dan Dataset | Selesai |
| 4 | Implementasi Halaman Publik | Belum dimulai |
| 5 | Implementasi Halaman Admin | Belum dimulai |
| 6 | Implementasi Metode SAW | Belum dimulai |
| 7 | Hasil Seleksi dan Pengumuman | Belum dimulai |
| 8 | Pengujian Sistem dan Keamanan | Belum dimulai |
| 9 | Finalisasi dan Dokumentasi | Belum dimulai |

## 14. Penutup

Pengembangan aplikasi SPK seleksi penerima beasiswa ini dilakukan secara bertahap menggunakan pendekatan SDLC Waterfall.

Setiap tahap akan melalui proses analisis, implementasi, pengujian, dokumentasi, dan penyimpanan perubahan ke GitHub.

Dengan proses tersebut, diharapkan aplikasi yang dibangun memiliki struktur yang baik, perhitungan SAW yang benar, keamanan data yang memadai, serta dokumentasi yang dapat dipertanggungjawabkan untuk kebutuhan penelitian akademik.