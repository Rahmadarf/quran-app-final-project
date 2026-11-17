# Quran App — Dokumentasi Proyek

Antarmuka (frontend) platform streaming audio Islami berorientasi mobile-first, terinspirasi dari MuslyWave. Pengguna mendengarkan Al-Qur'an dari berbagai qari, membaca teks Arab beserta terjemahan per ayat yang ikut tersorot saat audio berjalan, lalu menjelajah katalog qari, nasheed, adhkar, dan podcast, menyusun playlist, dan menyimpan audio untuk didengarkan tanpa internet.

Hanya **data Al-Qur'an** (teks, terjemahan, tafsir, audio qari) yang diambil dari API `equran.id`. Semua yang lain (pengguna, playlist, katalog, rekomendasi, status unduhan) memakai **data tiruan** di sisi aplikasi. Tidak ada backend buatan sendiri.

> Status: **perencanaan**. Repositori baru berisi template Flutter bawaan (`lib/main.dart`); belum ada kode aplikasi. Endpoint `equran.id` di [`03-api-integration.md`](03-api-integration.md) sudah dicoba langsung pada 17 Nov 2026 (hanya baca). Pemutaran audio, offline, dan pengukuran performa **belum diuji**.
>
> **Koreksi dari PRD:** PRD menulis dependensi `https://equran.id/apidev/v2`. Alamat itu mengembalikan halaman HTML 404. Alamat yang berfungsi adalah **`https://equran.id/api/v2`** (lihat [03](03-api-integration.md#1-alamat-dan-sifat-api)). `PRD.md` belum diubah; dokumen di folder ini memakai alamat yang benar.
>
> **Menyusul dari tim:** sumber audio untuk nasheed, adhkar, dan podcast (API hanya menyediakan audio Al-Qur'an), berkas desain Figma, dan target perangkat untuk pengukuran KPI. Daftar lengkap ada di [`01-overview.md`](01-overview.md#8-keputusan-yang-masih-terbuka).

## Daftar dokumen

| # | File | Isi | Dibaca oleh |
|---|------|-----|-------------|
| – | [`PRD.md`](PRD.md) | Dokumen kebutuhan produk asli (sumber dokumen lain) | Semua |
| 1 | [`01-overview.md`](01-overview.md) | Tujuan, KPI, ruang lingkup, persona, istilah, asumsi, keputusan terbuka | Semua |
| 2 | [`02-architecture.md`](02-architecture.md) | Stack Flutter, lapisan, alur data, state, struktur folder, penanganan error | Developer |
| 3 | [`03-api-integration.md`](03-api-integration.md) | Endpoint `equran.id` (sudah dicoba), model data, caching, pemetaan qari | Developer |
| 4 | [`04-mock-data.md`](04-mock-data.md) | Model dan isi data tiruan: pengguna, katalog, playlist, rekomendasi | Developer + desainer |
| 5 | [`05-audio-player.md`](05-audio-player.md) | Fase 1: Player Bar, Mini Player, Fullscreen Player, mesin status, antrean | Developer + desainer |
| 6 | [`06-quran-reader.md`](06-quran-reader.md) | Fase 2: layar Reader, mode tampilan, mesin sinkronisasi teks dan audio | Developer + desainer |
| 7 | [`07-ui-ux.md`](07-ui-ux.md) | Peta layar, navigasi, komponen, keadaan UI, breakpoint, aksesibilitas | Developer + desainer |
| 8 | [`08-catalog-playlist-offline.md`](08-catalog-playlist-offline.md) | Fase 3 dan 4: katalog, pencarian dan filter, playlist, rekomendasi, offline caching | Developer + desainer |
| 9 | [`09-roadmap-and-testing.md`](09-roadmap-and-testing.md) | Fase kerja, pembagian peran, pengukuran KPI, strategi uji, risiko | Semua |

## Ringkasan keputusan arsitektur

- **Framework:** Flutter (satu basis kode untuk iOS, Android, dan web). Proyek sudah dibuat dengan Flutter, SDK Dart `^3.13.5`.
- **Data Al-Qur'an dari `equran.id`, sisanya data tiruan.** Satu antarmuka repositori per sumber data; UI tidak tahu data datang dari jaringan atau dari berkas tiruan. Mengganti data tiruan dengan backend sungguhan nanti tidak mengubah layar.
- **Satu pemutar audio untuk seluruh aplikasi.** Player Bar, Mini Player, dan Fullscreen Player hanyalah tiga tampilan dari **satu** status pemutar yang sama.
- **Reader mengikuti audio.** Mode per ayat memakai berkas audio per ayat dari API, sehingga sinkronisasi nyata tanpa data waktu. Mode satu surat penuh memakai **waktu tiruan** (mock sync), sesuai PRD fase 2.
- **Offline = berkas audio dan teks tersimpan di perangkat**, dikelola antarmuka "Unduhan"; metadata unduhan disimpan lokal.
- **Tanpa akun sungguhan.** "Pengguna" adalah profil tiruan yang disimpan di perangkat.
- **Kinerja adalah fitur:** target FCP < 1,2 dtk, LCP < 2 dtk (web seluler), animasi 60 fps. Cara mengukurnya ada di [09](09-roadmap-and-testing.md#3-mengukur-kpi).

## Skala target

- Satu pengguna per perangkat, tanpa sinkronisasi antarperangkat.
- Katalog tiruan puluhan item; data Al-Qur'an nyata: 114 surat, 6.236 ayat, 6 qari.
- Risiko utama: **kelancaran audio dan UI**, **kinerja muat web**, dan **kebenaran teks Al-Qur'an yang ditampilkan**, bukan beban server.

## Konvensi dokumen

- Teks untuk pengguna memakai Bahasa Indonesia. Nama kelas, berkas, dan field memakai bahasa Inggris (`camelCase` untuk Dart, `snake_case` untuk nama berkas). Field mentah dari API (`namaLatin`, `teksArab`, dst.) ditulis apa adanya.
- Durasi dalam milidetik di kode (`Duration`), ditampilkan `mm:ss`.
- **"Diverifikasi"** berarti dicoba langsung terhadap API pada tanggal yang tertulis. **"Usulan"** berarti rancangan yang belum diputuskan tim atau belum dicoba.
- Blok kode di dokumen ini adalah **rancangan acuan**, bukan kode final.
- Teks Al-Qur'an ditampilkan **apa adanya dari API**. Aplikasi tidak boleh mengubah, memotong, atau menyusun ulang teks Arab (lihat [06](06-quran-reader.md#6-kebenaran-teks)).
