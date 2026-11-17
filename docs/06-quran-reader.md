# 06 — Reader Al-Qur'an dan Mesin Sinkronisasi (Fase 2)

Reader menampilkan teks Arab, transliterasi, dan terjemahan Indonesia per ayat dari API, dan menyorot ayat yang sedang dibacakan. PRD menyebut dua bagian: **layout Mushaf/teks + terjemahan per ayat**, dan **simulasi modul sinkronisasi teks real-time dengan data tiruan**.

## 1. Fakta data yang memengaruhi rancangan

Semua diverifikasi pada 17 Nov 2026 (lihat [03](03-api-integration.md)).

| Fakta | Akibat pada rancangan |
|-------|----------------------|
| API tidak memuat nomor halaman mushaf, juz, atau hizb | "Layout Mushaf" **tidak dapat** mereproduksi halaman Mushaf cetak. Yang dibuat: teks Arab mengalir bergaya mushaf (lihat §3.2) |
| Basmalah **tidak** termasuk ayat pada surat 2 dan 9 (ayat 1 Al-Baqarah `الۤمّۤ`, ayat 1 At-Taubah `بَرَاۤءَةٌ…`); pada Al-Fatihah Basmalah adalah ayat 1 | Reader menampilkan kepala Basmalah terpisah untuk surat 2–114 kecuali 9; teksnya diambil dari ayat 1 Al-Fatihah di API, **tidak diketik sendiri** |
| Ada audio per ayat untuk keenam qari | Sinkronisasi **nyata** untuk mode per ayat |
| Audio penuh hanya satu berkas per surat; API tidak memberi waktu mulai tiap ayat | Sinkronisasi untuk mode surat penuh hanya bisa **perkiraan (tiruan)** |
| Surat panjang: Al-Baqarah 286 ayat, ±397 KB terurai; ayat terpanjang 1.218 karakter Arab | Daftar harus malas-muat (*lazy*); satu ayat bisa lebih tinggi dari layar |
| Ada tafsir per ayat (`/tafsir/{nomor}`) | Lembar tafsir per ayat tersedia |

## 2. Layar dan navigasi Reader

### 2.1 Daftar surat

- Satu daftar 114 surat dengan: nomor (dalam ornamen), nama Latin, arti, nama Arab, jumlah ayat, penanda Mekah/Madinah.
- Pencarian cepat (nama Latin, arti, nomor) dan penyaring Mekah/Madinah. Data dari `GET /surat` (satu permintaan, di-cache).
- Ketuk → Reader surat itu. Tombol putar di baris → memutar langsung tanpa membuka Reader.
- Bagian "Lanjutkan membaca": surat dan ayat terakhir dibaca/didengar (data lokal).

### 2.2 Layar Reader

Susunan dari atas:

1. **Bilah atas:** kembali, judul (nama Latin + Arab), tombol pengaturan tampilan, tombol qari.
2. **Kepala surat:** nama Arab besar, arti, "Mekah · 7 ayat". Ketuk untuk membuka `deskripsi` (teks sudah dibersihkan dari HTML).
3. **Basmalah** (sesuai aturan §1).
4. **Daftar ayat** (§3).
5. **Pemutar:** Mini Player/Player Bar tetap di bawah (satu pemutar yang sama, [05](05-audio-player.md)).
6. **Navigasi surat:** tombol "Surat sebelumnya/berikutnya" di akhir daftar memakai `suratSebelumnya`/`suratSelanjutnya` dari API (kasus `false`/tidak ada ditangani).

## 3. Tata letak ayat

Dua mode tampilan, dipilih pengguna dan diingat.

### 3.1 Mode "Terjemahan" (bawaan)

Satu kartu per ayat:

```
┌────────────────────────────────────────────┐
│ ۝ ٢                       ▶  🔖  ⋯         │  ← nomor ayat + aksi
│                                            │
│            teks Arab (RTL, besar)          │
│                                            │
│  Transliterasi Latin (opsional, redup)     │
│  Terjemahan Indonesia                      │
└────────────────────────────────────────────┘
```

- Urutan dan isi tidak berubah dari API. Transliterasi dan terjemahan dapat disembunyikan satu per satu.
- Ayat aktif diberi latar sorotan dan tepi aksen (tidak hanya warna: juga garis tepi tebal agar terlihat tanpa warna).

### 3.2 Mode "Mushaf"

- Teks Arab mengalir sambung-menyambung dalam satu blok RTL, dengan **penanda akhir ayat** (`۝` + angka Arab-Indic) di antara ayat. Penanda dibuat oleh aplikasi dari `nomorAyat`; itu ornamen tampilan, bukan perubahan teks.
- Terjemahan **tidak** tampil di aliran; mengetuk ayat membuka lembar bawah berisi terjemahan, transliterasi, dan tafsir ayat itu.
- Ayat aktif disorot dalam aliran (rentang teks diwarnai/digarisbawahi).
- **Bukan halaman Mushaf cetak.** Pemisahan halaman, juz, dan baris Mushaf Madinah tidak tersedia dari API; jangan menyebut mode ini "Mushaf Madinah" di UI. Nama di UI: "Mode baca".

### 3.3 Pengaturan tampilan

| Pengaturan | Pilihan | Bawaan |
|------------|---------|--------|
| Ukuran huruf Arab | 5 tingkat (± 24–44 sp) | Tingkat 3 |
| Ukuran terjemahan | 3 tingkat | Sedang |
| Tampilkan transliterasi | ya/tidak | tidak |
| Tampilkan terjemahan | ya/tidak (mode Terjemahan) | ya |
| Ikuti ayat otomatis (*auto-scroll*) | ya/tidak | ya |
| Mode | Terjemahan / Mushaf | Terjemahan |

Pengaturan disimpan lokal (`SettingsRepository`) dan berlaku di semua surat.

### 3.4 Font Arab

Teks API memuat tanda baca penuh (harakat, tanda waqaf, tanda panjang khusus seperti `ۤ`). **Font harus dipilih dan diuji** supaya tidak ada tanda yang hilang atau bertumpuk. Font Arab dibundel (bukan dari jaringan; lihat KPI 5 dan [02 §9](02-architecture.md#9-keputusan-arsitektur-ringkas)). Uji dengan ayat terpanjang (Al-Baqarah 282) dan ayat yang memuat tanda khusus (mis. Al-Baqarah 1, At-Taubah 1) pada ukuran terkecil dan terbesar.

## 4. Mesin sinkronisasi (`SyncEngine`)

`SyncEngine` menjawab satu pertanyaan: **ayat mana yang sedang dibacakan sekarang?** Ia tidak memutar audio dan tidak mengubah teks.

```
(posisi audio, mode, data surat)  ─▶  SyncEngine  ─▶  activeAyah (int?) + progres dalam ayat (0..1)
```

### 4.1 Mode A — Per ayat (sinkronisasi nyata)

- Antrean pemutar berisi **satu `MediaItem` per ayat** (kind `ayah`, audio dari `ayat[n].audio[qari]`).
- `activeAyah` = indeks item yang sedang diputar. Tidak ada perhitungan waktu; selalu tepat.
- Berpindah ayat = `seekToIndex`. Mengetuk ayat → mulai dari ayat itu. "Ulangi ayat" = `repeat=one` pada item itu. "Ulangi rentang" = antrean dipotong menjadi rentang dan `repeat=all`.
- Pemuatan: item dimuat **malas**, sambil menyiapkan ayat berikutnya agar sambungan tanpa jeda panjang. Surat panjang tidak boleh meminta 286 berkas sekaligus.
- Kekurangan yang harus diterima: ada jeda tipis antarberkas, dan bacaan terasa lebih "terpotong-potong" dibanding audio surat penuh.

### 4.2 Mode B — Surat penuh (waktu tiruan, *mock sync*)

Audio satu berkas; tidak ada data waktu per ayat dari API. PRD memintanya **disimulasikan** dengan data tiruan.

**Perkiraan waktu mulai ayat** (usulan, perlu dikalibrasi):

```
bobot(ayat_i)      = jumlah huruf dasar Arab di teksArab_i (tanpa harakat/tanda baca) + jeda_tetap
total              = Σ bobot(ayat_i)
mulai(ayat_i)      = durasi_audio × (Σ bobot(ayat_1 .. ayat_{i-1})) / total
selesai(ayat_i)    = mulai(ayat_{i+1})
```

- `jeda_tetap` setara ±0,3 detik per ayat (nilai awal; dikalibrasi).
- Basmalah audio: audio penuh dari API pada surat 2–114 kemungkinan **memuat Basmalah di awal** (belum dicek). Bila ya, tambahkan bobot Basmalah di awal perhitungan. Ini **harus didengar dan diuji** pada beberapa qari.
- `activeAyah` = ayat dengan `mulai ≤ posisi < selesai` (pencarian biner pada larik `mulai`).

**Kejujuran antarmuka:** pada mode ini sorotan adalah **perkiraan** dan bisa meleset beberapa detik, terutama di surat panjang. Tampilkan lencana kecil "Sorotan perkiraan" di Reader saat mode B aktif, dan jangan menyebutnya akurat.

**Peningkatan opsional (hipotesis, belum teruji):** durasi tiap berkas ayat (didapat sekali dari mesin audio, di-cache) dapat dijumlahkan menjadi waktu mulai yang jauh lebih akurat untuk mode B, bila audio penuh sebanding dengan gabungan audio ayat. Itu perlu dibuktikan per qari sebelum dipakai.

### 4.3 Perilaku bersama

| Peristiwa | Reader |
|-----------|--------|
| `activeAyah` berubah | Ayat baru disorot, ayat lama dilepas; bila *auto-scroll* nyala, daftar menggulir sehingga ayat aktif berada di sepertiga atas layar dengan animasi ±250 ms |
| Pengguna menggulir manual | *Auto-scroll* ditangguhkan; tombol "Kembali ke ayat aktif" muncul; lanjut otomatis setelah pengguna menekannya |
| Pengguna mengetuk ayat | Pemutaran melompat ke ayat itu (mode A: pindah item; mode B: `seek(mulai(ayat))`) |
| Jeda | Sorotan tetap pada ayat terakhir |
| Pemutar berganti ke item lain (bukan surat ini) | Sorotan hilang; Reader tetap dapat dibaca |
| Reader dibuka untuk surat yang sedang diputar | Langsung menyorot ayat aktif dan menggulir ke sana |
| Reader dibuka untuk surat berbeda dari yang diputar | Tidak mengganggu pemutaran; tombol putar di Reader mengganti item |

### 4.4 Memilih mode

- Bawaan: **Mode A bila pengguna menekan putar dari Reader**, **Mode B bila memutar dari daftar/katalog/playlist** (agar memakai berkas penuh yang lebih mulus).
- Pengguna dapat berpindah di pengaturan pemutar "Sorot per ayat (lebih akurat)" ↔ "Audio penuh (lebih mulus)". Perpindahan mempertahankan ayat aktif (posisi dikonversi).

## 5. Aksi per ayat

Menu `⋯` dan ketuk lama pada ayat:

| Aksi | Perilaku |
|------|----------|
| Putar dari ayat ini | Sesuai §4.3 |
| Ulangi ayat / rentang | Set pengulangan ([05 §4](05-audio-player.md#4-perintah)) |
| Penanda (bookmark) | Simpan `surat:ayat` ke daftar lokal; ikon terisi |
| Tafsir | Lembar bawah berisi teks dari `/tafsir/{nomor}` untuk ayat itu; bila tidak ada entri untuk ayat itu, tampilkan "Tafsir tidak tersedia untuk ayat ini" |
| Salin | Menyalin teks Arab + terjemahan + rujukan "(QS Nama Surat: no)" |
| Bagikan | Lembar bagikan sistem dengan teks yang sama |

Catatan tafsir: pemetaan entri tafsir ke ayat (`ayat` bertipe string, kemungkinan rentang) **belum diperiksa**; lakukan sebelum mengimplementasikan lembar tafsir ([03 §2.5](03-api-integration.md#25-tafsir-per-surat)).

## 6. Kebenaran teks

Ini aturan paling ketat di seluruh proyek:

1. `teksArab` dan `teksIndonesia` ditampilkan **persis** seperti respons API. Tidak boleh di-`trim` di tengah, dinormalisasi, diganti karakternya, atau dipotong untuk "merapikan".
2. Pemformatan hanya boleh mengubah ukuran, jarak, warna, dan penyorotan.
3. Penanda akhir ayat (`۝`) dan angka adalah ornamen yang ditambahkan di luar teks, bukan di dalam string teks.
4. Basmalah header diambil dari data API (ayat 1 Al-Fatihah), tidak ditulis ulang di kode.
5. Uji: bandingkan teks yang dirender dengan teks respons (uji widget/golden) untuk Al-Fatihah, Al-Baqarah 1 dan 282, dan An-Nas.
6. Bila API gagal atau data tidak lengkap, tampilkan error; **jangan** menampilkan teks sebagian atau dari sumber lain tanpa penanda.
7. Perubahan font yang menyebabkan tanda baca hilang diperlakukan sebagai bug prioritas tinggi.

## 7. Penanda dan "lanjutkan"

- `HistoryRepository` menyimpan `{surat, ayat, waktu, mode}` terakhir. Dicatat saat jeda, saat meninggalkan Reader, dan tiap 10 detik pemutaran.
- Penanda bersifat lokal; model sederhana `{id, surat, ayat, catatan?, dibuat}`.

## 8. Kinerja Reader

| Aturan | Alasan |
|--------|--------|
| Daftar ayat memakai pembuat malas (`ListView.builder` / daftar dengan lompat ke indeks) | Al-Baqarah 286 ayat |
| Data surat diparse di isolate terpisah | Menghindari jank saat membuka surat panjang |
| Ketinggian ayat tidak diasumsikan tetap; lompat ke ayat memakai pustaka daftar dengan penjadwalan posisi | Ayat bervariasi dari satu baris sampai lebih dari layar |
| Sorotan ayat hanya membangun ulang kartu yang berubah (`select` atas `activeAyah`) | Sorotan tidak boleh membangun ulang 286 kartu |
| Penggulungan otomatis dianimasikan, tetapi lompatan jauh (≥ 20 ayat) tanpa animasi | Menghindari gulir panjang yang janggal |

## 9. Aksesibilitas Reader

- Teks Arab bertanda `Directionality` RTL dan bahasa `ar`; terjemahan `id` (agar pembaca layar memilih suara yang tepat).
- Skala teks sistem dihormati sampai 200 % tanpa teks terpotong.
- Sorotan memakai garis tepi dan latar, bukan warna saja; kontras teks ≥ 4,5 : 1.
- Pembaca layar mengumumkan "Ayat 5" ketika fokus berpindah; saat auto-scroll, pengumuman ayat aktif bersifat tidak mengganggu (tidak mengambil fokus).
- Tombol aksi ayat berukuran ≥ 48 dp.

## 10. Kriteria selesai (Fase 2)

1. Daftar surat 114 tampil dari API dalam satu permintaan dan bisa dicari.
2. Reader menampilkan teks Arab, transliterasi, terjemahan sesuai API untuk surat mana pun, termasuk Al-Baqarah tanpa jank berarti.
3. Basmalah muncul dan hilang sesuai aturan (surat 1: sebagai ayat; 2–114 kecuali 9: kepala; 9: tanpa).
4. Mode A: sorotan selalu tepat; mengetuk ayat memutar dari ayat itu.
5. Mode B: sorotan berjalan mulus dengan lencana "perkiraan"; kalibrasi diuji pada setidaknya 3 surat (pendek, sedang, panjang) dan 2 qari.
6. Teks yang dirender sama persis dengan respons API pada uji teks suci (§6).
7. Pengaturan ukuran huruf dan mode bertahan setelah aplikasi dibuka ulang.
