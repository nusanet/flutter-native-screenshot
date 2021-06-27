# Flutter Native Screenshot

Plugin ini berfungsi untuk mengambil screenshot dari layar device yang sedang aktif dengan cara menggunakan kode native-nya langsung.
Untuk saat ini support untuk platform Android & iOS.

## Cara Instalasi

Buka file **pubspec.yaml** dan tambahkan baris kode berikut didalam `dependencies`.

```
flutter_native_screenshot: ^<versi_terbaru>
```

*Catatan: Harap ganti tulisan <versi_terbaru> dengan nilai versi terbaru dari plugin ini.*

### Android

Untuk platform Android, Anda harus menambahkan permission berikut kedalam file **AndroidManifest.xml**.

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Dan jangan lupa tambahkan property berikut kedalam tag `application` didalam file **AndroidManifest.xml**.

```
android;requestLegacyExternalStorage="true"
```

### iOS

Untuk platform iOS, Anda harus menambahkan permission berikut kedalam file **Info.plist**.

```
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Take pretty screenshots and save it to the PhotoLibrary.</string>
```

### Contoh Pemakaian

Untuk contoh pemakaian silakan lihat didalam projek **example** ya.

### Catatan Penting

Perlu diketahui bahwa di plugin ini tidak meng-handle proses pengecekan runtime permission.
Oleh karena itu, pastikan Anda mengecek terlebih dahulu runtime permission-nya menggunakan plugin `permission_handler`.