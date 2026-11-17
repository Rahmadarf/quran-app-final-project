# 01 — Ringkasan Proyek

## 1. Tujuan

Membangun antarmuka platform streaming audio Islami yang:

1. **Nyaman didengar.** Pemutar audio meniru alur yang sudah dikenal dari Spotify: bilah pemutar di bawah, mini player yang bisa diperbesar, dan pemutar layar penuh.
2. **Nyaman dibaca.** Reader menampilkan teks Arab, transliterasi, dan terjemahan Indonesia per ayat, dan ayat yang sedang dibacakan tersorot dan ikut tergulir.
3. **Mudah dijelajahi.** Katalog qari, nasheed, adhkar, dan podcast, lengkap dengan pencarian, filter, dan playlist buatan sendiri.
4. **Tetap bisa dipakai saat sinyal buruk.** Pengguna bisa menyimpan audio dan teks untuk didengarkan tanpa internet.

Proyek ini **hanya frontend**. Hasil akhir yang diharapkan: aplikasi yang dapat didemokan penuh di ponsel dan browser, dengan data Al-Qur'an yang nyata dan sisanya data tiruan yang rapi, sehingga backend sungguhan dapat dipasang belakangan tanpa menulis ulang layar.

## 2. Indikator keberhasilan (KPI)

Dikutip dari PRD, dengan cara ukur yang diusulkan. Cara ukur lengkap ada di [09](09-roadmap-and-testing.md#3-mengukur-kpi).

| # | KPI | Target | Cara ukur (usulan) |
|---|-----|--------|--------------------|
| 1 | Kecepatan muat UI | FCP < 1,2 dtk dan LCP < 2 dtk di perangkat seluler | Lighthouse pada build web rilis, profil jaringan "Slow 4G" dan CPU 4× lebih lambat |
| 2 | Responsivitas dan kegunaan | 100 % lolos daftar uji lintas ukuran layar (iOS, Android, browser) | Matriks perangkat × layar di [09 §4.3](09-roadmap-and-testing.md#43-matriks-responsivitas) |
| 3 | Kelancaran komponen pemutar | Animasi 60 fps pada Player Bar, Mini Player, Fullscreen Player | Flutter DevTools (Performance overlay) pada perangkat nyata, mode profile |
| 4 | Integrasi API Al-Qur'an | Teks, terjemahan, dan audio qari tampil akurat | Uji kecocokan dengan respons API (jumlah ayat, urutan, tautan audio) |
| 5 | Pemisahan frontend-first | Semua fitur non-Qur'an berjalan dari data tiruan, tanpa panggilan ke backend lain | Periksa lalu lintas jaringan: satu-satunya host adalah `equran.id` dan `cdn.equran.id` |
| 6 | Smart offline caching | Audio dan teks yang disimpan bisa diputar dan dibaca tanpa jaringan | Mode pesawat: buka Unduhan, putar, baca |

> **Catatan KPI 1.** FCP dan LCP adalah metrik web. Pada build iOS dan Android, padanannya adalah *waktu sampai layar beranda interaktif* (cold start). Tim perlu memutuskan angkanya untuk aplikasi native; PRD belum menyebut. Lihat keputusan terbuka #6.

## 3. Prinsip desain

- **Satu sumber kebenaran untuk pemutar.** Apa pun yang berbunyi, yang menjadi acuan adalah satu objek status pemutar. Tidak ada layar yang menyimpan salinan status "sedang memutar" sendiri.
- **Teks suci tidak diubah.** Teks Arab dan terjemahan ditampilkan sesuai respons API. Pemformatan hanya boleh mengubah ukuran, jarak, dan warna.
- **Antarmuka repositori memisahkan sumber data.** Layar meminta data ke repositori; repositori yang memutuskan memakai API, data tiruan, atau cache.
- **Selalu ada jalan keluar.** Tiap layar punya keadaan memuat, kosong, dan gagal dengan tombol coba lagi. Jaringan putus tidak boleh membuat layar putih.
- **Mobile-first, tidak mobile-only.** Rancang untuk ponsel dulu, lalu pastikan tablet dan layar browser lebar tetap rapi.
- **Terinspirasi cara kerja, bukan salinan.** Proyek ini tidak memakai nama, logo, aset visual, atau teks dari MuslyWave maupun Spotify. Identitas visual dibuat sendiri oleh desainer.

## 4. Ruang lingkup

### Termasuk (versi 1)

| Area | Fitur | Fase |
|------|-------|------|
| Pemutar | Player Bar, Mini Player, Fullscreen Player, antrean, putar/jeda, maju/mundur, acak, ulang, kecepatan, timer tidur | 1 |
| Reader | Daftar surat, tampilan teks Arab + transliterasi + terjemahan per ayat, sorotan ayat saat audio berjalan, pilih qari, tafsir ringkas | 2 |
| Sinkronisasi | Mode per ayat (nyata) dan mode surat penuh (waktu tiruan) | 2 |
| Katalog | Qari, Nasheed, Adhkar, Podcast; halaman detail; pencarian dan filter | 3 |
| Playlist | Buat, ubah nama, tambah/hapus item, urutkan, hapus; data lokal | 3 |
| Rekomendasi | "Untuk kamu", "Lanjutkan mendengarkan", "Sering diputar", berdasarkan riwayat tiruan dan lokal | 4 |
| Offline | Unduh surat atau item, kelola penyimpanan, putar tanpa jaringan, pengaturan penyimpanan | 4 |
| Kualitas | Uji performa, responsivitas, aksesibilitas | 5 |

### Tidak termasuk (versi 1)

- Backend, basis data server, atau API buatan sendiri.
- Akun sungguhan, pendaftaran, masuk dengan Google/Apple, dan sinkronisasi antarperangkat.
- Pembayaran dan langganan.
- Unggah konten oleh pengguna.
- Pengenalan suara atau pencocokan bacaan pengguna.
- Waktu salat, arah kiblat, dan fitur ibadah lain di luar mendengarkan dan membaca.
- Terjemahan selain Bahasa Indonesia (API hanya menyediakan itu).

## 5. Persona dan peran

PRD tidak membedakan peran pengguna; tidak ada peran admin. Persona berikut hanya untuk memandu desain.

| Persona | Kebutuhan | Fitur yang paling penting |
|---------|-----------|---------------------------|
| **Pendengar harian** | Memutar surat favorit sambil bekerja, tanpa repot | Mini Player, lanjutkan mendengarkan, timer tidur |
| **Pembaca-pendengar** | Mengikuti bacaan sambil melihat teks dan arti | Reader dengan sorotan ayat, ukuran huruf Arab |
| **Penghafal** | Mengulang satu ayat atau rentang ayat | Ulangi ayat, kecepatan, pilih qari |
| **Pengguna jaringan lemah** | Mendengar di perjalanan atau tempat sinyal buruk | Unduhan, pemutaran offline, indikator jaringan |
| **Penjelajah** | Mencari bacaan atau nasheed baru | Katalog, pencarian, rekomendasi |

Status pengguna di aplikasi hanya dua: **tamu** (bawaan, tanpa profil) dan **profil tiruan** (dipilih dari data tiruan untuk demo rekomendasi dan playlist). Lihat [04](04-mock-data.md#2-pengguna).

## 6. Alur pengguna singkat

1. **Buka aplikasi.** Layar Beranda: "Lanjutkan mendengarkan", rekomendasi, jalan pintas ke surat populer.
2. **Pilih bacaan.** Dari Beranda, Katalog, atau Pencarian: pengguna membuka surat atau item, lalu menekan putar.
3. **Mendengar.** Player Bar muncul di bawah. Ketuk untuk membuka Mini Player lalu Fullscreen Player; pemutaran tidak terputus saat berpindah layar.
4. **Membaca.** Dari pemutar atau daftar surat, pengguna membuka Reader. Ayat yang dibacakan tersorot dan layar ikut tergulir; mengetuk ayat melompatkan audio ke ayat itu.
5. **Mengatur.** Menambah ke playlist, mengunduh untuk offline, memilih qari lain.
6. **Tanpa jaringan.** Banner "Offline" muncul; hanya konten terunduh yang aktif, yang lain redup dengan keterangan.

## 7. Istilah

| Istilah | Arti |
|---------|------|
| Qari | Pembaca Al-Qur'an. API menyediakan 6 qari (kode `01`–`06`) |
| Surat | Satu dari 114 bagian Al-Qur'an (`nomor` 1–114) |
| Ayat | Satu kalimat/penggalan dalam surat; total 6.236 |
| Audio penuh (`audioFull`) | Satu berkas MP3 untuk satu surat utuh per qari |
| Audio per ayat (`audio` di tiap ayat) | Satu berkas MP3 per ayat per qari |
| Player Bar | Bilah pemutar tetap di bawah layar: judul, putar/jeda, progres tipis |
| Mini Player | Pemutar ringkas yang bisa diperbesar dari Player Bar (artwork, kontrol utama) |
| Fullscreen Player | Pemutar layar penuh: artwork besar, bilah geser, semua kontrol, antrean |
| Reader | Layar baca ayat per ayat |
| Sync engine | Modul yang menentukan ayat mana yang sedang dibacakan dari posisi audio |
| Mock sync | Waktu ayat tiruan yang dihitung dari panjang teks untuk audio surat penuh |
| Data tiruan (mock) | Data statis di aplikasi yang meniru bentuk data backend |
| Repositori | Kelas yang menyembunyikan asal data (API, tiruan, cache) dari UI |
| Offline caching | Menyimpan berkas audio dan teks di perangkat agar tersedia tanpa jaringan |
| Vocal-only | Konten tanpa alat musik non-vokal (a cappella), sesuai asumsi PRD |

## 8. Keputusan yang masih terbuka

Nilai bawaan dipakai bila belum diputuskan.

| # | Pertanyaan | Bawaan yang diusulkan |
|---|------------|-----------------------|
| 1 | Sumber audio nasheed, adhkar, dan podcast. API hanya menyediakan audio Al-Qur'an | Berkas contoh kecil yang dibundel di aplikasi (lisensi bebas, diberi atribusi). Alternatif: pemutaran disimulasikan tanpa suara |
| 2 | Manajemen status (state management) | Riverpod (usulan; belum diputuskan oleh developer) |
| 3 | Penyimpanan lokal | `shared_preferences` untuk pengaturan, basis data ringan (Drift atau Hive) untuk playlist, riwayat, dan unduhan |
| 4 | Platform prioritas untuk demo akhir | Android + web; iOS bila ada perangkat/Mac untuk uji |
| 5 | Qari bawaan | `05` Misyari Rasyid Al-Afasi (ada di respons API; hanya usulan, tim yang memutuskan) |
| 6 | Padanan KPI 1 untuk aplikasi native | Cold start sampai Beranda tampil < 2 dtk di perangkat kelas menengah |
| 7 | Bahasa antarmuka | Hanya Bahasa Indonesia (versi 1) |
| 8 | Tema | Terang dan gelap mengikuti sistem; palet dari desainer |
| 9 | Berkas desain (Figma) dan token desain | Menyusul dari UI/UX Designer; sampai ada, [07](07-ui-ux.md) menjadi acuan struktur |
| 10 | Apakah tafsir ditampilkan | Ya, sebagai lembar bawah per ayat (data ada di endpoint tafsir; lihat [03](03-api-integration.md#25-tafsir-per-surat)) |
| 11 | Apa arti "terverifikasi halal" di UI | Hanya lencana pada data tiruan (`isVocalOnly`, `verifiedBy`); tidak ada proses verifikasi nyata |
| 12 | Penggunaan merek MuslyWave sebagai acuan | Hanya sebagai inspirasi alur; tidak ada aset atau nama yang disalin |

## 9. Asumsi dan batasan

- **Mayoritas pengguna di ponsel (70–80 %)** sehingga ponsel adalah ukuran rancang utama (PRD).
- **Streaming butuh jaringan stabil;** offline adalah jaring pengaman, bukan mode utama.
- **Pengguna menginginkan konten vocal-only** (PRD). Karena API Al-Qur'an hanya memuat bacaan qari tanpa musik, ini terpenuhi untuk Al-Qur'an; untuk nasheed tiruan, atributnya hanya penanda.
- **Pengguna sudah terbiasa dengan alur pemutar Spotify** (PRD), sehingga pola kontrol standar dipakai dan tidak diinovasi.
- **`equran.id` adalah layanan pihak ketiga.** Tidak ada jaminan ketersediaan; aplikasi harus tetap berguna bila API gagal (cache, pesan jelas). Syarat penggunaan dan atribusi perlu diperiksa sebelum rilis publik (lihat risiko #4 di [09](09-roadmap-and-testing.md#5-register-risiko)).
- Respons API **belum diketahui kuota atau pembatasannya.** Tidak ada kunci API yang dipakai pada percobaan 17 Nov 2026.
- Tim empat orang; developer frontend tunggal. Cakupan harus dijaga sesuai itu.

## 10. Tim

| Peran | Nama | Fokus dokumen |
|-------|------|---------------|
| Product Manager | Sahl | Ruang lingkup, prioritas, keputusan terbuka |
| UI/UX Designer | Dzulqarnain Abu Muhmmad | [07](07-ui-ux.md), [05](05-audio-player.md) dan [06](06-quran-reader.md) (sisi visual) |
| Frontend Developer | Rahmat Arifin Susilo | [02](02-architecture.md), [03](03-api-integration.md), [04](04-mock-data.md), semua implementasi |
| QA Engineer | Ade Setiawan | [09](09-roadmap-and-testing.md) |
