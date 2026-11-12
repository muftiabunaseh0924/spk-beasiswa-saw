# README TAHAP 1 - ANALISIS KEBUTUHAN SISTEM

**Proyek:** SPK Seleksi Penerima Beasiswa Metode SAW Berbasis Web (SDLC Waterfall)
**Tahap:** 1 dari 9
**Jenis pekerjaan:** Dokumentasi (tidak ada perubahan kode maupun database)

---

## 1. Tujuan Tahap

Menentukan kebutuhan dan fungsi aplikasi seleksi beasiswa secara tertulis, sehingga perancangan (Tahap 2) dan implementasi (Tahap 3-7) memiliki acuan yang jelas dan dapat diperiksa.

## 2. Ruang Lingkup

1. Menentukan kebutuhan pengguna.
2. Menentukan kebutuhan fungsional.
3. Menentukan kebutuhan nonfungsional.
4. Menentukan alur pendaftaran.
5. Menentukan alur verifikasi.
6. Menentukan alur penilaian.
7. Menentukan alur seleksi dan pengumuman.

Di luar ruang lingkup tahap ini: diagram (Use Case, Activity, ERD), struktur database, dan kode. Semuanya dikerjakan di tahap berikutnya.

## 3. Persiapan

- Hasil Tahap 0 (audit) dan README-PROJECT.md sebagai sumber kebutuhan.
- Konfirmasi pengembang atas enam asumsi (A1-A6) pada bagian 5.

## 4. Langkah Pengerjaan

1. Mengidentifikasi pengguna dan hak aksesnya dari README-PROJECT bagian 4.1.
2. Menurunkan kebutuhan fungsional dari tujuan proyek, ruang lingkup, dan tujuh tahap pengembangan.
3. Menurunkan kebutuhan nonfungsional dari temuan audit Tahap 0 (keamanan, akurasi, keandalan) dan ketentuan pengembangan.
4. Menyusun lima alur proses.
5. Mencatat asumsi dan meminta konfirmasi pengembang.
6. Memeriksa kelengkapan dan kesesuaian kebutuhan terhadap tujuan penelitian (bagian 9).

## 5. Asumsi dan Aturan Bisnis yang Disepakati

Keenam asumsi berikut telah dikonfirmasi pengembang dan menjadi ketentuan resmi.

| ID | Ketentuan |
|---|---|
| A1 | Satu pendaftar hanya boleh mendaftar sekali per periode; dicegah melalui nomor identitas (NISN untuk pelajar, NIM untuk mahasiswa) |
| A2 | Dokumen wajib: Kartu Keluarga, surat/slip penghasilan, rapor atau transkrip. Bukti prestasi dan bukti organisasi bersifat opsional. Format PDF/JPG/PNG, maksimal 2 MB per file |
| A3 | Hanya ada satu level admin, tanpa peran lain |
| A4 | Nilai C1-C3 diisi pendaftar lalu diperiksa dan dapat dikoreksi admin; nilai C4 dan C5 sepenuhnya diberikan admin |
| A5 | Hasil dapat dihitung ulang sebelum diumumkan, tetapi terkunci setelah diumumkan |
| A6 | Kuota satu per periode dan semua jenjang bersaing dalam satu peringkat |

Aturan bisnis tambahan dari README-PROJECT:

| ID | Aturan |
|---|---|
| B1 | Pendaftar tidak memerlukan akun login |
| B2 | Hanya peserta berstatus Terverifikasi dengan nilai C1-C5 lengkap yang diikutkan dalam perhitungan SAW |
| B3 | Peserta berstatus Ditolak tidak diikutkan dalam perhitungan |
| B4 | Halaman publik hanya menampilkan status Lolos atau Tidak Lolos (tanpa nilai dan peringkat) |
| B5 | Hasil tidak dipublikasikan sebelum disetujui admin |
| B6 | Data simulasi harus dapat dibedakan dari data nyata |
| B7 | Total bobot kriteria harus tepat 100% |
| B8 | Nilai prestasi (C4) dan keaktifan (C5) diberikan admin berdasarkan bukti yang sudah diverifikasi |

## 6. Kebutuhan Pengguna

| Pengguna | Akun | Kebutuhan utama |
|---|---|---|
| Pendaftar (pelajar SMA/SMK, mahasiswa D3/S1) | Tanpa akun | Melihat informasi dan persyaratan, mendaftar, mengunggah dokumen, memperoleh nomor pendaftaran, memeriksa status seleksi |
| Admin (satu level) | Login | Mengelola periode, kuota, peserta, kriteria; memverifikasi dokumen; menilai; menjalankan SAW; mengumumkan hasil; membuat laporan |

## 7. Kebutuhan Fungsional

### 7.1 Halaman Publik

| ID | Kebutuhan | Keterangan |
|---|---|---|
| FP-01 | Beranda dan informasi beasiswa | Menampilkan periode aktif dan jadwal |
| FP-02 | Halaman persyaratan | Daftar dokumen wajib/opsional dan kriteria penilaian |
| FP-03 | Formulir pendaftaran | Data diri, nomor identitas (NISN/NIM), jenjang, asal sekolah/kampus, penghasilan keluarga, jumlah tanggungan, nilai rapor atau IPK, keterangan prestasi dan keaktifan |
| FP-04 | Validasi input | Kolom wajib, tipe data, rentang nilai, duplikasi nomor identitas (A1) |
| FP-05 | Unggah dokumen persyaratan | PDF/JPG/PNG, maksimal 2 MB (A2) |
| FP-06 | Nomor pendaftaran otomatis | Unik, format tetap (contoh `BSW-2026-001`) |
| FP-07 | Pembatasan masa pendaftaran | Pendaftaran hanya dapat dilakukan saat periode berstatus terbuka |
| FP-08 | Cek status seleksi | Dengan nomor pendaftaran: Menunggu / Terverifikasi / Ditolak; Lolos / Tidak Lolos hanya setelah hasil diumumkan |

### 7.2 Halaman Admin

| ID | Kebutuhan | Keterangan |
|---|---|---|
| FA-01 | Login dan logout | Sesi aman; semua halaman admin terlindungi |
| FA-02 | Dashboard | Ringkasan jumlah pendaftar, status verifikasi, periode aktif |
| FA-03 | Kelola periode dan kuota | Buat, ubah, buka/tutup periode; atur kuota |
| FA-04 | Kelola peserta | Lihat, cari, filter, ubah, hapus dengan konfirmasi |
| FA-05 | Verifikasi dokumen | Setujui atau tolak, dengan catatan |
| FA-06 | Kelola kriteria dan bobot | Validasi total bobot 100% (B7) |
| FA-07 | Penilaian peserta | Periksa dan koreksi C1-C3; beri nilai C4 dan C5 (skala 1-5) |
| FA-08 | Hitung SAW | Hanya peserta yang memenuhi B2 |
| FA-09 | Tampilkan proses perhitungan | Matriks keputusan, normalisasi, nilai preferensi, peringkat |
| FA-10 | Penentuan status berdasarkan kuota | Lolos/Tidak Lolos; penanganan nilai seri (aturan ditetapkan di Tahap 2) |
| FA-11 | Persetujuan dan pengumuman hasil | Hasil terkunci setelah diumumkan (A5, B5) |
| FA-12 | Laporan hasil seleksi | Cetak atau ekspor |

### 7.3 Kebutuhan Sistem (Lintas Fitur)

| ID | Kebutuhan |
|---|---|
| FS-01 | Nomor pendaftaran dibuat otomatis dan tidak dapat duplikat |
| FS-02 | Penanda data simulasi agar dapat dibedakan dari data nyata (B6) |
| FS-03 | Perhitungan SAW sesuai rumus README-PROJECT bagian 6 dengan bobot C1=0,30; C2=0,20; C3=0,25; C4=0,15; C5=0,10 |
| FS-04 | Konversi nilai akademik D3/S1: IPK skala 4 dikali 25 menjadi skala 0-100 (diubah dari 20 pada Tahap 2) |
| FS-05 | File unggahan tersimpan aman dan hanya dapat diakses admin |

## 8. Kebutuhan Nonfungsional

| Aspek | Kebutuhan |
|---|---|
| Keamanan | Password di-hash; query terparameter (anti SQL injection); proteksi halaman admin; validasi tipe, ekstensi, dan ukuran unggahan; token CSRF; penanganan error tanpa membocorkan detail sistem |
| Privasi | Publik hanya melihat status (B4); data pribadi pendaftar tidak ditampilkan di halaman publik; data nyata tidak masuk repository |
| Akurasi | Hasil SAW dihitung tanpa pembulatan sebelum hasil akhir dan dapat dibandingkan dengan perhitungan manual |
| Keandalan | Penyimpanan hasil memakai transaksi database; backup sebelum perubahan besar |
| Kegunaan | Antarmuka Bahasa Indonesia, responsif untuk ponsel dan komputer |
| Kinerja | Halaman utama dan perhitungan 30 peserta selesai di bawah 3 detik pada Laragon |
| Portabilitas | Berjalan di Windows dengan Laragon (PHP, MySQL/MariaDB) |
| Pemeliharaan | Logika SAW dipisah dari tampilan; dokumentasi dan pengujian tersedia di setiap tahap |
| Dapat diuji | Setiap fitur memiliki skenario uji; perhitungan SAW dapat diverifikasi secara manual |

Beberapa kebutuhan keamanan di atas bersumber langsung dari temuan audit Tahap 0 (#1 sampai #4 dan #6 sampai #8).

## 9. Alur Proses

### 9.1 Alur Pendaftaran
1. Pendaftar membuka halaman publik dan membaca informasi serta persyaratan.
2. Sistem memeriksa apakah periode berstatus terbuka. Jika tertutup, pendaftaran ditolak dengan pesan.
3. Pendaftar mengisi formulir dan mengunggah dokumen.
4. Sistem memvalidasi input, termasuk memeriksa nomor identitas yang sudah terdaftar pada periode yang sama (A1).
5. Jika valid, sistem menyimpan data, membuat nomor pendaftaran unik, dan menetapkan status **Menunggu**.
6. Sistem menampilkan nomor pendaftaran kepada pendaftar.

### 9.2 Alur Verifikasi
1. Admin login dan membuka daftar peserta berstatus Menunggu.
2. Admin memeriksa kelengkapan dan keabsahan dokumen wajib (A2).
3. Admin menetapkan **Terverifikasi** atau **Ditolak** (dengan catatan).
4. Status baru tersimpan; pendaftar dapat melihatnya melalui cek status.

### 9.3 Alur Penilaian
1. Admin membuka peserta Terverifikasi.
2. Admin memeriksa C1-C3 yang diisi pendaftar terhadap dokumen, dan mengoreksi jika berbeda (A4).
3. Admin memberi nilai C4 (prestasi, skala 1-5) dan C5 (keaktifan, skala 1-5) berdasarkan bukti.
4. Sistem memvalidasi rentang nilai dan menyimpan. Peserta dengan nilai belum lengkap tidak diikutkan perhitungan (B2).

### 9.4 Alur Seleksi
1. Admin memilih periode dan menjalankan perhitungan SAW.
2. Sistem mengambil peserta yang memenuhi B2 beserta nilai C1-C5.
3. Sistem membentuk matriks keputusan, melakukan normalisasi (Benefit dan Cost), dan menghitung nilai preferensi.
4. Sistem mengurutkan hasil dari nilai tertinggi dan menentukan Lolos/Tidak Lolos berdasarkan kuota periode (A6).
5. Sistem memperingatkan jika terdapat nilai seri pada batas kuota.
6. Admin meninjau hasil dan dapat menghitung ulang selama belum diumumkan (A5).

### 9.5 Alur Pengumuman
1. Admin menyetujui hasil perangkingan untuk diumumkan.
2. Sistem mengunci hasil periode tersebut (A5) dan menandainya sebagai sudah diumumkan.
3. Pendaftar memasukkan nomor pendaftaran pada halaman cek status.
4. Sistem menampilkan status Lolos atau Tidak Lolos (B4). Sebelum diumumkan, sistem hanya menampilkan status verifikasi (B5).
5. Admin dapat mencetak laporan hasil seleksi.

## 10. Daftar Fitur Sistem

| Modul | Fitur | ID | Tahap implementasi |
|---|---|---|---|
| Publik | Beranda, informasi beasiswa, persyaratan | FP-01, FP-02 | 4 |
| Publik | Pendaftaran, validasi, unggah dokumen, nomor otomatis | FP-03 sampai FP-07 | 4 |
| Publik | Cek status seleksi | FP-08 | 4 dan 7 |
| Admin | Login, dashboard | FA-01, FA-02 | 5 |
| Admin | Periode dan kuota, peserta, kriteria | FA-03, FA-04, FA-06 | 5 |
| Admin | Verifikasi dokumen dan penilaian | FA-05, FA-07 | 5 |
| SAW | Perhitungan dan tampilan proses | FA-08, FA-09, FS-03, FS-04 | 6 |
| Hasil | Penentuan status, pengumuman, laporan | FA-10 sampai FA-12 | 6 dan 7 |
| Lintas | Penanda data simulasi, keamanan unggahan | FS-01, FS-02, FS-05 | 3 sampai 8 |

## 11. File yang Dibuat atau Diubah

| File | Aksi |
|---|---|
| `docs/README-Tahap-01-Analisis.md` | Dibuat (dokumen ini, sekaligus dokumen analisis kebutuhan dan daftar fitur) |
| `README-PROJECT.md` | Status Tahap 1 diubah menjadi Selesai |
| Kode aplikasi dan database | Tidak diubah |
| `admin/metode.php` (lokal) | Tidak diubah dan tidak di-commit |

## 12. Prosedur dan Hasil Pengujian

Pengujian pada tahap ini berupa pemeriksaan dokumen, sesuai ketentuan README-PROJECT.

### 12.1 Kelengkapan Kebutuhan

| Aktivitas README Tahap 1 | Dicakup di | Hasil |
|---|---|---|
| 1. Kebutuhan pengguna | Bagian 6 | Lengkap |
| 2. Kebutuhan fungsional | Bagian 7 | Lengkap (8 publik, 12 admin, 5 sistem) |
| 3. Kebutuhan nonfungsional | Bagian 8 | Lengkap |
| 4. Alur pendaftaran | Bagian 9.1 | Lengkap |
| 5. Alur verifikasi | Bagian 9.2 | Lengkap |
| 6. Alur penilaian | Bagian 9.3 | Lengkap |
| 7. Alur seleksi dan pengumuman | Bagian 9.4 dan 9.5 | Lengkap |

### 12.2 Kesesuaian dengan Tujuan Penelitian

| Tujuan README-PROJECT | Dipenuhi oleh | Hasil |
|---|---|---|
| 1. Aplikasi SPK seleksi beasiswa berbasis web | FP-01 sampai FP-08, FA-01 sampai FA-12 | Sesuai |
| 2. Implementasi metode SAW | FA-06 sampai FA-10, FS-03 | Sesuai |
| 3. Pengelolaan pendaftar dan dokumen | FP-03, FP-05, FA-04 | Sesuai |
| 4. Admin memverifikasi dan menilai | FA-05, FA-07 | Sesuai |
| 5. Keputusan berdasarkan bobot dan kuota | FA-08, FA-10 | Sesuai |
| 6. Transparansi melalui nomor pendaftaran | FP-06, FP-08, FA-11 | Sesuai |

### 12.3 Konsistensi dengan Ketentuan Pengembangan (README-PROJECT bagian 12)

| Ketentuan | Dipenuhi oleh | Hasil |
|---|---|---|
| 3. Jenjang SMA, SMK, D3, S1 | FP-03 | Sesuai |
| 4. Pendaftaran lewat halaman publik | FP-03 | Sesuai |
| 5. Admin memverifikasi dan menilai | FA-05, FA-07 | Sesuai |
| 6. Kuota per periode | FA-03, A6 | Sesuai |
| 7. Publik hanya melihat Lolos/Tidak Lolos | B4, FP-08 | Sesuai |
| 8. Hasil tidak publik sebelum disetujui | B5, FA-11 | Sesuai |
| 9. Data simulasi dibedakan dari data nyata | B6, FS-02 | Sesuai |

Ketentuan 1, 2, 10, 11, dan 12 mengatur metode dan proses kerja, bukan fitur aplikasi, sehingga tidak dipetakan ke kebutuhan.

### 12.4 Konfirmasi Pengembang

Asumsi A1-A6 dikonfirmasi pengembang dan diterima sebagai ketentuan resmi (bagian 5).

## 13. Kendala dan Solusi

| Kendala | Solusi |
|---|---|
| README-PROJECT belum menetapkan kebijakan dokumen, nomor identitas, peran admin, dan kuota per jenjang | Diusulkan sebagai asumsi A1-A6, lalu dikonfirmasi pengembang |
| Aturan penghasilan nol dan nilai seri belum ditetapkan | Sesuai README-PROJECT, ditetapkan di Tahap 2 sebelum kode perhitungan dibuat (lihat bagian 14) |

## 14. Keputusan yang Ditunda ke Tahap 2

| Topik | Pertanyaan yang harus diputuskan |
|---|---|
| Penghasilan nol (C1, Cost) | Bagaimana `r_ij = min/x` dihitung jika x = 0, dan nilai min yang dipakai jika ada penghasilan nol |
| Nilai seri pada batas kuota | Aturan penentuan urutan (tie-break) dan apakah perlu keputusan manual admin |
| Konversi nilai akademik | Penanganan IPK pada skala selain 4 dan batas rentang valid |
| Tabel database | Memakai ulang atau merancang ulang tabel beasiswa yang sudah ada (temuan Tahap 0) |
| Status periode | Nilai dan perpindahan status: Draf, Terbuka, Tertutup, Diumumkan |
| Format nomor pendaftaran | Pola dan cara menghindari duplikat saat pendaftaran bersamaan |
| Penyimpanan dokumen | Lokasi file di luar folder publik dan konvensi penamaan |
| Penanda data simulasi | Cara menandai data simulasi di database |

## 15. Status Penyelesaian

| Kegiatan | Status |
|---|---|
| Kebutuhan pengguna, fungsional, nonfungsional | Selesai |
| Lima alur proses | Selesai |
| Daftar fitur | Selesai |
| Pemeriksaan kelengkapan dan kesesuaian | Selesai, semua sesuai |
| Konfirmasi asumsi oleh pengembang | Selesai |
| README Tahap 1 | Selesai |
| Commit dan push ke GitHub | Dikerjakan pengembang (bagian 16) |
| Verifikasi di GitHub | Setelah push |

**Tahap 1 dinyatakan selesai setelah push berhasil dan file terlihat di GitHub.**

## 16. Informasi Commit Git

```powershell
git add README-PROJECT.md docs/README-Tahap-01-Analisis.md
git commit -m "Tahap 1: analisis kebutuhan sistem"
git push
```

| Item | Nilai |
|---|---|
| Pesan commit | `Tahap 1: analisis kebutuhan sistem` |
| Repository | `muftiabunaseh0924/spk-beasiswa-saw` (Private) |
| Branch | `main` |
| Hash commit | Lihat dengan `git log --oneline -1` |
