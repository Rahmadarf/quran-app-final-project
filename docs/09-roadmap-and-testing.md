# 09 — Roadmap, Pengujian, dan Risiko

## 1. Urutan pengerjaan

Urutan mengikuti lima fase di PRD. Prinsip: **bagian yang paling mahal bila salah dikerjakan lebih dulu** (pemutar dan kebenaran teks), tampilan dipoles belakangan. Estimasi waktu sengaja tidak diberikan karena tenggat belum diketahui; isi setelah tanggal pasti.

| Tahap | Isi | Selesai bila | PRD |
|-------|-----|--------------|-----|
| **M0 — Fondasi** | Struktur folder ([02 §5](02-architecture.md#5-struktur-folder-usulan)), tema dan token, router, klien API, model dan parser, `AppFailure`, repositori kosong, **uji asap kinerja web** (build rilis aplikasi hampir kosong, ukur FCP/LCP) | Aplikasi kosong berjalan di Android dan web; angka awal FCP/LCP tercatat | — |
| **M1 — Pemutar** | `PlayerController`, Mini Player, Player Bar, Fullscreen Player, antrean, acak/ulang, kecepatan, timer tidur, audio latar belakang, memutar surat dari API dan satu item tiruan | Kriteria selesai [05 §11](05-audio-player.md#11-kriteria-selesai-fase-1) lulus di perangkat nyata | Fase 1 |
| **M2 — Reader** | Daftar surat, Reader dua mode, Basmalah, pengaturan tampilan, `SyncEngine` mode A dan B, penanda, lembar tafsir | Kriteria [06 §10](06-quran-reader.md#10-kriteria-selesai-fase-2) lulus; uji teks suci lulus | Fase 2 |
| **M3 — Katalog dan playlist** | Data tiruan lengkap dan validasinya, katalog empat jenis, detail, pencarian, filter, playlist | Kriteria Fase 3 di [08 §7](08-catalog-playlist-offline.md#7-kriteria-selesai) lulus | Fase 3 |
| **M4 — Rekomendasi dan offline** | Riwayat, rak rekomendasi, unduhan, kelola penyimpanan, cache sementara | Kriteria Fase 4 di [08 §7](08-catalog-playlist-offline.md#7-kriteria-selesai) lulus, termasuk uji mode pesawat | Fase 4 |
| **M5 — QA dan rilis** | Uji kinerja dan responsivitas, aksesibilitas, optimasi muat (< 2 dtk), perbaikan, bangun rilis | Semua KPI di [bagian 3](#3-mengukur-kpi) terukur dan memenuhi target atau pengecualiannya disepakati PM | Fase 5 |

**Jika waktu sempit**, potong dari M4 (rekomendasi lanjutan, cache sementara, pra-muat) dan keindahan M3, **bukan** dari M1, M2, dan pengukuran KPI di M5. Pemutar yang andal dan teks yang benar adalah inti produk. Bagian M4 yang paling layak dipertahankan bila harus memilih: unduhan surat dasar + pemutaran offline.

### Pembagian peran (sesuai PRD)

| Peran | Nama | Tanggung jawab utama |
|-------|------|----------------------|
| Product Manager | Sahl | Menjaga ruang lingkup, memutuskan item di [01 §8](01-overview.md#8-keputusan-yang-masih-terbuka), menerima tiap tahap |
| UI/UX Designer | Dzulqarnain Abu Muhmmad | Desain layar [07](07-ui-ux.md), token desain, aset, pengamatan acuan, keputusan tampilan pemutar |
| Frontend Developer | Rahmat Arifin Susilo | Implementasi M0–M5, dokumen teknis 02–06 dan 08 |
| QA Engineer | Ade Setiawan | Rencana dan pelaksanaan uji [bagian 4](#4-strategi-pengujian), pengukuran KPI, daftar bug |

Ketergantungan lintas peran yang perlu dijadwalkan: desain pemutar sebelum M1 selesai; keputusan sumber audio tiruan sebelum M3; perangkat uji nyata (Android dan iOS) sebelum M1 ditutup.

## 2. Definisi selesai (per fitur)

Fitur dianggap selesai bila:

1. Berjalan end-to-end di perangkat nyata (bukan hanya emulator) untuk setidaknya satu ponsel Android dan build web; iOS bila perangkat tersedia.
2. Punya uji otomatis untuk jalur sukses dan sedikitnya dua jalur gagal (offline, data kosong, error API).
3. Keenam keadaan UI di [07 §4](07-ui-ux.md#4-keadaan-ui-yang-wajib-dirancang) dirancang dan teruji.
4. Pesan error berbahasa Indonesia yang ramah, tanpa pesan teknis mentah.
5. Lolos daftar aksesibilitas [07 §8](07-ui-ux.md#8-aksesibilitas-daftar-periksa) untuk layar itu.
6. Tidak menambah host jaringan selain `equran.id` dan `cdn.equran.id`.
7. Kode lolos `flutter analyze` (aturan `flutter_lints` yang sudah ada di proyek) tanpa peringatan baru.

## 3. Mengukur KPI

### 3.1 KPI 1 — Kecepatan muat (FCP < 1,2 dtk, LCP < 2 dtk)

| Aspek | Rencana |
|-------|---------|
| Apa yang diukur | **Build web rilis** (`flutter build web --release`) yang disajikan dari server statis lokal atau hosting uji, bukan mode debug |
| Alat | Lighthouse (Chrome DevTools) pada halaman Beranda; Web Vitals |
| Kondisi | Profil ponsel menengah: *Slow 4G*, CPU diperlambat 4×, cache bersih (kunjungan pertama) **dan** kunjungan kedua |
| Pengulangan | 5 kali, laporkan median |
| Kapan | **Sejak M0 (angka dasar)**, lalu tiap akhir tahap, bukan baru di M5 |

> **Risiko nyata:** aplikasi Flutter web membawa mesin render dan kode yang berukuran besar dibanding situs HTML biasa, sehingga target FCP 1,2 dtk di jaringan lambat tidak pasti tercapai. **Belum ada angka**; M0 menentukan apakah target realistis. Bila angka dasar jauh dari target, putuskan bersama PM: (a) kurangi kerja sebelum tampilan pertama dan pakai pemuatan tertunda, (b) tambahkan layar muat statis (HTML) yang ikut dihitung dalam FCP, (c) sesuaikan target atau definisinya untuk web. Jangan menyatakan KPI ini tercapai tanpa pengukuran.

Pada **iOS dan Android**, FCP/LCP tidak berlaku; ukur **cold start sampai Beranda tampil** di perangkat kelas menengah dengan `flutter run --profile` dan jejak awal DevTools (target usulan < 2 dtk; keputusan terbuka #6).

### 3.2 KPI 2 — Responsivitas dan kegunaan (100 %)

"100 %" didefinisikan sebagai: **semua sel pada matriks [§4.3](#43-matriks-responsivitas) lulus** untuk **semua layar utama** dengan daftar periksa per layar. Satu sel gagal = KPI belum tercapai. Hasil dicatat dalam lembar uji (layar × ukuran × tema × skala teks) oleh QA.

### 3.3 KPI 3 — Kelancaran 60 fps

| Aspek | Rencana |
|-------|---------|
| Alat | Flutter DevTools → Performance (*frame chart*), mode **profile**, perangkat nyata |
| Skenario | Mini Player ↔ Fullscreen (naik dan turun 10 kali), menggeser bilah geser, menggulir daftar surat panjang saat audio berjalan, sorotan ayat saat pemutaran Al-Baqarah |
| Kriteria | Rata-rata ≥ 55 fps; tidak ada rentetan bingkai > 32 ms; < 1 % bingkai > 16,6 ms pada skenario animasi pemutar (usulan batas, disepakati QA dan developer) |
| Perangkat | Setidaknya satu Android kelas menengah/rendah (bukan hanya perangkat tercepat) |

### 3.4 KPI 4 — Integrasi API akurat

- Uji kontrak ([03 §8](03-api-integration.md#8-uji-kontrak-api)): 114 surat, 6.236 ayat, enam kunci qari.
- Uji teks suci ([06 §6](06-quran-reader.md#6-kebenaran-teks)): teks yang dirender identik dengan respons.
- Sampel manual: QA membandingkan 10 surat (pendek, sedang, panjang) antara aplikasi dan sumber `equran.id`.
- Audio: tiap qari (6) × 3 surat dicoba diputar; tautan 404 dicatat.

### 3.5 KPI 5 — Pemisahan frontend-first

- Daftar host yang dipanggil aplikasi (Chrome DevTools Network di web; proksi pemeriksa di perangkat) **hanya** `equran.id` dan `cdn.equran.id`.
- Uji otomatis validasi data tiruan ([04 §9](04-mock-data.md#9-validasi-data-tiruan)): tidak ada URL host lain.
- Peninjauan kode: tidak ada impor paket yang memanggil layanan analitik atau backend lain.

### 3.6 KPI 6 — Smart offline caching

- Uji mode pesawat: unduh 3 surat → mode pesawat → buka Pustaka > Unduhan → putar dan baca.
- Uji ruang: ukuran yang ditampilkan sama (± toleransi) dengan ukuran berkas di perangkat; hapus unduhan membebaskan ruang.
- Uji duplikasi: unduh surat yang sama dua kali (dari dua tempat) → satu berkas.
- Hasilnya dibandingkan dengan rancangan [08 §5.5](08-catalog-playlist-offline.md#55-apa-yang-membuatnya-smart).

## 4. Strategi pengujian

Folder `test/` di repositori masih template; strategi ini yang harus diisi.

### 4.1 Uji unit (murah, banyak)

| Area | Skenario | Hasil yang benar |
|------|----------|------------------|
| Parser surat | Respons Al-Fatihah, Al-Ikhlas, surat 114 (tanpa `suratSelanjutnya`), surat 1 (`suratSebelumnya: false`) | Model benar; tanpa crash |
| Parser | Kunci audio tambahan/hilang; field wajib hilang | Kunci asing diabaikan; hilang → `AppFailure.parse` atau qari tidak tersedia |
| Parser tafsir | `ayat` bertipe string | Dikonversi ke int; entri tak terduga tidak membuat crash |
| Pembersih HTML `deskripsi` | `<i>`, `<br>`, tag tak dikenal | Gaya benar; tag lain dibuang |
| `SyncEngine` mode B | Durasi 120 dtk, ayat berbobot berbeda | `mulai` menaik, jumlah = durasi, `activeAyah` benar di batas |
| `SyncEngine` | Posisi 0, posisi = durasi, posisi di luar rentang | Dijepit; tanpa crash |
| Penormal pencarian | `Al Baqarah`, `baqarah`, `AL-BAQARAH`, `2`, `surat 2`, teks Arab dengan harakat | Semua menemukan Al-Baqarah |
| Filter | Gabungan beberapa filter (ATAU dalam, DAN antar) | Hasil sesuai [08 §3.3](08-catalog-playlist-offline.md#33-filter-per-jenis) |
| Playlist | Tambah duplikat, hapus + urungkan, reorder, batas 500 | Aturan [08 §4.2](08-catalog-playlist-offline.md#42-operasi-dan-aturan) |
| Rekomendasi | Riwayat kosong; profil `memorizer`; Jumat; jam 06.00 dan 17.00 | Rak muncul/hilang sesuai [08 §6.2](08-catalog-playlist-offline.md#62-rak-dan-aturan) |
| Antrean pemutar | Acak lalu matikan acak; hapus item aktif; `previous` pada 2 dtk dan 5 dtk | Urutan dan indeks benar |
| Status pemutar | Urutan perintah acak (fuzz ringan) | Tidak pernah masuk keadaan tidak sah |
| Data tiruan | Validasi [04 §9](04-mock-data.md#9-validasi-data-tiruan) | Lulus |
| Unduhan | Penentuan kelengkapan (ukuran tak cocok), pembersihan `*.part` | Ditandai gagal/dibersihkan |

### 4.2 Uji widget dan golden

| Uji | Hasil yang benar |
|-----|------------------|
| **Teks suci** (Al-Fatihah, Al-Baqarah 1 dan 282, An-Nas) | String yang dirender sama persis dengan data API |
| Basmalah | Surat 1: tidak ada kepala (ayat 1 adalah Basmalah); 2–114 kecuali 9: ada; 9: tidak ada |
| Mini Player/Player Bar/Fullscreen | Menampilkan item, status, dan kontrol yang sama dari satu status |
| Keadaan daftar | Memuat, kosong, galat, offline, data lama masing-masing tampil |
| Skala teks 200 % | Tidak ada overflow pada layar utama |
| Golden tema terang dan gelap | Tidak ada regresi visual pada komponen kunci |

### 4.3 Matriks responsivitas

Uji pada **setiap layar utama** (Beranda, Quran, Reader, Jelajah/Katalog, Cari, Pustaka, Fullscreen Player, Pengaturan):

| Kelas | Ukuran uji (dp) | Orientasi | Skala teks | Tema |
|-------|-----------------|-----------|------------|------|
| Compact kecil | 320 × 568 | Potret | 100 %, 200 % | Terang, gelap |
| Compact umum | 360 × 800, 390 × 844, 412 × 915 | Potret, lanskap | 100 %, 150 % | Terang, gelap |
| Medium | 768 × 1024 (tablet), 844 × 390 (ponsel lanskap) | Potret, lanskap | 100 % | Terang |
| Expanded | 1024 × 768, 1440 × 900, 1920 × 1080 | Lanskap | 100 % | Terang, gelap |
| Perubahan ukuran langsung (web) | Seret jendela dari 1920 ke 320 | — | 100 % | Terang |

Kriteria per sel: tidak ada overflow/teks terpotong; kontrol tetap terjangkau (≥ 48 dp); pemutar tidak menutupi isi tanpa jalan menggulir; navigasi sesuai kelas ([07 §0.1](07-ui-ux.md#01-titik-patah-breakpoint)); Reader terbaca dan sorotan tidak hilang.

### 4.4 Uji alur (integrasi / E2E)

1. **Dengar lalu baca:** Beranda → surat Yasin → putar → Mini Player muncul → buka Fullscreen → Baca → Reader menyorot ayat aktif → ketuk ayat lain → audio melompat.
2. **Berpindah layar saat memutar:** putar → Katalog → Cari → Pustaka; pemutaran tidak terputus dan Mini Player tetap.
3. **Playlist:** buat playlist → tambah 3 item dari tiga layar → urutkan → putar → tutup aplikasi → buka lagi → playlist dan item aktif (dalam keadaan jeda) pulih.
4. **Unduh dan offline:** unduh surat → mode pesawat → putar dan baca → hapus unduhan → status kembali "tersedia".
5. **Jaringan putus saat memutar:** putus di tengah → `buffering` → `error` dengan "Coba lagi" → sambung → lanjut.
6. **API gagal:** blokir `equran.id` → daftar surat dari cache; tanpa cache → keadaan galat; Beranda tetap menampilkan konten tiruan.
7. **Rekomendasi:** ganti profil demo → rak berubah; hapus riwayat → rak kembali editorial.
8. **Web:** muat ulang di `/quran/36` → langsung ke Reader; tombol kembali browser benar.

### 4.5 Uji kontrak API

Lihat [03 §8](03-api-integration.md#8-uji-kontrak-api). Dijalankan manual sebelum tiap rilis dan setelah ada laporan perubahan.

### 4.6 Uji manual di perangkat

- Audio latar belakang dan layar kunci (Android dan iOS): kontrol, metadata, artwork.
- Gangguan: panggilan masuk, alarm, cabut headset, Bluetooth putus.
- Perangkat: sedikitnya satu Android lama/rendah, satu Android baru, satu iPhone (bila ada), dan tiga browser (Chrome, Safari, Firefox).
- Jaringan: Wi‑Fi, seluler, putus-sambung berulang.
- Ukuran font sistem besar dan mode kontras tinggi.
- Pembaca layar dasar (TalkBack, VoiceOver) pada alur 1.
- Cek teks Arab pada setiap perangkat/browser: tanda baca tidak hilang atau bertumpuk.

### 4.7 Uji aksesibilitas

Daftar [07 §8](07-ui-ux.md#8-aksesibilitas-daftar-periksa) dilaksanakan per layar; temuan dicatat dengan tingkat keparahan. Alat bantu: pemeriksa kontras, `SemanticsDebugger`, pembaca layar nyata.

### 4.8 Pemeriksaan sebelum rilis

Daftar periksa singkat: analisis statis bersih; uji unit dan widget lulus; uji kontrak API lulus; angka KPI 1 dan 3 terbaru dicatat; matriks responsivitas lengkap; halaman Tentang memuat atribusi dan catatan data demo; tidak ada kunci/rahasia di repositori; ikon dan nama aplikasi tidak memakai merek lain.

## 5. Register risiko

| # | Risiko | Kemungkinan | Dampak | Mitigasi |
|---|--------|-------------|--------|----------|
| 1 | Target FCP < 1,2 dtk dan LCP < 2 dtk sulit dicapai pada Flutter web (muatan awal besar, jaringan lambat) | Tinggi | Tinggi | Ukur sejak M0; pemuatan tertunda; layar muat statis; font disubset; sepakati penyesuaian target bila perlu |
| 2 | `equran.id` lambat, berubah bentuk, membatasi laju, atau mati saat demo | Sedang | Tinggi | Cache disk agresif; uji kontrak; unduhan beberapa surat kunci sebelum demo; **siapkan contoh respons** untuk cadangan demo (periksa lisensi) |
| 3 | Pemutaran latar belakang/layar kunci bermasalah di iOS atau Android baru (konfigurasi, izin) | Sedang | Tinggi | Uji di perangkat nyata sejak M1; ikuti dokumentasi `audio_service`/`just_audio`; catat perilaku per platform |
| 4 | **Lisensi dan syarat penggunaan** teks, terjemahan, audio `equran.id` (termasuk menyimpan offline dan menampilkan ulang) belum diperiksa | Sedang | Tinggi | Baca syarat sebelum rilis publik; hubungi pengelola bila perlu; atribusi di Tentang; batasi demo bila tidak jelas |
| 5 | Sorotan ayat mode surat penuh (tiruan) meleset | Tinggi | Sedang | Lencana "perkiraan"; kalibrasi; Mode A sebagai jalur akurat; uji dengan 3 surat × 2 qari |
| 6 | Teks Arab rusak oleh font atau pemformatan (tanda baca hilang/bertumpuk) | Rendah | **Sangat tinggi** | Font diuji penuh; uji teks suci otomatis; tidak ada pemrosesan teks; bug jenis ini prioritas tertinggi |
| 7 | Konten agama tiruan (adhkar, deskripsi) keliru | Sedang | Tinggi | Salin dari sumber rujukan; tinjau orang kedua; tandai "contoh" bila belum diverifikasi ([04 §6](04-mock-data.md#6-konten-agama-pada-data-tiruan)) |
| 8 | Developer frontend tunggal, cakupan luas (5 fase) | Tinggi | Tinggi | Urutan M0–M5, potong dari M4 bukan M1–M2; keputusan terbuka diselesaikan lebih awal; QA ikut sejak M1 |
| 9 | Unduhan audio di web terhalang CORS/ruang penyimpanan browser | Tinggi | Sedang | Nonaktifkan unduhan audio di web sampai terbukti; uji pekerja layanan/proksi di M4 |
| 10 | Berkas audio surat panjang sangat besar; ruang pengguna habis | Sedang | Sedang | Ukur dahulu; tampilkan ukuran sebelum unduh; cadangan ruang; kelola penyimpanan |
| 11 | Jank saat membuka/menggulir surat panjang (Al-Baqarah) | Sedang | Sedang | Parse di isolate; daftar malas; `select` atas ayat aktif; ukur di perangkat rendah |
| 12 | Audio untuk nasheed/adhkar/podcast tiruan belum ada atau tak berlisensi | Sedang | Sedang | Putuskan keputusan #1 sebelum M3; pakai berkas berlisensi bebas dengan atribusi |
| 13 | Desain terlambat atau berubah besar setelah komponen dibuat | Sedang | Sedang | Komponen berbasis token; [07](07-ui-ux.md) sebagai acuan struktur; tinjauan desain per tahap |
| 14 | Perangkat Android rendah tidak memenuhi 60 fps | Sedang | Sedang | Uji di perangkat rendah sejak M1; kurangi efek (blur, bayangan berat) bila perlu; hormati "kurangi gerakan" |
| 15 | Lencana "terverifikasi halal" pada data tiruan disalahpahami sebagai sertifikasi nyata | Sedang | Sedang | Catatan "Data demo" di Tentang dan penanda di mode demo; jangan mengklaim sertifikasi |
| 16 | Sengketa merek/aset karena terinspirasi MuslyWave/Spotify | Rendah | Tinggi | Identitas, nama, logo, dan aset buatan sendiri; pernyataan tidak berafiliasi di Tentang |
| 17 | Transliterasi nama surat tidak seragam sehingga pencarian melewatkan ejaan lain | Sedang | Rendah | Normalisasi dan uji ejaan umum; daftar alias (mis. "Yasin"/"Ya-Sin") sebagai data tambahan |
| 18 | Fragmentasi perilaku web (Safari membatasi pemutaran otomatis, tab latar menghentikan audio) | Sedang | Sedang | Mulai putar hanya dari ketukan pengguna; catat batasan; uji tiga browser |
| 19 | Rute web (path vs hash) dan penyegaran halaman rusak di hosting statis | Rendah | Rendah | Konfigurasi pengalihan ke `index.html` di hosting; uji E2E #8 |

## 6. Pertanyaan yang masih terbuka

Lihat [01 §8](01-overview.md#8-keputusan-yang-masih-terbuka). Yang memengaruhi kode paling awal:

1. **Sumber audio nasheed/adhkar/podcast** (#1) — sebelum M3.
2. **Manajemen status dan penyimpanan lokal** (#2, #3) — sebelum M0 selesai.
3. **Padanan KPI 1 untuk native dan perangkat acuan** (#6) — sebelum M5, diukur dasar di M0.
4. **Berkas desain dan token** (#9) — sebelum M1.
5. **Syarat penggunaan `equran.id`** (risiko #4) — sebelum rilis.

## 7. Ide setelah versi 1

- Pencarian isi ayat dan terjemahan (butuh indeks lokal seluruh teks).
- Data waktu ayat nyata untuk audio surat penuh, sehingga mode B menjadi akurat.
- Akun dan sinkronisasi antarperangkat dengan backend sungguhan (repositori sudah dipisah).
- Mode hafalan: ulang rentang ayat dengan jeda, sembunyikan teks.
- Terjemahan dan tafsir bahasa lain.
- Widget layar kunci dan layar utama, serta dukungan Apple CarPlay/Android Auto.
- Pewaktu otomatis untuk "tidur setelah surat selesai" dan pengingat adhkar.
- Mode baca dengan halaman Mushaf sungguhan bila sumber data halaman tersedia.
