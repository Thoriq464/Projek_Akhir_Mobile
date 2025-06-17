# 🎙️ Panduan Fitur Speech-to-Text

## Fitur yang Telah Diimplementasikan

### 1. Tombol Microphone
- **Hijau** 🟢: Siap merekam
- **Merah** 🔴: Sedang merekam
- **Lokasi**: Di sebelah kiri tombol kirim

### 2. Status Indicator
- **AppBar** menampilkan status "Mendengarkan..." saat recording
- **Hint text** berubah menjadi "Ketik atau tekan mic untuk berbicara..."

### 3. Pengaturan Speech Recognition
- **Bahasa**: Indonesian (id_ID)
- **Durasi Max**: 30 detik
- **Auto Stop**: 3 detik setelah diam
- **Real-time**: Text muncul langsung saat berbicara

## Cara Menggunakan

### Step 1: Buka Chatbot
```
1. Tap tombol "Chatbot Jawa" di halaman utama
2. Tunggu hingga permission microphone diminta
3. Allow/Izinkan akses microphone
```

### Step 2: Gunakan Speech-to-Text
```
1. Tap tombol microphone hijau 🟢
2. Tombol berubah merah 🔴 + status "Mendengarkan..."
3. Mulai berbicara dengan jelas
4. Text akan muncul real-time di input field
5. Tap tombol merah 🔴 untuk stop ATAU diam 3 detik
6. Edit text jika perlu, lalu tap tombol kirim
```

## Tips Penggunaan

### ✅ Do's:
- Berbicara dengan jelas dan tidak terlalu cepat
- Gunakan Bahasa Indonesia untuk hasil terbaik
- Test di lingkungan yang tidak terlalu bising
- Pastikan microphone device berfungsi normal

### ❌ Don'ts:
- Jangan berbicara terlalu pelan atau jauh dari mic
- Hindari background noise yang keras
- Jangan gunakan di emulator (gunakan device fisik)

## Troubleshooting

### Permission Denied
```
Solusi: 
1. Buka Settings > Apps > Kamus Jawa > Permissions
2. Enable "Microphone" permission
3. Restart aplikasi
```

### Speech Not Working
```
Solusi:
1. Check koneksi internet (dibutuhkan untuk speech recognition)
2. Test microphone di aplikasi lain
3. Restart device jika perlu
```

### Text Tidak Akurat
```
Solusi:
1. Berbicara lebih pelan dan jelas
2. Ulangi jika hasil tidak sesuai
3. Edit manual text yang dihasilkan
```

## Technical Details

### Dependencies
- `speech_to_text: ^7.0.0`
- `permission_handler: ^11.3.1`

### Permissions (Android)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### Kode Utama
```dart
// Inisialisasi
_speechToText.initialize()

// Mulai recording
_speechToText.listen(
  onResult: _onSpeechResult,
  localeId: 'id_ID',
  listenOptions: SpeechListenOptions(
    partialResults: true,
    cancelOnError: true,
    listenMode: ListenMode.confirmation,
  ),
)

// Stop recording
_speechToText.stop()
```

## Testing Checklist

- [ ] Permission microphone granted
- [ ] Tombol mic berubah warna saat tap
- [ ] Status "Mendengarkan..." muncul di AppBar
- [ ] Text muncul real-time saat berbicara
- [ ] Auto stop setelah 3 detik diam
- [ ] Manual stop dengan tap tombol merah
- [ ] Text bisa diedit setelah speech selesai
- [ ] Pesan bisa dikirim normal setelah speech

---
📝 **Note**: Fitur ini membutuhkan device Android fisik dan koneksi internet untuk hasil optimal.
