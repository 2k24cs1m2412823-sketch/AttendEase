# AttendEase 🎯

**Smart Attendance System** — Bluetooth proximity, QR seat scanning, AI face verification, and real-time dashboards.

## Architecture

```
attendease/
├── mobile/       → Flutter app (Student + Teacher)
├── web/          → React.js Admin Dashboard
├── firebase/     → Firestore rules, Cloud Functions
├── ml/           → TFLite model training & evaluation
└── docs/         → Architecture diagrams & API specs
```

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Web Dashboard | React.js + Tailwind CSS |
| Backend | Firebase (Auth, Firestore, Storage, Functions) |
| AI Engine | TensorFlow Lite (MobileFaceNet) |

## Getting Started

### Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

### Web Dashboard
```bash
cd web
npm install
npm run dev
```

### Firebase
```bash
cd firebase
npm install
firebase emulators:start
```

## Features

- **Roll Number Login** with synthetic email mapping
- **Device Lock** — one student, one device (UUID token)
- **BLE Proximity Check** — Bluetooth room validation
- **QR Seat Scanning** — desk-level location verification
- **AI Face Verification** — offline MobileFaceNet + liveness detection
- **Damage Reporting** — photo upload with suspect identification
- **Real-Time Dashboard** — live classroom grid, exportable reports
- **Offline Mode** — local queue with auto-sync
