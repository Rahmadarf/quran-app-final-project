# 03 — Integrasi API Al-Qur'an (`equran.id`)

Dokumen ini mencatat apa yang **sudah dicoba langsung** pada 17 Nov 2026 (hanya permintaan `GET`, tanpa kunci API) dan bagaimana aplikasi memakainya. Yang belum dicoba ditandai.

## 1. Alamat dan sifat API

| Hal | Nilai | Status |
|-----|-------|--------|
| Alamat dasar yang berfungsi | `https://equran.id/api/v2` | Diverifikasi |
| Alamat di PRD | `https://equran.id/apidev/v2` | **Salah**: `GET /apidev/v2/surat/1` mengembalikan HTTP 404 berisi halaman HTML, bukan JSON |
| Autentikasi | Tidak ada | Diverifikasi (tanpa header khusus) |
| Format | JSON `application/json; charset=utf-8` | Diverifikasi |
| Metode | `GET`, `OPTIONS`, `HEAD` | Dari header `access-control-allow-methods` |
| CORS | `access-control-allow-origin: *` | Diverifikasi (penting untuk build web) |
| Cache HTTP | `cache-control: public, max-age=2592000, stale-while-revalidate=604800` (30 hari + 7 hari) | Diverifikasi |
| Validator cache | Header `etag` ada pada `/surat` | Diverifikasi |
| Kuota dan batas laju | Tidak diketahui | **Belum dicek**; jangan memuat massal |
| Syarat penggunaan/atribusi | Tidak diketahui | **Belum dibaca**; periksa sebelum rilis publik |

Selubung respons (sukses):

```json
{ "code": 200, "message": "Data retrieved successfully", "data": { } }
```

Selubung respons (tidak ditemukan, misalnya `/surat/999`):

```json
{ "code": 404, "message": "Data not found" }
```

## 2. Endpoint yang dipakai

| # | Endpoint | Dipakai untuk | Ukuran (17 Nov 2026) |
|---|----------|---------------|----------------------|
| 1 | `GET /surat` | Daftar 114 surat + tautan audio penuh 6 qari | 122.946 byte mentah, ±22,5 KB terkompresi |
| 2 | `GET /surat/{nomor}` | Detail surat: semua ayat, audio per ayat, surat sebelumnya/berikutnya | Al-Fatihah ±1,6 KB; Al-Baqarah 396.697 byte terurai, ±89 KB terkompresi |
| 3 | `GET /tafsir/{nomor}` | Tafsir per ayat satu surat | Belum diukur |

Endpoint lain di `equran.id` (jadwal, doa, dll.) **di luar ruang lingkup** dan tidak dicoba.

### 2.1 Daftar surat — `GET /surat`

`data` adalah larik 114 objek:

| Field | Tipe | Contoh | Catatan |
|-------|------|--------|---------|
| `nomor` | int | `1` | 1–114 |
| `nama` | string | `الفاتحة` | Nama Arab |
| `namaLatin` | string | `Al-Fatihah` | |
| `jumlahAyat` | int | `7` | Jumlah seluruh ayat 6.236 (diverifikasi) |
| `tempatTurun` | string | `Mekah` | Hanya `Mekah` (84) dan `Madinah` (30) |
| `arti` | string | `Pembukaan` | |
| `deskripsi` | string | `Surat <i>Al Faatihah</i> ...` | **Berisi tag HTML** (`<i>`, `<br>`) |
| `audioFull` | objek | `{"01": "https://cdn.equran.id/audio-full/Abdullah-Al-Juhany/001.mp3", ...}` | Kunci `01`–`06`; ke-114 surat memiliki keenam kunci (diverifikasi) |

### 2.2 Detail surat — `GET /surat/{nomor}`

Semua field di atas, ditambah:

| Field | Tipe | Catatan |
|-------|------|---------|
| `ayat` | larik | Satu objek per ayat, urut |
| `suratSelanjutnya` | objek atau `false` | `{nomor, nama, namaLatin, jumlahAyat}`; pada surat 114 kunci ini **tidak ada** |
| `suratSebelumnya` | objek atau `false` | Pada surat 1 bernilai `false` |

Objek `ayat`:

| Field | Tipe | Contoh |
|-------|------|--------|
| `nomorAyat` | int | `1` |
| `teksArab` | string | `بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ` |
| `teksLatin` | string | `Bismillāhir-raḥmānir-raḥīm(i). ` (ada spasi di ujung) |
| `teksIndonesia` | string | `Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.` |
| `audio` | objek | `{"01": ".../audio-partial/Abdullah-Al-Juhany/001001.mp3", ...}` kunci `01`–`06` |

Pola nama berkas audio per ayat: `{SSS}{AAA}.mp3` (surat 3 digit + ayat 3 digit), mis. `001001.mp3`. Pola audio penuh: `{SSS}.mp3`. **Aplikasi tidak boleh menyusun URL sendiri dari pola ini**; selalu pakai URL dari respons.

### 2.3 Surat yang kosong atau tidak ada

`GET /surat/999` → 404 dengan badan JSON. Nomor di luar 1–114 tidak boleh dikirim dari UI (pemilih surat hanya menampilkan 1–114); 404 tetap ditangani sebagai `notFound`.

### 2.4 Audio di CDN

| Hal | Hasil pada percobaan |
|-----|----------------------|
| Host | `cdn.equran.id` |
| Tipe | `audio/mpeg` |
| `accept-ranges: bytes` | Ya (diverifikasi pada berkas per ayat dan penuh); penting untuk lompat posisi (seek) tanpa mengunduh semua |
| Ukuran contoh | Al-Fatihah ayat 1 qari `01`: 53.208 byte. Al-Fatihah penuh qari `01`: 1.537.300 byte |
| Ukuran surat panjang | **Belum diukur** (Al-Baqarah penuh akan jauh lebih besar; ukur sebelum menetapkan batas unduhan) |
| Header CORS pada percobaan | Tidak terlihat pada berkas per ayat. Pemutaran lewat elemen audio browser tidak membutuhkan CORS, tetapi **membaca byte audio dari kode web** (mis. untuk cache sendiri) bisa gagal. Uji di build web sebelum merencanakan unduhan di web |

### 2.5 Tafsir per surat

`GET /tafsir/{nomor}` mengembalikan field surat yang sama dengan `/surat`, tanpa `ayat`, dengan:

```json
"tafsir": [ { "ayat": "1", "teks": "Surah al-Fatihah dimulai dengan Basmalah\n\nAda beberapa pendapat ..." } ]
```

Catatan: `ayat` di sini bertipe **string**, bukan int; ubah ke int saat parsing. `teks` berisi baris baru (`\n`). Satu entri tafsir bisa mencakup beberapa ayat atau bernomor tidak berurutan: **belum diperiksa**; jangan berasumsi satu entri per ayat.

## 3. Pemetaan qari

API hanya mengenal kode `01`–`06`. Nama dalam tabel ini **disimpulkan dari alamat berkas audio**, bukan dari endpoint resmi daftar qari (tidak ada yang dicoba). Tim perlu memastikan ejaan nama dan izin penggunaan foto/biodata.

| Kode API | Nama dari alamat berkas | Folder CDN |
|----------|-------------------------|-----------|
| `01` | Abdullah Al-Juhany | `Abdullah-Al-Juhany` |
| `02` | Abdul Muhsin Al-Qasim | `Abdul-Muhsin-Al-Qasim` |
| `03` | Abdurrahman As-Sudais | `Abdurrahman-as-Sudais` |
| `04` | Ibrahim Al-Dossari | `Ibrahim-Al-Dossari` |
| `05` | Misyari Rasyid Al-Afasi | `Misyari-Rasyid-Al-Afasi` |
| `06` | Yasser Al-Dosari | `Yasser-Al-Dosari` |

`QariRepository` (data tiruan) memegang foto, bio, dan negara tiap qari, dan memiliki field `apiQariId` yang menunjuk ke kode ini. Itulah satu-satunya jembatan antara katalog tiruan dan audio nyata ([04 §4](04-mock-data.md#4-qari)).

## 4. Model domain dan DTO

DTO (bentuk persis JSON) dipisahkan dari model domain (bentuk yang dipakai UI), supaya perubahan API tidak merembet ke layar.

```dart
// DTO: mengikuti JSON apa adanya (usulan)
class SurahSummaryDto {
  final int nomor;
  final String nama, namaLatin, tempatTurun, arti, deskripsi;
  final int jumlahAyat;
  final Map<String, String> audioFull;      // kunci "01".."06"
}

class AyahDto {
  final int nomorAyat;
  final String teksArab, teksLatin, teksIndonesia;
  final Map<String, String> audio;           // kunci "01".."06"
}

// Domain: dipakai UI
class Surah {
  final int number;
  final String arabicName, latinName, meaning;
  final Revelation revelation;               // makkiyah | madaniyah
  final int ayahCount;
  final String descriptionPlain;             // deskripsi sudah dibersihkan dari tag HTML
  final Map<QariId, Uri> fullAudio;
}

class Ayah {
  final int surahNumber, number;
  final String arabic, transliteration, translation;   // tidak diubah dari API
  final Map<QariId, Uri> audio;
}
```

Aturan parsing:

1. **Kunci tak terduga tidak boleh membuat aplikasi mogok.** Kunci audio selain `01`–`06` diabaikan; kunci yang hilang membuat qari itu tidak tersedia untuk surat tersebut (UI menyembunyikannya, bukan error).
2. `suratSelanjutnya` / `suratSebelumnya`: terima objek, `false`, atau kunci tidak ada.
3. `teksLatin` boleh di-`trim()` di tampilan; `teksArab` dan `teksIndonesia` **tidak diubah** (lihat [06 §6](06-quran-reader.md#6-kebenaran-teks)).
4. `deskripsi`: ubah `<i>…</i>` menjadi teks miring, `<br>` menjadi baris baru, buang tag lain. Jangan render HTML mentah.
5. Respons yang gagal parsing menghasilkan `AppFailure.parse`, bukan mogok.

## 5. Strategi cache

| Data | Di memori | Di disk | Masa berlaku | Alasan |
|------|-----------|---------|--------------|--------|
| Daftar surat (`/surat`) | Ya | Ya | 7 hari (usulan; API menyatakan 30 hari) | Muncul di Beranda dan Katalog; harus instan pada kunjungan ke-2 |
| Detail surat | Ya (maks. 5 surat terakhir) | Ya | 30 hari, sesuai header API | Surat tidak berubah; respons besar |
| Tafsir | Tidak | Ya | 30 hari | Dibuka jarang |
| Audio | Tidak | Hanya bila diunduh ([08 §5](08-catalog-playlist-offline.md#5-offline-caching)) | Sampai dihapus pengguna | Besar; ditangani sebagai unduhan eksplisit |

- Strategi: **cache dulu, perbarui di latar belakang** (*stale-while-revalidate*), mengikuti niat server. Tampilkan data cache segera; perbarui bila lewat masa berlaku dan jaringan ada.
- Bila jaringan gagal dan ada cache, tampilkan cache dengan banner kecil; bila tidak ada cache, tampilkan keadaan error dengan "Coba lagi".
- Kunci cache memuat versi skema (`v1`) supaya perubahan model tidak membaca cache lama yang tidak cocok.
- Pada web, `Cache-Control` server dan cache browser sudah membantu; cache disk aplikasi tetap dipakai agar perilaku sama di semua platform.

## 6. Perkiraan beban jaringan

Dihitung dari ukuran yang diukur 17 Nov 2026 (angka terkompresi):

| Skenario | Perkiraan |
|----------|-----------|
| Buka aplikasi pertama kali (daftar surat) | ±22,5 KB |
| Buka surat pendek (mis. Al-Ikhlas, 4 ayat) | ±1–2 KB |
| Buka Al-Baqarah (286 ayat) | ±89 KB |
| Seluruh 114 surat | Belum diukur; **jangan** dimuat bersamaan sebagai awal aplikasi |

Konsekuensi: respons teks ringan; **audio** yang mendominasi data. Tampilan awal (FCP/LCP) tidak boleh menunggu surat mana pun selain daftar.

## 7. Penanganan kegagalan

| Kondisi | Jenis `AppFailure` | Perilaku UI |
|---------|--------------------|-------------|
| Tidak ada jaringan | `offline` | Pakai cache; bila tidak ada, keadaan error + coba lagi |
| Lewat batas waktu | `timeout` | Coba ulang otomatis 2 kali, lalu tampilkan error |
| HTTP 404 | `notFound` | "Surat tidak ditemukan." (seharusnya mustahil dari UI) |
| HTTP 5xx | `server` | Pakai cache bila ada; kalau tidak, error + coba lagi |
| JSON rusak atau field wajib hilang | `parse` | Pesan umum; catat di log |
| Berkas audio 404/putus di tengah | Dari mesin audio | Hentikan item, tampilkan pesan, beri tombol "Coba lagi" |

## 8. Uji kontrak API

Karena API pihak ketiga bisa berubah tanpa pemberitahuan:

- Simpan **contoh respons** (Al-Fatihah, Al-Ikhlas, An-Nas, daftar surat) sebagai berkas uji dan uji parser terhadapnya.
- Satu uji "kontrak" yang boleh dijalankan manual (bukan di CI wajib): ambil `/surat`, periksa 114 entri, jumlah ayat total 6.236, dan keenam kunci qari ada.
- Bila uji kontrak gagal, jangan memperbaiki dengan mengubah data; catat perubahan API dan perbarui dokumen ini.
