# PRD — Personal Expense Tracker

## 1. Product Overview

**Nama sementara:** `Spendly`  
**Tipe:** Personal Finance / Expense Tracking  
**Target platform:** Web/Mobile  
**Target pengguna:** Individu yang ingin mencatat dan memahami pengeluaran bulanannya.

### Problem

Banyak orang mengetahui jumlah uang yang dimiliki, tetapi tidak mengetahui dengan jelas:

- Uang paling banyak digunakan untuk apa.
- Berapa total pengeluaran setiap bulan.
- Apakah pengeluaran bulan ini lebih besar dari bulan sebelumnya.
- Kategori apa yang paling banyak menghabiskan uang.
- Apakah pengeluaran sudah melebihi budget yang ditentukan.

Pencatatan manual menggunakan Excel atau catatan HP juga sering terasa merepotkan.

### Solution

Aplikasi memungkinkan pengguna:

1. Mencatat pengeluaran dengan cepat.
2. Mengelompokkan pengeluaran berdasarkan kategori.
3. Melihat ringkasan pengeluaran bulanan.
4. Melihat grafik pengeluaran.
5. Membandingkan pengeluaran antarbulan.
6. Menentukan budget bulanan.
7. Melihat apakah pengeluaran masih dalam batas budget.

---

## 2. Product Goal

### Primary Goal

> Membantu pengguna mengetahui **ke mana uang mereka pergi** dan mengontrol pengeluaran bulanannya.

### Success Metrics

| Metric | Target |
|---|---:|
| User berhasil membuat transaksi | >90% |
| Waktu mencatat transaksi | <30 detik |
| User membuka dashboard | ≥3x/bulan |
| User mencatat transaksi | ≥10 transaksi/bulan |
| User melihat laporan bulanan | ≥1x/bulan |

---

## 3. Target User

### Persona

**Nama:** Andi  
**Umur:** 20–35 tahun  
**Pekerjaan:** Karyawan / mahasiswa / freelancer

Andi biasanya mempunyai penghasilan bulanan tetap, tetapi sering tidak sadar bahwa pengeluaran kecil seperti:

- Makan
- Kopi
- Transportasi
- Belanja online
- Subscription
- Nongkrong

jika dijumlahkan menjadi cukup besar.

Andi ingin aplikasi yang:

> **"Buka → masukkan pengeluaran → selesai."**

Bukan aplikasi accounting yang rumit.

---

## 4. Core Features

## 4.1 Dashboard

Dashboard menjadi halaman utama.

Dashboard menampilkan:

- Total pengeluaran bulan berjalan
- Budget bulan berjalan
- Sisa budget
- Persentase budget terpakai
- Grafik pengeluaran bulanan
- Grafik berdasarkan kategori
- Transaksi terbaru

Contoh struktur:

```text
┌─────────────────────────────────────┐
│ October 2026                    ▼   │
├─────────────────────────────────────┤
│                                     │
│ Total Pengeluaran                   │
│ Rp 4.250.000                        │
│                                     │
│ Budget                              │
│ Rp 5.000.000                        │
│                                     │
│ Sisa Budget                         │
│ Rp 750.000                          │
├─────────────────────────────────────┤
│                                     │
│ Pengeluaran Bulan Ini               │
│                                     │
│        █                             │
│        █                             │
│   █    █                            │
│   █    █    █                       │
│   █    █    █    █                  │
│ ─────────────────────────           │
│ Jul Aug Sep Oct                     │
│                                     │
├─────────────────────────────────────┤
│ Pengeluaran berdasarkan kategori    │
│                                     │
│ Makan        Rp 1.500.000   35%     │
│ Transport    Rp   700.000   16%     │
│ Belanja      Rp   600.000   14%     │
│ Tagihan      Rp   500.000   12%     │
└─────────────────────────────────────┘
```

---

## 4.2 Tambah Pengeluaran

Form pengeluaran harus dibuat sesederhana mungkin.

```text
Tambah Pengeluaran

Nominal
Rp 50.000

Kategori
[Makanan ▼]

Tanggal
08 Oktober 2026

Catatan
Makan siang

[ SIMPAN ]
```

### Field

| Field | Required | Type |
|---|---|---|
| Amount | ✅ | Decimal |
| Category | ✅ | Category |
| Date | ✅ | Date |
| Note | ❌ | Text |
| Payment Method | ❌ | Enum |

Payment method dapat ditunda untuk MVP jika ingin menyederhanakan aplikasi.

Pilihan payment method:

- Cash
- Bank Transfer
- Debit Card
- Credit Card
- E-Wallet

---

## 4.3 Expense Categories

Default category:

### Living

- 🍚 Makanan
- 🏠 Rumah
- 🚗 Transportasi
- 💡 Tagihan
- 🛒 Belanja

### Lifestyle

- ☕ Nongkrong
- 🎮 Entertainment
- ✈️ Travel
- 📱 Subscription

### Financial

- 💰 Investasi
- 💳 Cicilan
- 🏦 Tabungan

### Others

- 📦 Lainnya

User juga dapat menambahkan kategori sendiri.

Contoh:

```text
+ Tambah Kategori

Nama:
Gym

Icon:
🏋️

[ SIMPAN ]
```

---

## 4.4 Transaction History

Halaman untuk melihat seluruh transaksi.

```text
Pengeluaran

[🔍 Search]

08 Oct 2026

🍜 Makanan
Makan siang
Rp 35.000

☕ Nongkrong
Kopi
Rp 25.000


07 Oct 2026

🚗 Transportasi
Gojek
Rp 18.000
```

### Filter

- Bulan
- Kategori
- Date range
- Nominal

### Sorting

- Terbaru
- Terlama
- Nominal terbesar
- Nominal terkecil

---

## 4.5 Monthly Report

Monthly Report menjadi salah satu **core feature** aplikasi.

User dapat memilih bulan:

```text
< September 2026 >
```

Kemudian aplikasi memberikan summary.

### Summary

```text
Total Pengeluaran

Rp 4.850.000

+8.5%
dibanding bulan sebelumnya
```

### Category Breakdown

```text
Makanan       Rp 1.500.000
Transportasi  Rp   800.000
Belanja       Rp   700.000
Tagihan       Rp   600.000
Hiburan       Rp   400.000
Lainnya       Rp   850.000
```

Visualisasinya dapat menggunakan pie/donut chart.

---

## 4.6 Monthly Comparison

User dapat membandingkan pengeluaran dari bulan ke bulan.

Informasi yang dapat ditampilkan:

- Pengeluaran naik/turun
- Bulan paling boros
- Bulan paling hemat
- Rata-rata pengeluaran
- Perubahan persentase dibanding bulan sebelumnya

Contoh:

```text
May  2026  Rp 4.200.000
Jun  2026  Rp 4.600.000
Jul  2026  Rp 3.900.000
Aug  2026  Rp 5.100.000
Sep  2026  Rp 4.700.000
Oct  2026  Rp 4.250.000
```

---

## 4.7 Budget Management

User dapat menentukan budget bulanan.

```text
Budget Bulanan

October 2026

Total Budget
Rp 5.000.000

Terpakai
Rp 4.250.000

Sisa
Rp 750.000
```

### Budget Status

#### 🟢 Aman

Penggunaan budget < 70%.

#### 🟡 Waspada

Penggunaan budget 70–90%.

#### 🔴 Melebihi Budget

Penggunaan budget > 100%.

---

## 4.8 Category Budget

Versi lanjutan memungkinkan user menentukan budget per kategori.

```text
Budget October

Makanan
Rp 1.500.000 / Rp 2.000.000
██████████████░░

Transportasi
Rp 700.000 / Rp 800.000
█████████████████

Hiburan
Rp 650.000 / Rp 500.000
████████████████████ 🔴
```

Tujuan fitur ini adalah membantu user mengetahui kategori mana yang menyebabkan overspending.

---

## 4.9 Insights

Fitur untuk memberikan informasi otomatis berdasarkan data transaksi.

Contoh:

> 💡 **Insight**
>
> Pengeluaran makanan bulan ini mencapai **Rp1.500.000**, naik **18%** dibanding bulan lalu.

Contoh lainnya:

> 💡 Pengeluaran transportasi merupakan **kategori terbesar kedua** bulan ini.

Atau:

> ⚠️ Kamu telah menggunakan **92% budget hiburan**, padahal bulan masih tersisa 8 hari.

Untuk MVP, insight dapat menggunakan rule sederhana tanpa AI.

---

## 4.10 Recurring Expense

Fitur tahap berikutnya untuk pengeluaran rutin.

Contoh:

```text
Netflix
Rp 186.000
Setiap tanggal 15

Internet
Rp 350.000
Setiap tanggal 5

Kos
Rp 1.500.000
Setiap tanggal 1
```

Aplikasi dapat membuat transaksi secara otomatis sesuai jadwal.

---

## 4.11 Search & Filter

User dapat mencari transaksi.

Contoh:

```text
"Indomaret"
```

Hasil:

```text
05 Oct   Indomaret    Rp 125.000
20 Sep   Indomaret    Rp  75.000
12 Sep   Indomaret    Rp  50.000
```

Filter:

- Date
- Category
- Amount
- Payment method

---

# 5. Data Model

Untuk MVP, struktur database dapat dibuat sederhana.

## users

```text
id
name
email
password
created_at
updated_at
```

## categories

```text
id
user_id
name
icon
type
created_at
updated_at
```

`type`:

```text
expense
income
```

## transactions

```text
id
user_id
category_id
amount
transaction_date
note
payment_method
created_at
updated_at
```

## budgets

```text
id
user_id
month
year
amount
created_at
updated_at
```

## category_budgets

```text
id
user_id
category_id
month
year
amount
```

---

# 6. Navigation

Navigation dibuat sederhana.

```text
Dashboard
    │
    ├── Add Expense
    │
    ├── Transactions
    │
    ├── Reports
    │
    └── Settings
```

Untuk mobile:

```text
┌─────────────────────────────────────┐
│                                     │
│            Application              │
│                                     │
├─────────────────────────────────────┤
│                                     │
│   🏠        📋       ＋       📊    │
│ Home      History    Add     Report │
└─────────────────────────────────────┘
```

Tombol `+` menjadi action utama karena pencatatan pengeluaran adalah aktivitas paling penting.

---

# 7. User Flow

## Flow Mencatat Pengeluaran

```text
Dashboard
   ↓
Press "+"
   ↓
Input nominal
   ↓
Pilih kategori
   ↓
Pilih tanggal
   ↓
Tambahkan catatan (optional)
   ↓
Simpan
   ↓
Dashboard diperbarui
```

### Target

Pengguna dapat mencatat pengeluaran dalam:

> **< 30 detik**

Form harus dibuat sesingkat mungkin.

---

# 8. Functional Requirements

## FR-001 — Create Expense

User harus dapat membuat transaksi pengeluaran.

## FR-002 — Edit Expense

User dapat mengubah transaksi yang sudah dibuat.

## FR-003 — Delete Expense

User dapat menghapus transaksi.

## FR-004 — Monthly Summary

Sistem menghitung total pengeluaran berdasarkan bulan yang dipilih.

Secara konsep:

```sql
SUM(transactions.amount)
WHERE month = selected_month
```

## FR-005 — Category Summary

Sistem mengelompokkan pengeluaran berdasarkan kategori.

```sql
SUM(amount)
GROUP BY category
```

## FR-006 — Budget Calculation

```text
remaining_budget =
monthly_budget - total_expense
```

## FR-007 — Budget Percentage

```text
budget_usage =
(total_expense / monthly_budget) × 100
```

## FR-008 — Monthly Comparison

Sistem membandingkan:

```text
current_month
vs
previous_month
```

---

# 9. Non-Functional Requirements

## Performance

Dashboard harus dapat tampil dalam:

> **< 2 detik**

untuk dataset normal.

## Security

- Password harus di-hash.
- User hanya dapat melihat transaksi miliknya sendiri.
- API menggunakan authentication.
- Validasi input nominal.
- SQL injection prevention.
- Authorization harus diterapkan pada setiap resource milik user.

## Usability

Mencatat pengeluaran harus dapat dilakukan dalam:

> **< 30 detik**

---

# 10. MVP Scope

Jangan langsung membuat semua fitur.

## Phase 1 — MVP

### Critical

- [ ] Register/Login
- [ ] Dashboard
- [ ] Tambah pengeluaran
- [ ] Edit pengeluaran
- [ ] Delete pengeluaran
- [ ] Kategori
- [ ] Riwayat transaksi
- [ ] Filter bulan
- [ ] Total pengeluaran
- [ ] Grafik pengeluaran bulanan
- [ ] Grafik kategori
- [ ] Budget bulanan

## Phase 2

### High Priority

- [ ] Budget per kategori
- [ ] Recurring expense
- [ ] Payment method
- [ ] Export Excel/CSV
- [ ] Import transaksi
- [ ] Custom category
- [ ] Monthly comparison
- [ ] Spending insights

## Phase 3

### Future

- [ ] Income tracking
- [ ] Saving goal
- [ ] Investment tracking
- [ ] Debt tracking
- [ ] AI financial insight
- [ ] Notification
- [ ] Multi-device sync

---

# 11. Feature Priority

| Feature | Priority |
|---|---|
| Add Expense | 🔴 Critical |
| Transaction History | 🔴 Critical |
| Dashboard | 🔴 Critical |
| Monthly Summary | 🔴 Critical |
| Category | 🔴 Critical |
| Monthly Chart | 🔴 Critical |
| Budget | 🟠 High |
| Category Budget | 🟠 High |
| Monthly Comparison | 🟠 High |
| Search | 🟡 Medium |
| Recurring Expense | 🟡 Medium |
| Export | 🟡 Medium |
| Income | 🟢 Later |
| Investment | 🟢 Later |
| AI Insight | 🟢 Later |

---

# 12. API Design

Jika menggunakan REST API:

```text
POST   /api/auth/register
POST   /api/auth/login

GET    /api/dashboard

GET    /api/transactions
POST   /api/transactions
GET    /api/transactions/{id}
PUT    /api/transactions/{id}
DELETE /api/transactions/{id}

GET    /api/categories
POST   /api/categories
PUT    /api/categories/{id}
DELETE /api/categories/{id}

GET    /api/budgets
POST   /api/budgets
PUT    /api/budgets/{id}

GET    /api/reports/monthly
GET    /api/reports/category
```

---

# 13. Recommended Technology Stack

Melihat kebutuhan aplikasi dan kemungkinan digunakan sebagai portfolio project, beberapa pilihan teknologi dapat digunakan.

## Option A — Laravel

```text
Frontend
    ↓
Laravel Blade / Vue
    ↓
Laravel API
    ↓
MySQL / PostgreSQL
```

Cocok jika tujuan utama adalah memperdalam Laravel.

## Option B — Laravel + React

```text
React
  ↓
REST API
  ↓
Laravel
  ↓
PostgreSQL
```

Lebih cocok jika ingin mempelajari frontend modern sekaligus backend.

## Option C — Go + React

```text
React / Next.js
       ↓
    REST API
       ↓
     Golang
       ↓
   PostgreSQL
```

Pilihan ini cocok jika aplikasi juga digunakan sebagai project untuk belajar Go.

---

# 14. Recommended Architecture

Untuk project portfolio, arsitektur yang disarankan:

```text
┌──────────────────────┐
│   React / Next.js    │
│      Frontend        │
└──────────┬───────────┘
           │
           │ REST API
           ▼
┌──────────────────────┐
│      Golang          │
│       Backend        │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│     PostgreSQL       │
│      Database        │
└──────────────────────┘
```

Docker:

```text
┌─────────────────────────────────┐
│             Docker              │
│                                 │
│  ┌─────────┐  ┌──────────────┐ │
│  │ Backend │  │  PostgreSQL  │ │
│  │   Go    │  │              │ │
│  └─────────┘  └──────────────┘ │
│                                 │
└─────────────────────────────────┘
```

---

# 15. Core Business Logic

## Total Expense

```text
Total Expense =
SUM(all expense transactions)
```

## Remaining Budget

```text
Remaining Budget =
Monthly Budget - Total Expense
```

## Budget Usage

```text
Budget Usage =
(Total Expense / Monthly Budget) × 100
```

## Monthly Difference

```text
Difference =
Current Month Expense - Previous Month Expense
```

## Monthly Percentage Change

```text
Percentage Change =
(
    (Current Month Expense - Previous Month Expense)
    / Previous Month Expense
) × 100
```

---

# 16. Example Dashboard

```text
┌────────────────────────────────────────────┐
│ Spendly                     October 2026 ▼ │
├────────────────────────────────────────────┤
│                                            │
│ TOTAL PENGELUARAN                          │
│ Rp 4.250.000                               │
│                                            │
│ Budget             Sisa                    │
│ Rp 5.000.000       Rp 750.000              │
│                                            │
│ █████████████████░░░ 85%                   │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ Pengeluaran Bulanan                       │
│                                            │
│     █                                       │
│     █   █                                   │
│ █   █   █                                   │
│ █   █   █   █                               │
│ ─────────────────────────                  │
│ May Jun Jul Aug Sep Oct                    │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ Pengeluaran berdasarkan kategori           │
│                                            │
│ 🍚 Makanan          Rp 1.500.000           │
│ 🚗 Transportasi     Rp   700.000           │
│ 🛒 Belanja          Rp   600.000           │
│ 💡 Tagihan          Rp   500.000           │
│ 🎮 Hiburan          Rp   400.000           │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ Transaksi Terbaru                         │
│                                            │
│ Makan siang               Rp 35.000        │
│ Gojek                     Rp 18.000        │
│ Kopi                      Rp 25.000        │
│                                            │
└────────────────────────────────────────────┘
```

---

# 17. Product Principle

Aplikasi harus mengikuti prinsip:

### 1. Fast

Mencatat pengeluaran harus cepat.

### 2. Simple

Tidak terasa seperti aplikasi accounting.

### 3. Insightful

Data transaksi harus menghasilkan informasi yang berguna.

### 4. Visual

Pengguna dapat memahami kondisi keuangannya melalui grafik.

### 5. Actionable

Informasi yang diberikan harus membantu pengguna mengambil keputusan.

---

# 18. Final Product Vision

Daripada membuat aplikasi hanya sebagai:

> **"Catatan pengeluaran digital."**

Product vision sebaiknya:

> **"Aplikasi yang membantu pengguna memahami pola pengeluaran, mengontrol budget, dan membuat keputusan finansial yang lebih baik."**

Flow produk:

```text
             TRANSACTION
                  │
                  ▼
             CATEGORIES
                  │
                  ▼
             MONTHLY DATA
                  │
          ┌───────┴────────┐
          ▼                ▼
       CHARTS            BUDGET
          │                │
          └───────┬────────┘
                  ▼
               INSIGHT
                  │
                  ▼
          BETTER DECISION
```

## Recommended MVP

Untuk versi pertama, fokus hanya pada:

```text
1. Authentication
2. Add Expense
3. Transaction History
4. Categories
5. Monthly Dashboard
6. Monthly Chart
7. Category Chart
8. Monthly Budget
9. Basic Spending Insight
```

Setelah bagian tersebut stabil, baru tambahkan recurring expense, income, saving goal, export, dan fitur advanced lainnya.
