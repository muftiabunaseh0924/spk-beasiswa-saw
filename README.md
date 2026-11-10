# 🎓 SPK SELEKSI PENERIMA BEASISWA

### Sistem Pendukung Keputusan Menggunakan Metode Simple Additive Weighting (SAW)

<p align="center">
  <img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white" />
  <img src="https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white" />
  <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black" />
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
</p>

---

## 📌 Tentang Proyek

SPK Seleksi Penerima Beasiswa merupakan aplikasi Sistem Pendukung Keputusan (SPK) berbasis web yang dikembangkan untuk membantu proses seleksi calon penerima beasiswa secara lebih terstruktur, objektif, dan transparan.

Sistem ini menggunakan metode **Simple Additive Weighting (SAW)** sebagai metode pengambilan keputusan dengan mempertimbangkan beberapa kriteria dan bobot penilaian.

Pengembangan proyek ini merupakan pengembangan lanjutan dari project SPK berbasis SAW yang telah dibuat sebelumnya, kemudian disesuaikan dengan kebutuhan sistem seleksi penerima beasiswa.

## 🎯 Tujuan Proyek

- Mengembangkan sistem seleksi penerima beasiswa berbasis web.
- Mengimplementasikan metode Simple Additive Weighting (SAW).
- Membantu proses pengelolaan data calon penerima beasiswa.
- Mempermudah proses penilaian berdasarkan kriteria dan bobot.
- Menghasilkan perangkingan berdasarkan hasil perhitungan SAW.
- Mendukung proses pengambilan keputusan secara lebih terstruktur.

## ⚙️ Metode yang Digunakan

**Simple Additive Weighting (SAW)**

Metode SAW merupakan metode pengambilan keputusan yang menggunakan proses penjumlahan terbobot dari nilai kinerja setiap alternatif pada seluruh kriteria.

Tahapan perhitungan:

1. Menentukan alternatif dan kriteria.
2. Menentukan bobot setiap kriteria.
3. Membentuk matriks keputusan.
4. Melakukan normalisasi matriks.
5. Menghitung nilai preferensi.
6. Mengurutkan hasil perangkingan.

Rumus normalisasi:

- Benefit: `Rij = Xij / Max(Xj)`
- Cost: `Rij = Min(Xj) / Xij`

Rumus nilai preferensi:

`Vi = Σ (Wj × Rij)`

## 📊 Kriteria Penilaian

Rancangan sistem menggunakan lima kriteria utama:

| Kode | Kriteria | Bobot | Atribut |
|---|---|---:|---|
| C1 | Penghasilan orang tua/keluarga | 30% | Cost |
| C2 | Jumlah tanggungan keluarga | 20% | Benefit |
| C3 | Nilai akademik | 25% | Benefit |
| C4 | Prestasi akademik/nonakademik | 15% | Benefit |
| C5 | Keaktifan organisasi/kegiatan sosial | 10% | Benefit |
| | Total | 100% | |

## ✨ Ruang Lingkup Pengembangan

Sistem direncanakan memiliki dua jenis pengguna:

**1. Admin**
- Mengelola data peserta.
- Mengelola periode seleksi dan kuota.
- Mengelola kriteria dan bobot.
- Melakukan verifikasi dokumen.
- Mengelola penilaian peserta.
- Melakukan perhitungan SAW.
- Melihat hasil perangkingan.
- Mengelola pengumuman dan laporan.

**2. Pendaftar**
- Melihat informasi beasiswa.
- Melihat persyaratan pendaftaran.
- Melakukan pendaftaran.
- Mengunggah dokumen persyaratan.
- Mendapatkan nomor pendaftaran.
- Memeriksa status seleksi.

*Catatan: Ruang lingkup di atas merupakan target pengembangan sistem. Ketersediaan setiap fitur mengikuti tahapan implementasi.*

## 🛠️ Teknologi yang Digunakan

| Teknologi | Fungsi |
|---|---|
| PHP | Backend aplikasi |
| MySQL / MariaDB | Database |
| HTML5 | Struktur halaman web |
| CSS3 | Desain dan tampilan |
| JavaScript | Interaksi halaman |
| Laragon | Lingkungan server lokal |
| Git | Version control |
| GitHub | Penyimpanan dan dokumentasi proyek |

## 📂 Struktur Repository

```text
spk-beasiswa-saw/
│
├── admin/
│
├── assets/
│   └── conn/
│
├── docs/
│
├── index.php
│
├── metode_saw.sql
│
├── README.md
│
└── README-PROJECT.md
```

*Struktur di atas merupakan gambaran repository dan dokumentasi proyek. Detail struktur dapat berkembang selama proses pengembangan.*

## 🚀 Instalasi Aplikasi

### Persyaratan

- Windows
- Laragon atau XAMPP
- PHP
- MySQL / MariaDB
- Web Browser

### Langkah Instalasi

1. Clone repository:

```bash
git clone https://github.com/muftiabunaseh0924/spk-beasiswa-saw.git
```

2. Pindahkan folder proyek ke direktori web server, misalnya `www` pada Laragon atau `htdocs` pada XAMPP.

3. Jalankan Apache dan MySQL.

4. Buka phpMyAdmin.

5. Buat database dengan nama `metode_saw`.

6. Import file `metode_saw.sql`.

7. Sesuaikan konfigurasi koneksi database pada source code.

8. Jalankan aplikasi melalui browser.

### Petunjuk Instalasi Versi Awal

Dokumentasi instalasi pada proyek awal:

1. Place the folder in `htdocs` (XAMPP).
2. Make a new database named `metode_saw` in phpMyAdmin.
3. Import `metode_saw.sql` via phpMyAdmin.
4. Open `http://localhost/penerapan-metode-saw`.

*Alamat lokal versi awal tersebut perlu disesuaikan dengan nama folder proyek ketika dijalankan.*

## 📖 Dokumentasi Proyek

Dokumentasi lengkap mengenai perencanaan dan pengembangan sistem dapat dilihat pada:

📄 [README-PROJECT.md](README-PROJECT.md)

Dokumentasi tersebut mencakup:

- Informasi dan tujuan proyek.
- Ruang lingkup sistem.
- Kriteria dan bobot SAW.
- Rumus perhitungan SAW.
- Rencana pengembangan SDLC Waterfall.
- Tahapan implementasi.
- Standar pengujian.
- Dokumentasi Git dan GitHub.

## 👨‍💻 Kredit dan Atribusi

Proyek ini dikembangkan berdasarkan project SPK metode SAW yang dibuat oleh:

**Original Project Creator: Bagasksm**

Terima kasih kepada Bagasksm atas source code dan kontribusi awal yang menjadi dasar pengembangan proyek ini.

**Further Development: Mufti Abu Naseh**

Proyek kemudian dikembangkan dan disesuaikan lebih lanjut untuk kebutuhan penelitian dengan judul:

*Implementasi Sistem Pendukung Keputusan (SPK) Seleksi Penerima Beasiswa Menggunakan Metode SAW Berbasis Web dengan Pendekatan SDLC Waterfall.*

## 📌 Status Pengembangan

Pengembangan sistem dilakukan secara bertahap menggunakan pendekatan SDLC Waterfall.

Dokumentasi tahapan dan perkembangan proyek akan diperbarui secara berkala melalui repository GitHub ini.

---

<p align="center">
  <b>SPK Seleksi Penerima Beasiswa</b>
  <br>
  Developed with by Mufti Abu Naseh
  <br>
  Based on the original project by Bagasksm.
</p>
