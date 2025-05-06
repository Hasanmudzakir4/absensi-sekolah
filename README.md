# 📚 Aplikasi Absensi Mahasiswa dan Dosen

Aplikasi Absensi Mahasiswa dan Dosen adalah solusi berbasis mobile yang dibangun menggunakan **Flutter** dan **Firebase**. Aplikasi ini memungkinkan mahasiswa dan dosen untuk melakukan proses absensi digital dengan mudah melalui pemindaian QR code, serta menyediakan fitur manajemen jadwal dan riwayat kehadiran secara real-time.

---

## 🚀 Fitur Utama

### 🔐 Autentikasi

- Mahasiswa dan Dosen dapat melakukan **registrasi** dan **login** menggunakan Firebase Authentication.

### 👤 Manajemen Profil

- Mahasiswa dan Dosen dapat **melengkapi** dan **mengubah** profil mereka (seperti nama lengkap, NIM/NIDN, kelas, jurusan, dll).

### 👨‍🏫 Fitur untuk Dosen

- **Kelola Jadwal Mengajar**: Tambah, ubah, dan hapus jadwal mengajar.
- **Generate QR Code**: Tampilkan QR code absensi untuk mahasiswa berdasarkan jadwal aktif.
- **Riwayat Kehadiran Mahasiswa**: Lihat semua kehadiran mahasiswa berdasarkan jadwal yang dibuat.

### 🧑‍🎓 Fitur untuk Mahasiswa

- **Scan QR Code**: Mahasiswa dapat memindai barcode dari dosen untuk melakukan absensi.
- **Lihat Jadwal Hari Ini**: Tampilkan jadwal berdasarkan hari dan semester saat ini.
- **Lihat Semua Jadwal**: Tampilkan semua jadwal aktif yang tersedia.
- **Riwayat Kehadiran**: Lihat daftar absensi yang telah dilakukan.

---

## 🛠 Teknologi yang Digunakan

- **Flutter**: Framework UI cross-platform untuk Android dan iOS.
- **Firebase Authentication**: Digunakan untuk sistem login dan registrasi pengguna.
- **Firebase Cloud Firestore**: Digunakan sebagai basis data utama.
- **Firebase Storage**: Untuk menyimpan gambar profil pengguna.

---

## 📷 Cuplikan Aplikasi

> Tambahkan tangkapan layar atau animasi GIF dari tampilan aplikasi seperti:
>
> - Halaman Login & Register
> - Halaman Scan QR
> - Daftar Jadwal
> - Riwayat Absensi

---

## 📦 Cara Menjalankan

1. Clone repository ini:

```bash
git clone https://github.com/Hasanmudzakir4/absensi-sekolah.git
```

2. Masuk ke folder project:

```bash
cd absensi
```

3. Install dependencies:

```bash
flutter pub get
```

4. Hubungkan dengan Firebase:

- Buat project baru di [Firebase Console](https://console.firebase.google.com/).
- Aktifkan Authentication (Email/Password) dan Cloud Firestore .
- Download google-services.json (Android).
- Tempatkan file konfigurasi tersebut pada direktori sesuai platform.

5. Jalankan aplikasi:

```bash
flutter run
```

## 📲 Unduh Aplikasi

Silakan unduh dan coba aplikasi melalui tautan berikut:

👉 [App Absensi](https://appdistribution.firebase.dev/i/1223f8745732d035)

© 2025 Aplikasi Absensi. Dibuat dengan ❤️ menggunakan Flutter dan Firebase.
