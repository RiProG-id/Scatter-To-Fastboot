# Scatter To Fastboot

Scatter To Fastboot adalah skrip shell sederhana yang mengonversi berkas scatter menjadi perintah fastboot untuk mem-flash perangkat Android.

## Cara Menggunakan

### Cara pertama

1. Unduh skrip Scatter To Fastboot.
2. Jalankan skrip dengan perintah berikut:

   ```bash
   sh scatter_to_fastboot.sh
   ```

3. Ikuti instruksi yang muncul di layar untuk memasukkan lokasi firmware Anda.
4. Tunggu hingga skrip selesai menjalankan.
5. Periksa direktori firmware Anda untuk melihat hasil keluaran.

### Cara One Command

Jalankan perintah berikut untuk langsung mengunduh dan menjalankan skrip:

```bash
curl https://raw.githubusercontent.com/RiProG-id/Scatter-To-Fastboot/main/scatter_to_fastboot.sh > x.sh; sh x.sh; rm -f x.sh
```

## Catatan Penting

- Pastikan Anda memiliki perangkat Android yang didukung dan driver fastboot yang diinstal sebelum menggunakan skrip ini.
- Perhatikan bahwa hasil konversi dapat bervariasi tergantung pada struktur berkas scatter Anda.

