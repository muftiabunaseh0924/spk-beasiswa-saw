<#
  database/uji_database.ps1
  Pengujian database Tahap 3 (koneksi, struktur, data, CRUD, relasi, integritas, bobot).

  Penggunaan (dari folder proyek):
    .\database\uji_database.ps1 -Database metode_saw_uji

  Semua pengujian yang mengubah data dibungkus transaksi dan di-ROLLBACK,
  sehingga isi database tidak berubah setelah pengujian.
  Jenis uji: ok = harus berhasil, nilai = hasil harus sama dengan harapan,
             gagal = harus ditolak MySQL dengan kode galat tertentu.
#>
param(
    [string]$Database = "metode_saw_uji",
    [string]$User = "root"
)

$prefix = "SET SESSION sql_mode='STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION'; "

function Invoke-Mysql([string]$Sql) {
    $raw = ($prefix + $Sql) | & mysql -u $User -N -B $Database 2>&1
    $code = $LASTEXITCODE
    $txt = (($raw | ForEach-Object { "$_" }) -join "`n").Trim()
    [pscustomobject]@{ Code = $code; Text = $txt }
}

$tests = @(
    @{ K='ok'; N='Koneksi database'; Q='SELECT 1'; E='' },
    @{ K='nilai'; N='Jumlah tabel sistem = 9'; Q='SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN (''admin'',''periode'',''kriteria'',''periode_kriteria'',''peserta'',''dokumen'',''penilaian'',''hasil_seleksi'',''log_aktivitas'')'; E='9' },
    @{ K='nilai'; N='Semua tabel sistem bermesin InnoDB'; Q='SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN (''admin'',''periode'',''kriteria'',''periode_kriteria'',''peserta'',''dokumen'',''penilaian'',''hasil_seleksi'',''log_aktivitas'') AND engine = ''InnoDB'''; E='9' },
    @{ K='nilai'; N='Jumlah foreign key = 11'; Q='SELECT COUNT(*) FROM information_schema.referential_constraints WHERE constraint_schema = DATABASE() AND table_name IN (''admin'',''periode'',''kriteria'',''periode_kriteria'',''peserta'',''dokumen'',''penilaian'',''hasil_seleksi'',''log_aktivitas'')'; E='11' },
    @{ K='nilai'; N='Jumlah batasan CHECK = 14'; Q='SELECT COUNT(*) FROM information_schema.table_constraints WHERE table_schema = DATABASE() AND constraint_type = ''CHECK'' AND table_name IN (''admin'',''periode'',''kriteria'',''periode_kriteria'',''peserta'',''dokumen'',''penilaian'',''hasil_seleksi'',''log_aktivitas'')'; E='14' },
    @{ K='nilai'; N='Jumlah kriteria = 5'; Q='SELECT COUNT(*) FROM kriteria'; E='5' },
    @{ K='nilai'; N='C1 Cost, C2-C5 Benefit'; Q='SELECT COUNT(*) FROM kriteria WHERE (kode = ''C1'' AND atribut = ''Cost'') OR (kode <> ''C1'' AND atribut = ''Benefit'')'; E='5' },
    @{ K='nilai'; N='Total bobot kriteria = 1'; Q='SELECT CASE WHEN ROUND(SUM(bobot),4) = 1 THEN ''ya'' ELSE ''tidak'' END FROM kriteria'; E='ya' },
    @{ K='nilai'; N='Jumlah periode = 2'; Q='SELECT COUNT(*) FROM periode'; E='2' },
    @{ K='nilai'; N='Total bobot tiap periode = 1'; Q='SELECT COUNT(*) FROM (SELECT id_periode FROM periode_kriteria GROUP BY id_periode HAVING ROUND(SUM(bobot),4) <> 1) x'; E='0' },
    @{ K='nilai'; N='Tiap periode punya 5 kriteria'; Q='SELECT COUNT(*) FROM (SELECT id_periode FROM periode_kriteria GROUP BY id_periode HAVING COUNT(*) <> 5) x'; E='0' },
    @{ K='nilai'; N='Tepat satu periode berstatus Terbuka'; Q='SELECT COUNT(*) FROM periode WHERE status = ''Terbuka'''; E='1' },
    @{ K='nilai'; N='Peserta periode 1 = 30'; Q='SELECT COUNT(*) FROM peserta WHERE id_periode = 1'; E='30' },
    @{ K='nilai'; N='Komposisi jenjang SMA/SMK/D3/S1 = 10/10/5/5'; Q='SELECT SUM(jenjang = ''SMA''), SUM(jenjang = ''SMK''), SUM(jenjang = ''D3''), SUM(jenjang = ''S1'') FROM peserta WHERE id_periode = 1'; E='10|10|5|5' },
    @{ K='nilai'; N='Status Terverifikasi/Menunggu/Ditolak = 27/1/2'; Q='SELECT SUM(status_verifikasi = ''Terverifikasi''), SUM(status_verifikasi = ''Menunggu''), SUM(status_verifikasi = ''Ditolak'') FROM peserta WHERE id_periode = 1'; E='27|1|2' },
    @{ K='nilai'; N='Peserta layak hitung SAW = 25'; Q='SELECT COUNT(*) FROM peserta p JOIN penilaian n ON n.id_peserta = p.id_peserta WHERE p.id_periode = 1 AND p.status_verifikasi = ''Terverifikasi'' AND n.c1 IS NOT NULL AND n.c2 IS NOT NULL AND n.c3 IS NOT NULL AND n.c4 IS NOT NULL AND n.c5 IS NOT NULL'; E='25' },
    @{ K='nilai'; N='Peserta belum dinilai (C4/C5 kosong) = 2'; Q='SELECT COUNT(*) FROM penilaian WHERE c4 IS NULL OR c5 IS NULL'; E='2' },
    @{ K='nilai'; N='Peserta layak berpenghasilan 0 = 3'; Q='SELECT COUNT(*) FROM penilaian WHERE c1 = 0 AND c4 IS NOT NULL AND c5 IS NOT NULL'; E='3' },
    @{ K='nilai'; N='Aturan R3: Terverifikasi punya 3 dokumen wajib Valid (pelanggaran = 0)'; Q='SELECT COUNT(*) FROM peserta p WHERE p.status_verifikasi = ''Terverifikasi'' AND (SELECT COUNT(*) FROM dokumen d WHERE d.id_peserta = p.id_peserta AND d.status = ''Valid'' AND d.jenis IN (''KK'',''Penghasilan'',''Akademik'')) < 3'; E='0' },
    @{ K='nilai'; N='Aturan R4: Terverifikasi punya baris penilaian (pelanggaran = 0)'; Q='SELECT COUNT(*) FROM peserta p WHERE p.status_verifikasi = ''Terverifikasi'' AND NOT EXISTS (SELECT 1 FROM penilaian n WHERE n.id_peserta = p.id_peserta)'; E='0' },
    @{ K='nilai'; N='Menunggu/Ditolak tidak punya penilaian (pelanggaran = 0)'; Q='SELECT COUNT(*) FROM peserta p JOIN penilaian n ON n.id_peserta = p.id_peserta WHERE p.status_verifikasi <> ''Terverifikasi'''; E='0' },
    @{ K='nilai'; N='Nilai C3 sesuai konversi, IPK x 25 (pelanggaran = 0)'; Q='SELECT COUNT(*) FROM peserta p JOIN penilaian n ON n.id_peserta = p.id_peserta WHERE (p.skala_nilai = ''IPK4'' AND ABS(n.c3 - p.nilai_akademik_input * 25) > 0.001) OR (p.skala_nilai = ''Rapor100'' AND ABS(n.c3 - p.nilai_akademik_input) > 0.001)'; E='0' },
    @{ K='nilai'; N='Nomor pendaftaran berformat BSW-2026-NNN dan counter = 30'; Q='SELECT (SELECT COUNT(*) FROM peserta WHERE id_periode = 1 AND no_pendaftaran LIKE ''BSW-2026-%''), (SELECT counter_nomor FROM periode WHERE id_periode = 1)'; E='30|30' },
    @{ K='nilai'; N='Semua peserta dan periode bertanda simulasi (pelanggaran = 0)'; Q='SELECT (SELECT COUNT(*) FROM peserta WHERE is_simulasi <> 1) + (SELECT COUNT(*) FROM periode WHERE is_simulasi <> 1)'; E='0' },
    @{ K='nilai'; N='Jumlah dokumen simulasi = 134'; Q='SELECT COUNT(*) FROM dokumen'; E='134' },
    @{ K='nilai'; N='Tabel hasil_seleksi masih kosong'; Q='SELECT COUNT(*) FROM hasil_seleksi'; E='0' },
    @{ K='nilai'; N='Tidak ada data yatim (peserta, dokumen, penilaian)'; Q='SELECT (SELECT COUNT(*) FROM peserta p LEFT JOIN periode d ON d.id_periode = p.id_periode WHERE d.id_periode IS NULL) + (SELECT COUNT(*) FROM dokumen o LEFT JOIN peserta p ON p.id_peserta = o.id_peserta WHERE p.id_peserta IS NULL) + (SELECT COUNT(*) FROM penilaian n LEFT JOIN peserta p ON p.id_peserta = n.id_peserta WHERE p.id_peserta IS NULL)'; E='0' },
    @{ K='nilai'; N='TAMBAH: peserta baru tersimpan'; Q='START TRANSACTION; INSERT INTO peserta (id_periode,no_pendaftaran,nomor_identitas,nama,jenjang,asal_institusi,no_hp,penghasilan_input,tanggungan_input,skala_nilai,nilai_akademik_input) VALUES (1,''BSW-2026-901'',''UJI0000001'',''Peserta Uji'',''SMA'',''SMA Uji'',''081200000000'',1000000,2,''Rapor100'',80.00); SELECT COUNT(*) FROM peserta WHERE id_periode = 1; ROLLBACK;'; E='31' },
    @{ K='nilai'; N='UBAH: nama peserta berubah'; Q='START TRANSACTION; UPDATE peserta SET nama = ''Uji Ubah'' WHERE id_peserta = 1; SELECT nama FROM peserta WHERE id_peserta = 1; ROLLBACK;'; E='Uji Ubah' },
    @{ K='nilai'; N='HAPUS: peserta terhapus beserta dokumennya (CASCADE)'; Q='START TRANSACTION; DELETE FROM peserta WHERE id_peserta = 30; SELECT COUNT(*) FROM peserta WHERE id_peserta = 30; SELECT COUNT(*) FROM dokumen WHERE id_peserta = 30; ROLLBACK;'; E='0;0' },
    @{ K='nilai'; N='HAPUS: periode terhapus beserta bobotnya (CASCADE)'; Q='START TRANSACTION; DELETE FROM periode WHERE id_periode = 2; SELECT COUNT(*) FROM periode_kriteria WHERE id_periode = 2; ROLLBACK;'; E='0' },
    @{ K='nilai'; N='TAMBAH: hasil_seleksi tersimpan'; Q='START TRANSACTION; INSERT INTO hasil_seleksi (id_periode,id_peserta,nilai_preferensi,peringkat,status) VALUES (1,1,0.5,1,''Lolos''); SELECT COUNT(*) FROM hasil_seleksi; ROLLBACK;'; E='1' },
    @{ K='nilai'; N='TAMBAH: admin tersimpan'; Q='START TRANSACTION; INSERT INTO admin (username,password_hash,nama_lengkap) VALUES (''uji'',''x'',''Admin Uji''); SELECT COUNT(*) FROM admin; ROLLBACK;'; E='1' },
    @{ K='nilai'; N='Pindah periode Terbuka (tutup periode 2, buka periode 1)'; Q='START TRANSACTION; UPDATE periode SET status = ''Tertutup'' WHERE id_periode = 2; UPDATE periode SET status = ''Terbuka'' WHERE id_periode = 1; SELECT COUNT(*) FROM periode WHERE status = ''Terbuka''; ROLLBACK;'; E='1' },
    @{ K='gagal'; N='Nomor identitas sama pada periode sama ditolak (A1)'; Q='START TRANSACTION; INSERT INTO peserta (id_periode,no_pendaftaran,nomor_identitas,nama,jenjang,asal_institusi,no_hp,penghasilan_input,tanggungan_input,skala_nilai,nilai_akademik_input) VALUES (1,''BSW-2026-902'',''9900000001'',''Peserta Uji'',''SMA'',''SMA Uji'',''081200000000'',1000000,2,''Rapor100'',80.00); ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Nomor pendaftaran duplikat ditolak (FS-01)'; Q='START TRANSACTION; INSERT INTO peserta (id_periode,no_pendaftaran,nomor_identitas,nama,jenjang,asal_institusi,no_hp,penghasilan_input,tanggungan_input,skala_nilai,nilai_akademik_input) VALUES (1,''BSW-2026-001'',''UJI0000002'',''Peserta Uji'',''SMA'',''SMA Uji'',''081200000000'',1000000,2,''Rapor100'',80.00); ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Peserta dengan periode tidak ada ditolak'; Q='START TRANSACTION; INSERT INTO peserta (id_periode,no_pendaftaran,nomor_identitas,nama,jenjang,asal_institusi,no_hp,penghasilan_input,tanggungan_input,skala_nilai,nilai_akademik_input) VALUES (99,''BSW-2026-903'',''UJI0000003'',''Peserta Uji'',''SMA'',''SMA Uji'',''081200000000'',1000000,2,''Rapor100'',80.00); ROLLBACK;'; E='ERROR 1452' },
    @{ K='gagal'; N='Jenjang di luar daftar ditolak'; Q='START TRANSACTION; UPDATE peserta SET jenjang = ''SMP'' WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 1265' },
    @{ K='gagal'; N='Skala nilai tidak sesuai jenjang ditolak (R6)'; Q='START TRANSACTION; UPDATE peserta SET skala_nilai = CASE WHEN skala_nilai = ''IPK4'' THEN ''Rapor100'' ELSE ''IPK4'' END WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Nilai akademik di luar rentang ditolak'; Q='START TRANSACTION; UPDATE peserta SET nilai_akademik_input = 101 WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Penghasilan negatif ditolak'; Q='START TRANSACTION; UPDATE peserta SET penghasilan_input = -1 WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Nilai C4 di luar 1-5 ditolak'; Q='START TRANSACTION; UPDATE penilaian SET c4 = 6 WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Nilai C3 di atas 100 ditolak'; Q='START TRANSACTION; UPDATE penilaian SET c3 = 101 WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Nilai C1 negatif ditolak'; Q='START TRANSACTION; UPDATE penilaian SET c1 = -1 WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Dua penilaian untuk satu peserta ditolak'; Q='START TRANSACTION; INSERT INTO penilaian (id_peserta,c1,c2,c3,c4,c5) VALUES (1,0,1,80,3,3); ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Dua dokumen berjenis sama untuk satu peserta ditolak (R7)'; Q='START TRANSACTION; INSERT INTO dokumen (id_peserta,jenis,nama_asli,nama_tersimpan,mime_type,ukuran_byte) VALUES (1,''KK'',''a.pdf'',''UJI-A'',''application/pdf'',1000); ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Dokumen lebih dari 2 MB ditolak'; Q='START TRANSACTION; INSERT INTO dokumen (id_peserta,jenis,nama_asli,nama_tersimpan,mime_type,ukuran_byte) VALUES (30,''Prestasi'',''a.pdf'',''UJI-B'',''application/pdf'',3000000); ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Bobot kriteria di atas 1 ditolak'; Q='START TRANSACTION; UPDATE kriteria SET bobot = 1.5 WHERE kode = ''C1''; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Kuota negatif ditolak'; Q='START TRANSACTION; UPDATE periode SET kuota = -1 WHERE id_periode = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Tanggal tutup sebelum tanggal buka ditolak'; Q='START TRANSACTION; UPDATE periode SET tanggal_tutup = ''2020-01-01'' WHERE id_periode = 1; ROLLBACK;'; E='ERROR 3819' },
    @{ K='gagal'; N='Status periode di luar daftar ditolak'; Q='START TRANSACTION; UPDATE periode SET status = ''Selesai'' WHERE id_periode = 1; ROLLBACK;'; E='ERROR 1265' },
    @{ K='gagal'; N='Dua periode Terbuka sekaligus ditolak (R2)'; Q='START TRANSACTION; UPDATE periode SET status = ''Terbuka'' WHERE id_periode = 1; ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Dua hasil untuk peserta yang sama ditolak'; Q='START TRANSACTION; INSERT INTO hasil_seleksi (id_periode,id_peserta,nilai_preferensi,peringkat,status) VALUES (1,1,0.5,1,''Lolos''); INSERT INTO hasil_seleksi (id_periode,id_peserta,nilai_preferensi,peringkat,status) VALUES (1,1,0.5,2,''Lolos''); ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Dua peserta berperingkat sama ditolak'; Q='START TRANSACTION; INSERT INTO hasil_seleksi (id_periode,id_peserta,nilai_preferensi,peringkat,status) VALUES (1,1,0.5,1,''Lolos''); INSERT INTO hasil_seleksi (id_periode,id_peserta,nilai_preferensi,peringkat,status) VALUES (1,2,0.5,1,''Lolos''); ROLLBACK;'; E='ERROR 1062' },
    @{ K='gagal'; N='Hapus peserta yang sudah punya hasil ditolak (RESTRICT)'; Q='START TRANSACTION; INSERT INTO hasil_seleksi (id_periode,id_peserta,nilai_preferensi,peringkat,status) VALUES (1,1,0.5,1,''Lolos''); DELETE FROM peserta WHERE id_peserta = 1; ROLLBACK;'; E='ERROR 1451' },
    @{ K='gagal'; N='Hapus periode yang masih punya peserta ditolak (RESTRICT)'; Q='START TRANSACTION; DELETE FROM periode WHERE id_periode = 1; ROLLBACK;'; E='ERROR 1451' },
    @{ K='gagal'; N='Hapus kriteria yang dipakai periode ditolak (RESTRICT)'; Q='START TRANSACTION; DELETE FROM kriteria WHERE kode = ''C1''; ROLLBACK;'; E='ERROR 1451' },
    @{ K='gagal'; N='Username admin ganda ditolak'; Q='START TRANSACTION; INSERT INTO admin (username,password_hash,nama_lengkap) VALUES (''uji'',''x'',''A''); INSERT INTO admin (username,password_hash,nama_lengkap) VALUES (''uji'',''y'',''B''); ROLLBACK;'; E='ERROR 1062' }
)

Write-Host ""
Write-Host "Pengujian database: $Database" -ForegroundColor Cyan
Write-Host ("-" * 78)

$pass = 0; $fail = 0; $no = 0
foreach ($t in $tests) {
    $no++
    $r = Invoke-Mysql $t.Q
    $good = $false
    $info = ""
    switch ($t.K) {
        'ok'    { $good = ($r.Code -eq 0); if (-not $good) { $info = $r.Text } }
        'nilai' {
            $norm = (($r.Text -replace "`t", "|") -replace "\r?\n", ";")
            $good = ($r.Code -eq 0 -and $norm -eq $t.E)
            if (-not $good) { $info = "harapan='" + $t.E + "' hasil='" + $norm + "'" }
        }
        'gagal' {
            $good = ($r.Code -ne 0 -and $r.Text -like ("*" + $t.E + "*"))
            $first = ($r.Text -split "\r?\n")[0]
            if ($first.Length -gt 100) { $first = $first.Substring(0, 100) }
            $info = if ($good) { $first } else { "harapan " + $t.E + " | hasil: " + $first }
        }
    }
    if ($good) { $pass++; $tag = "LOLOS" ; $color = "Green" } else { $fail++; $tag = "GAGAL"; $color = "Red" }
    Write-Host ("{0,2}. [{1}] {2}" -f $no, $tag, $t.N) -ForegroundColor $color
    if ($info -ne "" -and ($t.K -eq 'gagal' -or -not $good)) { Write-Host ("        " + $info) -ForegroundColor DarkGray }
}

Write-Host ("-" * 78)
Write-Host ("Total: {0} uji | Lolos: {1} | Gagal: {2}" -f $tests.Count, $pass, $fail) -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
if ($fail -gt 0) { exit 1 }
