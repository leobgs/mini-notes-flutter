# Mini Notes App

Aplikasi mobile sederhana dan modern untuk mencatat catatan harian, dibangun menggunakan **Flutter** dengan arsitektur yang bersih, responsif, dan performa tinggi menggunakan penyimpanan lokal **Hive CE**.

---

## Fitur Utama

- **Halaman List Catatan yang Efisien:** Menggunakan `ListView.builder` untuk merender catatan secara efisien (judul tebal, preview isi 2 baris, tanggal update terakhir, dan badge total catatan).
- **Pencarian Realtime:** Filter catatan secara instan berdasarkan judul atau isi catatan.
- **Penyimpanan Lokal Cepat (Offline-First):** Data disimpan secara lokal di perangkat menggunakan **Hive CE** (Community Edition yang aktif dirawat), menjamin akses cepat tanpa jeda jaringan.
- **Operasi CRUD Lengkap:**
  - **Tambah Catatan:** Membuat catatan baru dengan UUID unik.
  - **Edit Catatan:** Memperbarui judul dan isi catatan yang sudah ada.
  - **Hapus Catatan:** Menghapus catatan dengan dialog konfirmasi keamanan (tersedia di card list maupun di dalam layar edit).
- **Form Input & Validasi:**
  - Validasi form wajib: Judul catatan tidak boleh kosong.
  - Konfirmasi _Unsaved Changes_: Dialog peringatan jika pengguna mencoba keluar tanpa menyimpan perubahan.
- **Navigasi Mulus:** Berpindah antar layar secara intuitif menggunakan standard Flutter imperative Navigator (`push` dan `pop`).
- **UI Responsif & Material 3:**
  - Mendukung tampilan notch, status bar, dan navigation bar di iOS maupun Android secara proporsional berkat implementasi `SafeArea`.
  - Desain tema modern berbasis Material 3 dengan warna primer Indigo dan kartu bertepi halus (_clean card elevation_).

---

## 📂 Struktur Proyek

```text
lib/
├── main.dart                      # Entry point, inisialisasi Hive, System UI & MaterialApp
├── models/
│   └── note.dart                  # Model data Note & Hive TypeAdapter (NoteAdapter)
├── services/
│   └── note_service.dart          # Data access layer / CRUD service (Hive box & listenable)
├── screens/
│   ├── note_list_screen.dart      # Halaman utama daftar catatan (ListView.builder & search)
│   └── note_form_screen.dart      # Halaman tambah & edit catatan beserta validasi form
└── theme/
    └── app_theme.dart             # Konfigurasi tema Material 3 (warna, tipografi, card, button)
test/
├── note_test.dart                 # Unit & widget tests (Model Note, Hive Box CRUD, Form Validation)
└── widget_test.dart               # Smoke test integritas data
```

---

## Cara Menjalankan Proyek

### 1. Prasyarat

Pastikan Flutter SDK dan simulator/perangkat fisik Anda telah terpasang:

```bash
flutter doctor
```

### 2. Mengunduh Dependensi

Di folder proyek, jalankan:

```bash
flutter pub get
```

### 3. Menjalankan Aplikasi

- **Menjalankan di perangkat yang aktif / default:**

  ```bash
  flutter run
  ```

- **Menjalankan di iOS Simulator:**

  ```bash
  open -a Simulator
  flutter run
  ```

- **Menjalankan di Android Emulator:**
  ```bash
  flutter emulators --launch Medium_Phone
  flutter run -d emulator-5554
  ```

---

## Menjalankan Pengujian (Testing)

Proyek ini telah dilengkapi dengan pengujian automated untuk memastikan kehandalan data dan antarmuka pengguna:

- **Jalankan unit & widget test:**

  ```bash
  flutter test
  ```

- **Jalankan linter / static code analysis:**
  ```bash
  flutter analyze
  ```
