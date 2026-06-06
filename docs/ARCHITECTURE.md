# AttendEase — Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    STUDENT PHONE                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │ BLE Scan │ │ QR Scan  │ │ TFLite   │ │ ML Kit   │   │
│  │ Proximity│ │ Seat ID  │ │ FaceNet  │ │ Liveness │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│       └─────────────┴────────────┴────────────┘         │
│                         │                                │
│            ┌────────────┴────────────┐                   │
│            │  Attendance Controller  │                   │
│            │  (Orchestrator)         │                   │
│            └────────────┬────────────┘                   │
│                         │                                │
│       ┌─────────────────┴─────────────────┐              │
│       │ Online → Firestore  │ Offline → Hive │           │
│       └─────────────────────┴─────────────┘              │
└─────────────────────────┬───────────────────────────────┘
                          │  Firebase SDK
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    FIREBASE CLOUD                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │   Auth   │ │Firestore │ │ Storage  │ │Functions │   │
│  │ (Email)  │ │ (Realtime│ │ (Photos) │ │ (Damage  │   │
│  │          │ │  DB)     │ │          │ │ Analysis)│   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │
└─────────────────────────┬───────────────────────────────┘
                          │  Firestore Realtime
                          ▼
┌─────────────────────────────────────────────────────────┐
│               ADMIN WEB DASHBOARD                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │ Live     │ │Attendance│ │ Damage   │ │ Export   │   │
│  │ Seat Grid│ │ Logs     │ │ Feed     │ │ (XLS/PDF)│   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Firestore Collections

| Collection | Key Fields | Purpose |
|---|---|---|
| `users` | institutional_id, role, bound_device_token, face_embedding | User profiles |
| `active_sessions` | teacher_id, room_id, beacon_uuid, seat_map, is_active | Live sessions |
| `attendance_logs` | session_id, student_id, seat_id, verification_score | Attendance records |
| `damage_reports` | seat_id, flag (GREEN/RED), suspect_uid, image_url | Damage tracking |

## Security Protocols

1. **Roll Number Login** → Synthetic email mapping (CS-2024-001 → cs-2024-001@attendease.app)
2. **Device Lock** → UUID token in secure storage, compared with Firestore on every login
3. **BLE Proximity** → RSSI threshold validation (> -70 dBm ≈ 5m range)
4. **QR Integrity** → SHA-256 HMAC hash on seat+room+secret prevents forgery
5. **Face Privacy** → Only 192-float vectors stored, never raw images
6. **Firestore Rules** → Role-based read/write with field-level restrictions
