# 04 — Data Tiruan (Mock)

Semua yang bukan teks atau audio Al-Qur'an memakai data tiruan: pengguna, qari (foto dan bio), nasheed, adhkar, podcast, koleksi, playlist awal, dan rekomendasi. Dokumen ini menetapkan **bentuk** data dan **aturan pembuatannya**, supaya:

1. Desainer dan PM bisa mengubah isi tanpa menyentuh kode Dart.
2. Bentuknya cukup mirip backend sungguhan sehingga penggantian nanti tidak menyentuh layar (KPI 5).
3. Data tampil nyata saat demo: judul, durasi, dan gambar tidak terlihat sebagai "Lorem ipsum".

## 1. Prinsip

- **Berkas JSON di `assets/mock/`**, dimuat oleh repositori tiruan. Satu berkas per jenis data.
- **Bentuk mengikuti gaya API nyata**: kunci `camelCase`, `id` string, tanggal ISO 8601, durasi dalam detik bulat.
- **Tidak ada nama orang nyata di luar qari Al-Qur'an dari API.** Nama pelantun nasheed, pembicara podcast, dan pengguna dibuat fiktif (hindari mengklaim orang sungguhan mengucapkan konten tiruan).
- **Teks agama tiruan harus benar.** Judul adhkar dan terjemahannya tidak boleh dikarang; pakai teks yang sudah diverifikasi sumbernya, atau tandai item sebagai "contoh" dan jangan menampilkan teks Arab karangan. Lihat [bagian 6](#6-konten-agama-pada-data-tiruan).
- **Perubahan data tiruan tidak mengubah kode.** Kode hanya membaca skema di bawah.

## 2. Pengguna

Aplikasi tidak punya akun nyata. "Pengguna" adalah profil tiruan yang dipilih untuk mendemokan rekomendasi dan playlist.

`assets/mock/users.json`

```json
[
  {
    "id": "u-001",
    "displayName": "Aisyah",
    "avatar": "assets/images/avatars/a1.png",
    "favoriteQariIds": ["05", "03"],
    "listeningProfile": "daily",
    "createdAt": "2026-01-10T08:00:00Z"
  }
]
```

| Field | Arti |
|-------|------|
| `favoriteQariIds` | Kode qari API (`01`–`06`) |
| `listeningProfile` | `daily`, `memorizer`, `commuter`; memilih set riwayat awal untuk demo rekomendasi |

Keadaan bawaan: **tamu** (tanpa profil). Pengguna memilih "Masuk sebagai Aisyah" di Pengaturan untuk memuat profil demo; ini hanya mengganti data lokal, tidak ada kata sandi.

Usulan minimum: 3 profil dengan `listeningProfile` berbeda.

## 3. Model media tunggal

Pemutar tidak perlu tahu apakah item adalah surat atau nasheed. Semua jenis dibungkus satu model:

```dart
enum MediaKind { surah, ayah, nasheed, adhkar, podcastEpisode }
enum MediaSource { api, mock, local }

class MediaItem {
  final String id;            // "surah:1:05", "nasheed:n-014", "podcast:p-002:e-007"
  final MediaKind kind;
  final MediaSource source;
  final String title;
  final String subtitle;      // nama qari / pelantun / acara
  final Duration? duration;   // null bila belum diketahui (surat dari API)
  final Uri audioUri;         // jaringan, aset, atau berkas lokal
  final String? artwork;      // jalur aset
  final Map<String, Object?> meta; // surahNumber, qariId, dll.
}
```

Aturan `id`: berawalan jenis dan unik. Untuk surat, `id` memuat **nomor surat dan kode qari** (`surah:1:05`), karena satu surat dengan dua qari adalah dua item berbeda di antrean dan di unduhan.

## 4. Qari

`assets/mock/qaris.json` memegang bagian yang **tidak ada di API**: foto, bio, negara, gaya bacaan. Audio tetap dari API melalui `apiQariId`.

```json
[
  {
    "id": "q-05",
    "apiQariId": "05",
    "name": "Misyari Rasyid Al-Afasi",
    "country": "Kuwait",
    "photo": "assets/images/qari/05.png",
    "bio": "…",
    "styleTags": ["murattal", "merdu"],
    "isVocalOnly": true,
    "verifiedBy": "Tim konten (tiruan)"
  }
]
```

| Aturan | Isi |
|--------|-----|
| Jumlah | Tepat enam, satu untuk tiap kode API |
| Nama | Mengikuti pemetaan di [03 §3](03-api-integration.md#3-pemetaan-qari); ejaan dan **fakta biodata (negara, bio) harus diperiksa** sebelum dipakai di demo publik. Isi `country` dan `bio` di atas hanya contoh bentuk, bukan data terverifikasi |
| Foto | Tim memutuskan: foto asli butuh izin; alternatif ilustrasi/monogram buatan sendiri (disarankan) |
| `isVocalOnly` | Selalu `true` untuk bacaan Al-Qur'an |
| `verifiedBy` | Tiruan. Menampilkan lencana "Terverifikasi" tanpa proses nyata; lihat keputusan terbuka #11 di [01](01-overview.md#8-keputusan-yang-masih-terbuka) |

## 5. Nasheed, adhkar, podcast

### 5.1 Nasheed

`assets/mock/nasheed.json`

```json
[
  {
    "id": "n-014",
    "title": "…",
    "artist": "…",
    "album": "…",
    "durationSec": 214,
    "artwork": "assets/images/nasheed/n-014.png",
    "audio": "assets/audio_samples/sample_01.mp3",
    "tags": ["tenang", "anak"],
    "isVocalOnly": true,
    "language": "id",
    "releasedAt": "2025-03-02"
  }
]
```

Usulan: 20–30 item, 5–6 pelantun fiktif, 6–8 album, dengan sebaran `tags` supaya filter di [08 §3](08-catalog-playlist-offline.md#3-pencarian-dan-filter) terlihat bermakna.

### 5.2 Adhkar

`assets/mock/adhkar.json`

```json
[
  {
    "id": "a-003",
    "category": "pagi",
    "title": "…",
    "arabic": "…",
    "translation": "…",
    "source": "…",
    "repeat": 3,
    "durationSec": 45,
    "audio": "assets/audio_samples/sample_02.mp3"
  }
]
```

- `category`: `pagi`, `petang`, `setelah-salat`, `tidur`, `bangun`, `bepergian` (usulan; ubah sesuai kebutuhan).
- `arabic`, `translation`, `source` **wajib berasal dari sumber yang dapat dirujuk** ([bagian 6](#6-konten-agama-pada-data-tiruan)).
- `repeat` dipakai UI untuk penghitung "3×" (tidak mengulang audio otomatis kecuali pengguna menyalakan).

### 5.3 Podcast

`assets/mock/podcasts.json` — acara dengan episode bersarang:

```json
[
  {
    "id": "p-002",
    "title": "…",
    "host": "…",
    "description": "…",
    "artwork": "assets/images/podcast/p-002.png",
    "categories": ["kajian", "sirah"],
    "episodes": [
      { "id": "e-007", "title": "…", "durationSec": 1260, "publishedAt": "2026-09-01", "audio": "assets/audio_samples/sample_03.mp3" }
    ]
  }
]
```

Usulan: 4–5 acara, masing-masing 3–6 episode.

### 5.4 Audio untuk konten tiruan

API tidak menyediakan audio untuk nasheed, adhkar, dan podcast. Pilihan ([01 keputusan #1](01-overview.md#8-keputusan-yang-masih-terbuka)):

| Opsi | Kelebihan | Kekurangan |
|------|-----------|------------|
| **A. Berkas contoh kecil yang dibundel** (3–5 berkas, dipakai bergantian) | Pemutaran nyata (progres, seek, offline) dapat didemokan | Menambah ukuran aplikasi; perlu lisensi bebas dan atribusi; semua item terdengar sama |
| B. Pemutaran disimulasikan (timer, tanpa suara) | Ringan, tanpa masalah lisensi | Terasa palsu; tidak bisa menguji perilaku audio nyata |
| C. Tautan audio publik berlisensi bebas | Beragam | Menambah host jaringan lain (melanggar KPI 5), bisa mati |

Bawaan yang diusulkan: **A**. Bila dipilih A, kunci `audio` menunjuk ke jalur aset dan `MediaSource.mock`.

## 6. Konten agama pada data tiruan

Data tiruan tidak boleh menyebarkan kekeliruan agama:

- Teks Arab, terjemahan, dan rujukan adhkar **disalin dari sumber yang jelas** (kitab/koleksi yang disebut pada field `source`) dan diperiksa orang kedua sebelum demo.
- Bila belum ada waktu memverifikasi, **jangan tampilkan teks Arab karangan**; tampilkan judul dan audio saja, dan tandai kartu "Contoh konten".
- Deskripsi qari dan klaim "terverifikasi halal" adalah penanda antarmuka, bukan pernyataan sertifikasi. Tambahkan catatan "Data demo" di halaman Tentang.
- Jangan memakai nama ulama, pelantun, atau lembaga nyata pada data tiruan nasheed/podcast tanpa izin.

## 7. Koleksi, playlist, dan riwayat

### 7.1 Koleksi editorial (rak di Beranda)

`assets/mock/collections.json`

```json
[
  { "id": "c-001", "title": "Menemani perjalanan", "kind": "mixed", "itemIds": ["surah:36:05", "n-014", "p-002:e-007"] }
]
```

Koleksi boleh memuat campuran jenis media. `itemIds` memakai aturan `id` di [bagian 3](#3-model-media-tunggal).

### 7.2 Playlist

- **Playlist awal** (`playlists.json`): 3–4 playlist contoh per profil, supaya layar Playlist tidak kosong saat demo.
- **Playlist buatan pengguna** disimpan di basis data lokal, bukan di berkas aset. Berkas aset hanya benih (seed) yang disalin ke basis data pada pertama kali.
- Rincian model dan aturan di [08 §4](08-catalog-playlist-offline.md#4-playlist).

### 7.3 Riwayat dan benih rekomendasi

- `history_seed.json` berisi riwayat putar awal tiap `listeningProfile` supaya rekomendasi dapat didemokan sejak menit pertama.
- Riwayat nyata (yang dibuat saat pengguna memutar) ditulis ke basis data lokal dan menimpa/menambah benih.

## 8. Jujur tentang data tiruan di UI

- Satu halaman **Tentang** menjelaskan: data Al-Qur'an dari `equran.id`; sisanya data demo.
- Konten tiruan yang berkesan "resmi" (lencana terverifikasi, jumlah pendengar) diberi penanda halus "Demo" di mode pengembangan dan di Tentang. Jangan memajang angka pendengar palsu yang tampak seperti statistik nyata tanpa penanda.

## 9. Validasi data tiruan

Uji otomatis yang dianjurkan (cepat, murah):

| Uji | Tujuan |
|-----|--------|
| Setiap `id` unik dan berawalan jenis yang benar | Mencegah antrean/unduhan bentrok |
| `apiQariId` hanya `01`–`06`, dan ada tepat enam qari | Jembatan ke API tidak putus |
| Semua jalur `artwork` dan `audio` ada di aset | Mencegah gambar/suara hilang saat demo |
| `itemIds` koleksi dan playlist mengarah ke item yang ada | Mencegah baris rusak |
| `durationSec` > 0 | Mencegah progres NaN |
| Tidak ada URL selain `equran.id` dan `cdn.equran.id` | Menjaga KPI 5 |
