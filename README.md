# 🩺 Med Guard

**Med Guard** is an offline-first, elderly-friendly medicine reminder application built with Flutter.
It ensures reliable medication tracking, even without internet connectivity, while supporting real-time sync when online.

---

## 🚀 Overview

Med Guard is designed to solve a critical problem:

> **Missed medicines due to poor reminder systems and unreliable connectivity**

This app provides:

* 📅 Smart daily dose generation
* 🔔 Actionable notifications (Taken / Skip)
* 📊 Adherence tracking & analytics
* 🌐 Sync-ready architecture with Firebase
* 📦 Fully offline-first using Hive

---

## 🧠 Core Features

### 💊 Pillbox Management

* Add / Update / Delete medicines
* Multiple daily schedules
* Daily or custom duration support

---

### ⏰ Smart Reminder System

* Local notifications with:

  * ✅ Taken
  * ❌ Skip
* Exact alarm scheduling (Android)
* Background action handling

---

### 📊 Dose Tracking & Dashboard

* Real-time tracking of:

  * Taken
  * Missed
  * Skipped
  * Pending
* Daily adherence percentage
* Weekly analytics (extensible)

---

### 🔄 Offline-First Sync System

* Hive as source of truth
* Sync Queue (event-based)
* Firestore integration (incremental sync)
* Conflict-safe architecture

---

### 🧓 Elderly-Friendly UX

* Simple UI
* Minimal navigation complexity
* Emergency-ready extensibility

---

## 🏗️ Architecture

This project follows **Clean Architecture + BLoC**:

```text
lib/
│
├── core/
│   ├── di/                # Dependency Injection (get_it)
│   ├── services/          # Notification, Sync, Generator
│   ├── sync/              # Sync Manager & Service
│   ├── routes/            # GoRouter navigation
│   └── theme/
│
├── features/
│   ├── auth/
│   ├── pillbox/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── dashboard/
│   ├── reminder/
│   ├── profile/
│   └── sync/
│
└── main.dart
```

---

## ⚙️ Tech Stack

| Layer                | Technology                           |
| -------------------- | ------------------------------------ |
| UI                   | Flutter                              |
| State Management     | BLoC                                 |
| Local Storage        | Hive                                 |
| Notifications        | flutter_local_notifications          |
| Timezone             | timezone (tz)                        |
| Backend              | Firebase (Firestore - optional sync) |
| Dependency Injection | get_it                               |
| Routing              | GoRouter                             |

---

## 🔁 Data Flow

### Add Medicine Flow

```text
Add Medicine
   ↓
Save to Hive
   ↓
Schedule Notification
   ↓
Generate Today's Dose
   ↓
Add to Sync Queue
```

---

### Dashboard Flow

```text
Hive Stream
   ↓
BLoC Listener
   ↓
Filter Today Doses
   ↓
Calculate Stats
   ↓
Update UI
```

---

### Sync Flow

```text
Local Change
   ↓
Add to Sync Queue
   ↓
Sync Manager Trigger
   ↓
Push to Firestore
   ↓
Pull Updates
   ↓
Merge to Hive
```

---

## 📦 Key Components

### 🔹 DailyDoseGenerator

* Generates only **today’s doses**
* Prevents duplication
* Keeps database lightweight

---

### 🔹 NotificationService

* Schedules exact reminders
* Handles foreground & background actions

---

### 🔹 SyncService

* Incremental sync using `updatedAt`
* Conflict-safe merging

---

### 🔹 Tracking System

* Tracks dose states:

  * `pending`
  * `taken`
  * `skipped`
  * `missed`

---

## 🛠️ Setup Instructions

### 1. Clone Project

```bash
git clone https://github.com/your-username/med_guard.git
cd med_guard
```

---

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Run App

```bash
flutter run
```

---

### 4. (Optional) Firebase Setup

* Add `google-services.json`
* Enable Firestore
* Configure rules

---

## ⚠️ Important Notes

* App works **fully offline**
* Sync is optional but recommended
* Notifications require:

  * Exact alarm permission (Android 12+)
  * Notification permission

---

## 🧪 Debug Logs

The app includes detailed logs for:

* Dose generation
* Hive updates
* Sync operations
* Notification triggers

---

## 📈 Future Enhancements

* 🚨 Emergency SOS system
* 👨‍⚕️ Caregiver alerts
* 📅 Weekly/monthly insights
* ☁️ Full Firebase Auth integration
* 📲 Cross-device sync
* 🧠 Smart adherence AI

---

## 👨‍💻 Author

**Anshul Parmar**

* GitHub: https://github.com/anshulparmar353
* LinkedIn: https://linkedin.com

---

## ⭐ Final Note

Med Guard is not just a reminder app —
it’s a **reliability-first healthcare assistant** built with scalable architecture and real-world usability in mind.
