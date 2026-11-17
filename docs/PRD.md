Product Requirement Document (PRD)
Context
Proyek ini berfokus pada pengembangan antarmuka pengguna (UI/Frontend) untuk platform streaming audio Islami modern yang terinspirasi dari MuslyWave. Platform ini menyediakan antarmuka yang responsif dan intuitif untuk mendengarkan Al-Qur'an. Penggunaan API pihak ketiga (seperti equran.id) digunakan secara eksklusif untuk data Al-Qur'an (teks, terjemahan, dan pemetaan audio), sedangkan semua fitur lainnya (seperti manajemen pengguna, playlist, metadata katalog, dan rekomendasi) menggunakan data tiruan (mock/static data) untuk mendukung simulasi berbasis frontend saja. Arsitektur frontend dirancang untuk mendukung aplikasi mobile (iOS dan Android) serta web browser dengan performa tinggi dan efisiensi alur kerja pengembang.
Goals & Key Performance Indicators
Tujuan Utama: Mengembangkan antarmuka pengguna (UI/Frontend) streaming audio Islami yang intuitif, modern, dan responsif berorientasi mobile-first dengan simulasi data mock serta integrasi API Al-Qur'an.

Target KPI 1 (UI Loading Performance): Mencapai First Contentful Paint (FCP) < 1,2 detik dan Largest Contentful Paint (LCP) < 2 detik pada perangkat seluler.

Target KPI 2 (Mobile Responsiveness & Usability): Skor kelayakan antarmuka 100% pada pengujian responsivitas lintas ukuran layar (iOS/Android mobile & web browser).

Simulasi Pemutar Audio & UI Interaktif: Memastikan interaksi komponen pemutar audio (Player Bar, Mini Player, Fullscreen Player) berjalan lancar tanpa lag (60 fps animation).

Integrasi API Al-Qur'an Mulus: Menampilkan data Al-Qur'an (teks ayat, terjemahan, dan pemetaan audio qari dari equran.id) secara akurat dan responsif pada UI Reader.

Pemisahan Fokus Frontend-First: Mengisolasi seluruh fitur non-Qur'an (manajemen pengguna, rekomendasi, playlist, dan katalog metadata) menggunakan data mock statis tanpa ketergantungan pada API backend produksi.
Smart Offline Caching: Peningkatan efisiensi penyimpanan lokal untuk mendukung offline listening secara optimal.
Assumptions
Perangkat Pengguna: Mayoritas pengguna (sekitar 70-80%) mengakses platform melalui perangkat seluler (iOS & Android), sehingga desain mobile-first menjadi prioritas utama.
Konektivitas Internet: Pengguna membutuhkan koneksi internet yang stabil untuk streaming audio berkualitas tinggi, namun fitur caching/offline listening sangat penting untuk mengantisipasi jaringan yang tidak stabil.
Preferensi Konten: Pengguna menginginkan konten audio Islami yang terverifikasi halal dan bebas instrumen musik non-vokal (vocal-only/acapella) sesuai standar syariat.
Integrasi API Pihak Ketiga & Data Mock: API pihak ketiga (equran.id) digunakan khusus untuk mendukung data Al-Qur'an (teks ayat, terjemahan, dan audio qari), sementara seluruh fitur lain (seperti manajemen pengguna, playlist, metadata katalog, dan rekomendasi) bergantung pada data tiruan/statis untuk menjaga fokus utama pada pengembangan antarmuka (UI/Frontend).
Familiaritas Pengguna: Pengguna sudah terbiasa dengan alur antarmuka dan kontrol pemutar audio standar pada platform streaming spotify.
Dependencies
API Pihak Ketiga: https://equran.id/apidev/v2
Tasks
1. Core/Main Features (Prioritas Utama)
Fase 1: Implementasi UI/UX & Pemutar Audio Utama: Pengembangan komponen Antarmuka Pemutar Audio (Player Bar, Mini Player, Fullscreen Player) dan alur antarmuka dasar berorientasi mobile-first.

Fase 2: Tampilan Reader Al-Qur'an & Mock Sync Engine: Tampilan Reader Al-Qur'an (Layout Mushaf/Teks + Terjemahan per Ayat) beserta simulasi modul sinkronisasi teks real-time mengolah data tiruan (mock data).

Fase 3: Layout Katalog, Navigasi & Desain Komponen: Antarmuka Navigasi Katalog Qari/Nasheed/Adhkar/Podcast, tampilan sistem playlist kustom, serta layout pencarian dan filter berbasis mock/static data.

2. Secondary/Future Features (Fitur Pendukung/Sampingan)

Fase 4: Rekomendasi & Offline Caching UI: Antarmuka sistem rekomendasi cerdas berbasis kebiasaan pengguna serta opsi UI untuk penyimpanan/caching data offline.

Fase 5: QA, Pengujian Responsivitas UI & Perilisan: Pengujian performa antarmuka frontend, responsivitas berbagai ukuran layar, dan optimasi muat halaman (< 2 detik) sebelum persiapan perilisan aplikasi.

Team & Roles
Product Manager: Sahl
UI/UX Designer: Dzulqarnain Abu Muhmmad
Frontend Developer: Rahmat Arifin Susilo
QA Engineer: Ade Setiawan


