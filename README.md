<div align="center">

# AttendEase 🎯

**AI-powered Smart Attendance System**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-MobileFaceNet-FF6F00?style=flat&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![React](https://img.shields.io/badge/React-Vite-61DAFB?style=flat&logo=react&logoColor=black)](https://react.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Bluetooth proximity · QR seat scanning · Offline-first AI face verification · Real-time dashboard*

</div>

---

## 📸 Screenshots

> _Add screenshots here — mobile login, QR scan, face verify screen, and web dashboard grid._> <img width="287" height="538" alt="image" src="https://github.com/user-attachments/assets/57cae5b1-6b7a-42ad-b43a-f34b4e9189c3" />
<img width="367" height="679" alt="image" src="https://github.com/user-attachments/assets/bbc18e05-81e9-4b22-8976-04ad35528b31" />
<img width="368" height="678" alt="image" src="https://github.com/user-attachments/assets/635f2221-71bd-40cc-8b5c-d0824e6f197c" />
<img width="373" height="680" alt="image" src="https://github.com/user-attachments/assets/cb8a137b-3ec8-48f2-a34a-a689b9c848c5" />
<img width="416" height="779" alt="image" src="https://github.com/user-attachments/assets/47ed30b8-4900-4f4e-a360-36eb5d246b86" />




---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Roll Number Login** | Synthetic email mapping — no manual account creation |
| 📱 **Device Lock** | One student, one device via UUID token in secure storage |
| 📡 **BLE Proximity** | Bluetooth RSSI check ensures student is physically in the room |
| 🪑 **QR Seat Scanning** | HMAC-signed QR codes tie each student to a specific desk |
| 🤖 **AI Face Verification** | Offline MobileFaceNet (192-dim embeddings) + liveness detection |
| 📷 **Damage Reporting** | Photo upload with automatic suspect identification via Cloud Functions |
| 📊 **Real-Time Dashboard** | Live classroom seat grid, attendance logs, Excel/PDF export |
| 🔌 **Offline Mode** | Hive local queue with automatic sync when connection is restored |

attendease/
├── mobile/         → Flutter app (Student + Teacher flows)
│   ├── lib/
│   │   ├── screens/    → UI screens
│   │   └── services/   → BLE, QR, Face, Auth, Offline services
│   └── assets/models/  → TFLite model (place mobilefacenet.tflite here)
├── web/            → React.js + Tailwind CSS admin dashboard
├── firebase/
│   ├── functions/  → Cloud Functions (damage analysis, session cleanup)
│   └── firestore.rules
├── ml/             → MobileFaceNet evaluation scripts
└── docs/           → Architecture diagrams & API specs

### How It Works
Student opens app
│
├─ 1. BLE Scan → Must be within 5m of teacher's beacon
├─ 2. QR Scan  → Scans desk QR code (HMAC-verified, seat-specific)
├─ 3. Face     → MobileFaceNet embedding compared against enrolled vector
└─ 4. Log      → Written to Firestore (or Hive if offline)

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| Web Dashboard | React + Vite + TypeScript + Tailwind CSS v4 |
| Backend | Firebase — Auth, Firestore, Storage, Cloud Functions |
| AI Engine | TensorFlow Lite — MobileFaceNet (offline inference) |
| Offline Storage | Hive (Flutter) |
| State Management | Provider + GoRouter |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.2.0
- [Node.js](https://nodejs.org/) ≥ 18
- [Firebase CLI](https://firebase.google.com/docs/cli) — `npm install -g firebase-tools`
- Firebase project with Auth, Firestore, Storage, and Functions enabled

### 1. Clone the repo

```bash
git clone https://github.com/2k24cs1m2412823-sketch/AttendEase.git
cd AttendEase
```

### 2. Mobile app

```bash
cd mobile
flutter pub get
flutter run
```

### 3. Web dashboard

```bash
cd web
npm install
npm run dev
```

### 4. Firebase emulators

```bash
cd firebase
npm install
firebase emulators:start
```

---

## 🔒 Security

- **Device Lock** — UUID token in `flutter_secure_storage`, verified on every login
- **BLE Proximity** — RSSI threshold > −70 dBm (≈ 5 m range)
- **QR Integrity** — SHA-256 HMAC prevents seat QR forgery
- **Face Privacy** — Only 192-float vectors stored, never raw images
- **Firestore Rules** — Role-based read/write with field-level restrictions

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

---

## 📄 License

MIT © 2024 — see [LICENSE](LICENSE) for details.

---

## 🏗️ Architecture
