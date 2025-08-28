Penyelesaian Soal: It’s Called ‘Legacy Code’ for a Reason
Dokumen ini menjelaskan penyelesaian untuk soal "It’s Called ‘Legacy Code’ for a Reason" dari Seleksi Bagian B Laboratorium Sistem Terdistribusi 2025.

Nama: Naufarrelza Zhafif Abhista
NIM: (Silakan isi NIM Anda)

1. Keterangan Bonus yang Dikerjakan
Berikut adalah daftar bonus yang telah berhasil dikerjakan:

No.

Nama Bonus

Poin

Status

Keterangan

1

Konversi ke Indonesia Rupiah

2

✅ Selesai

Saldo akun kini ditampilkan dalam format Rupiah (IDR) dengan nilai tukar yang disarankan soal (1 Rai Stone ≈ Rp 120.000.000).

2

Deploy menggunakan Kubernetes

3

✅ Selesai

Aplikasi telah berhasil di-deploy ke cluster Kubernetes (k3s) yang berjalan di atas VPS DigitalOcean dan dapat diakses secara publik.

2. Penjelasan Cara Pengerjaan dan Menjalankan Proyek
Proyek ini terdiri dari sebuah backend COBOL yang diekspos melalui API menggunakan FastAPI (Python). Seluruh aplikasi ini di-container-isasi menggunakan Docker dan di-deploy ke cluster Kubernetes.

Alur Arsitektur (Disederhanakan)
Permintaan Pengguna: Pengguna mengakses http://[ALAMAT_IP_VPS]:30007.

Firewall: Firewall di VPS mengizinkan lalu lintas masuk pada port 30007.

Service (NodePort): Kubernetes menerima permintaan pada NodePort dan meneruskannya langsung ke Service cobol-banking-service.

Aplikasi: Service mengirimkan permintaan ke Pod aplikasi COBOL/FastAPI untuk diproses.

Respons: Hasil dari program COBOL dikembalikan melalui FastAPI ke pengguna.

Cara Menjalankan Proyek
A. Membangun dan Menjalankan Secara Lokal (Docker)
Prasyarat: Docker sudah terinstal di komputer.

Build Image Docker: Buka terminal di direktori proyek dan jalankan:

docker build -t cobol-app .

Jalankan Container:

docker run --rm -p 8000:8000 cobol-app

Akses Aplikasi: Buka browser dan akses http://127.0.0.1:8000.

B. Menjalankan di Lingkungan Produksi (Kubernetes)
Prasyarat:

Sebuah cluster Kubernetes (proyek ini menggunakan k3s di VPS).

kubectl sudah terkonfigurasi untuk terhubung ke cluster.

Image Docker sudah di-push ke sebuah registry (proyek ini menggunakan reletz/cobol-app:latest di Docker Hub).

Terapkan Manifest:
Hanya satu file yang dibutuhkan. Jalankan perintah berikut:

# Deploy aplikasi COBOL dan Service-nya
kubectl apply -f deployment.yaml

Akses Aplikasi: Aplikasi akan dapat diakses secara publik di http://[ALAMAT_IP_VPS]:30007.