# 📋 Complete Workflows Documentation

This document clearly explains the **three distinct workflows** in the Access Control mobile application, their differences, and how they are implemented.

---

## 🎯 Overview: Three Separate Workflows

| Workflow | Type | QR Scan? | Native Unlock? | Use Case | Endpoint |
|----------|------|----------|----------------|----------|----------|
| **Access Requisition** | QR-based action | ✅ Yes | ✅ Yes | User WITH permission wants to ENTER a zone | `POST /api/access/verify` |
| **Access Request** | Form submission | ❌ No | ❌ No | User WITHOUT permission requests TEMPORARY access | `POST /api/access-requests` |
| **Pointage** | QR-based action | ✅ Yes | ✅ Yes | Employee marks attendance (check-in/check-out) | `POST /api/attendance/check-in` or `/check-out` |

---

## 1️⃣ Access Requisition (Zone Access via QR)

### 📝 Definition
**Access Requisition** is the action of scanning a QR code to REQUEST ENTRY into a zone. This is for users who **ALREADY have permission** to access the zone.

### 🔑 Key Characteristics
- **QR Code Required**: Yes, scans the zone's QR code
- **Native Unlock Required**: Yes, before scanning
- **User Requirement**: User must have access rights to the zone
- **Purpose**: Indicate that the user wants to enter the zone right now

### 🛠️ Technical Implementation

#### Screens
1. **DeviceUnlockScreen** (`lib/presentation/screens/access/device_unlock_screen.dart`)
   - Triggers native device unlock (fingerprint, face, pattern, PIN, password)
   - Uses `DeviceUnlockService` with `local_auth` package
   - `biometricOnly: false` - accepts ALL unlock methods

2. **QRScannerScreen** (`lib/presentation/screens/access/qr_scanner_screen.dart`)
   - Scans the zone's QR code using `mobile_scanner` package
   - Sends QR code to backend for verification

3. **Result Screens**:
   - **AccessGrantedScreen**: Access approved (LOW/MEDIUM security zones)
   - **PinEntryScreen**: PIN required (HIGH security zones)
   - **AccessDeniedScreen**: Access refused

#### BLoC
- **AccessBloc** (`lib/presentation/blocs/access/access_bloc.dart`)
- Events:
  - `DeviceUnlockRequested` - triggers native unlock
  - `QRCodeScanned` - processes scanned QR code
  - `PINSubmitted` - verifies PIN for high-security zones

#### Use Cases
- `VerifyAccessUseCase` - calls `POST /api/access/verify`
- `VerifyPinUseCase` - calls `POST /api/access/verify-pin`

#### API Endpoint
```
POST /api/access/verify
Body: {
  "userId": 123,
  "qrCode": "ZONE_QR_123",
  "deviceInfo": "Mobile App",
  "ipAddress": null
}
```

Response statuses:
- `GRANTED` - Access approved
- `PENDING_PIN` - PIN required (high security)
- `DENIED` - Access refused

#### Flow
```
Dashboard → "Accès Zone" button →
DeviceUnlockScreen (native unlock) →
QRScannerScreen (scan QR) →
AccessBloc.verifyAccess() →
[GRANTED → AccessGrantedScreen]
[PENDING_PIN → PinEntryScreen → AccessGrantedScreen]
[DENIED → AccessDeniedScreen]
```

#### Navigation
- From Dashboard: "Accès Zone (Scan QR)" quick menu button
- Directly opens `DeviceUnlockScreen`

---

## 2️⃣ Access Request (Temporary Access Form)

### 📝 Definition
**Access Request** is a **form-based** request for temporary access to a zone. This is for users who **DO NOT have permission** and need to formally request authorization.

### 🔑 Key Characteristics
- **QR Code Required**: ❌ NO - this is a FORM, not a scan
- **Native Unlock Required**: ❌ NO - just fill out a form
- **User Requirement**: User does NOT have access rights
- **Purpose**: Request temporary authorization from an administrator

### 🛠️ Technical Implementation

#### Screens
1. **CreateAccessRequestScreen** (`lib/presentation/screens/access_requests/create_access_request_screen.dart`)
   - Form with fields:
     - Zone selector (dropdown)
     - Start date/time picker
     - End date/time picker
     - Justification (text area, min 20 characters)
   - Submit button sends request to admin

2. **MyAccessRequestsScreen** (`lib/presentation/screens/access_requests/my_access_requests_screen.dart`)
   - 3 tabs: Pending, Approved, Rejected
   - Displays all user's access requests with status
   - Expandable cards showing justification and admin notes

#### BLoC
- **AccessRequestBloc** (`lib/presentation/blocs/access_request/access_request_bloc.dart`)
- Events:
  - `CreateRequestSubmitted` - submits new access request
  - `MyRequestsRequested` - fetches user's requests

#### Use Cases
- `CreateRequestUseCase` - calls `POST /api/access-requests`
- `GetMyRequestsUseCase` - calls `GET /api/access-requests/my-requests`

#### API Endpoints
```
POST /api/access-requests
Body: {
  "userId": 123,
  "zoneId": 456,
  "startDate": "2025-11-08T09:00:00",
  "endDate": "2025-11-08T17:00:00",
  "justification": "Need access to server room for maintenance work"
}
```

```
GET /api/access-requests/my-requests?userId=123
Response: [
  {
    "id": 1,
    "userId": 123,
    "zoneId": 456,
    "zoneName": "Server Room",
    "status": "PENDING",
    "justification": "...",
    "createdAt": "2025-11-08T08:00:00",
    ...
  }
]
```

#### Flow
```
Dashboard → "Mes Demandes" button →
MyAccessRequestsScreen (view existing requests) →
[Optional] Floating Action Button → CreateAccessRequestScreen →
Fill form → Submit →
Success → Back to MyAccessRequestsScreen
```

OR

```
Access Denied → "Demander un Accès Temporaire" button →
CreateAccessRequestScreen →
Fill form → Submit →
Success → Confirmation
```

#### Navigation
- From Dashboard: "Mes Demandes (Accès temporaire)" quick menu button
- From AccessDeniedScreen: "Demander un Accès Temporaire" button

---

## 3️⃣ Pointage (Attendance Marking)

### 📝 Definition
**Pointage** is the action of marking attendance (check-in/check-out) by scanning a QR code. This is for employees to record their work hours.

### 🔑 Key Characteristics
- **QR Code Required**: ✅ Yes, scans the attendance QR code
- **Native Unlock Required**: ✅ Yes, before each scan
- **User Requirement**: Any employee
- **Purpose**: Record work time (arrival and departure)

### 🛠️ Technical Implementation

#### Screens
1. **AttendanceScreen** (`lib/presentation/screens/attendance/attendance_screen.dart`)
   - Shows current attendance status:
     - Not checked in yet → "Pointer Entrée" button
     - Checked in → Live timer + "Pointer Sortie" button
     - Day complete → Summary with total hours
   - Triggers native unlock before QR scan

2. **AttendanceQRScannerScreen** (`lib/presentation/screens/attendance/attendance_qr_scanner_screen.dart`)
   - Scans QR code for check-in OR check-out
   - Different from zone access scanner
   - `isCheckIn` parameter distinguishes entry from exit

#### BLoC
- **AttendanceBloc** (`lib/presentation/blocs/attendance/attendance_bloc.dart`)
- Events:
  - `CheckInUnlockRequested` - triggers native unlock for check-in
  - `CheckInQRScanned` - processes check-in QR scan
  - `CheckOutUnlockRequested` - triggers native unlock for check-out
  - `CheckOutQRScanned` - processes check-out QR scan
  - `TodayAttendanceRequested` - fetches today's attendance status

#### Use Cases
- `CheckInUseCase` - calls `POST /api/attendance/check-in`
- `CheckOutUseCase` - calls `POST /api/attendance/check-out`
- `GetTodayAttendanceUseCase` - calls `GET /api/attendance/today`

#### API Endpoints
```
POST /api/attendance/check-in
Body: {
  "userId": 123,
  "qrCode": "ATTENDANCE_QR",
  "pinCode": "1234",
  "checkInTime": "2025-11-08T09:00:00",
  "location": null
}
```

```
POST /api/attendance/check-out
Body: {
  "userId": 123,
  "qrCode": "ATTENDANCE_QR",
  "pinCode": "1234",
  "checkOutTime": "2025-11-08T17:00:00",
  "location": null
}
```

#### Flow - Check-in
```
Dashboard → Bottom Nav "Pointage" →
AttendanceScreen (not checked in) →
"Pointer Entrée" button →
Native Unlock (via AttendanceBloc) →
AttendanceQRScannerScreen (isCheckIn: true) →
Scan QR → Enter PIN →
Success → AttendanceScreen (checked in, timer starts)
```

#### Flow - Check-out
```
AttendanceScreen (already checked in, timer running) →
"Pointer Sortie" button →
Native Unlock (via AttendanceBloc) →
AttendanceQRScannerScreen (isCheckIn: false) →
Scan QR → Enter PIN →
Success → Day complete screen with summary
```

#### Navigation
- From Dashboard: Bottom Navigation Bar → "Pointage" icon

---

## 🔄 Comparison Table

| Feature | Access Requisition | Access Request | Pointage |
|---------|-------------------|----------------|----------|
| **Trigger** | Button "Accès Zone" | Button "Mes Demandes" or "Demander Accès" | Bottom Nav "Pointage" |
| **Step 1** | Native Unlock | Open Form | Check Status |
| **Step 2** | Scan Zone QR | Fill Form Fields | Native Unlock |
| **Step 3** | Verify Access | Submit Request | Scan QR |
| **Step 4 (if needed)** | Enter PIN | - | Enter PIN |
| **Result** | Immediate (granted/denied) | Pending admin approval | Recorded in system |
| **BLoC** | AccessBloc | AccessRequestBloc | AttendanceBloc |
| **Screen Prefix** | `access/` | `access_requests/` | `attendance/` |

---

## 🏗️ Architecture Summary

### File Organization
```
lib/presentation/
├── blocs/
│   ├── access/                    # Access Requisition BLoC
│   ├── access_request/            # Access Request BLoC ⭐ NEW
│   └── attendance/                # Pointage BLoC
├── screens/
│   ├── access/                    # Access Requisition screens
│   │   ├── device_unlock_screen.dart
│   │   ├── qr_scanner_screen.dart
│   │   ├── pin_entry_screen.dart
│   │   ├── access_granted_screen.dart
│   │   └── access_denied_screen.dart
│   ├── access_requests/           # Access Request screens ⭐ NEW
│   │   ├── create_access_request_screen.dart
│   │   └── my_access_requests_screen.dart
│   └── attendance/                # Pointage screens
│       ├── attendance_screen.dart
│       └── attendance_qr_scanner_screen.dart
```

### Data Layer
```
lib/data/
├── data_sources/remote/
│   ├── access_api.dart           # Access Requisition API
│   ├── access_request_api.dart   # Access Request API
│   └── attendance_api.dart       # Pointage API
├── repositories/
│   ├── access_repository.dart
│   ├── access_request_repository.dart
│   └── attendance_repository.dart
```

### Domain Layer
```
lib/domain/usecases/
├── access/
│   ├── verify_access_usecase.dart
│   └── verify_pin_usecase.dart
├── access_request/               # ⭐ NEW
│   ├── create_request_usecase.dart
│   └── get_my_requests_usecase.dart
└── attendance/
    ├── check_in_usecase.dart
    └── check_out_usecase.dart
```

---

## ✅ Checklist: What's Implemented

### Access Requisition (Zone Access)
- ✅ DeviceUnlockScreen with native unlock
- ✅ QRScannerScreen for zone QR codes
- ✅ AccessBloc with device unlock + QR verification
- ✅ PIN entry for high-security zones
- ✅ AccessGrantedScreen and AccessDeniedScreen
- ✅ API integration with `/api/access/verify`
- ✅ Navigation from Dashboard

### Access Request (Temporary Access Form)
- ✅ CreateAccessRequestScreen with form
- ✅ MyAccessRequestsScreen with 3 tabs
- ✅ AccessRequestBloc for state management
- ✅ API integration with `/api/access-requests`
- ✅ Navigation from Dashboard and AccessDeniedScreen
- ✅ Dependency injection setup

### Pointage (Attendance)
- ✅ AttendanceScreen with check-in/check-out logic
- ✅ AttendanceQRScannerScreen (separate from zone access)
- ✅ AttendanceBloc with native unlock
- ✅ Live timer display
- ✅ API integration with `/api/attendance/*`
- ✅ Navigation from Dashboard bottom nav

---

## 🎨 User Experience

### Clear Naming
- **"Accès Zone"** with subtitle "Scan QR" → Access Requisition
- **"Mes Demandes"** with subtitle "Accès temporaire" → Access Requests
- **"Pointage"** in bottom nav → Attendance

### Visual Distinction
- **Access Requisition**: Blue/primary color theme, lock icons
- **Access Request**: Form-based, orange warning color for action button
- **Pointage**: Green success theme, timer animations

### Error Handling
- Clear error messages for each workflow
- Proper loading states
- Success confirmations
- Guidance when something goes wrong

---

## 📚 For Developers

### Adding a New Access Request
1. User fills form in `CreateAccessRequestScreen`
2. Form validates (zone selected, dates valid, justification ≥20 chars)
3. `AccessRequestBloc.CreateRequestSubmitted` event fired
4. `CreateRequestUseCase` calls API
5. Success → Dialog → Navigate back
6. Request appears in `MyAccessRequestsScreen` under "Pending" tab

### Verifying Zone Access
1. User taps "Accès Zone" in Dashboard
2. `DeviceUnlockScreen` opens → triggers native unlock
3. On success → `QRScannerScreen` opens
4. QR scanned → `AccessBloc.QRCodeScanned` event
5. `VerifyAccessUseCase` calls `/api/access/verify`
6. Response determines next screen (granted/PIN/denied)

### Marking Attendance
1. User taps "Pointage" in bottom nav
2. `AttendanceScreen` shows status
3. User taps "Pointer Entrée"
4. `AttendanceBloc.CheckInUnlockRequested` → native unlock
5. On success → `AttendanceQRScannerScreen(isCheckIn: true)`
6. QR scanned → PIN entered
7. `CheckInUseCase` calls `/api/attendance/check-in`
8. Timer starts on `AttendanceScreen`

---

## 🔐 Security Notes

1. **Native Unlock**: Uses device's native unlock (NOT app-specific). The `biometricOnly: false` setting ensures all unlock methods work (fingerprint, face, pattern, PIN, password).

2. **Device Unlock Confirmation**: The backend receives confirmation that native unlock was performed (though this can't be cryptographically guaranteed on all platforms).

3. **PIN Codes**: High-security zones require an additional PIN after QR scan. 3 failed attempts → account locked for 30 minutes.

4. **Token Refresh**: All API calls use interceptors with automatic token refresh.

---

## 🚀 Testing Each Workflow

### Test Access Requisition
1. Login as a user with zone access rights
2. Tap "Accès Zone (Scan QR)" on Dashboard
3. Complete native unlock
4. Scan a zone QR code
5. Verify access granted/PIN required/denied response

### Test Access Request
1. Login as any user
2. Tap "Mes Demandes (Accès temporaire)" on Dashboard
3. Tap floating "+" button
4. Fill form with valid data
5. Submit
6. Verify request appears in "Pending" tab

### Test Pointage
1. Login as an employee
2. Tap "Pointage" in bottom nav
3. Tap "Pointer Entrée"
4. Complete native unlock
5. Scan attendance QR code
6. Enter PIN
7. Verify timer starts
8. Later: tap "Pointer Sortie" and complete flow
9. Verify summary shows correct hours

---

**Generated**: 2025-11-08
**Version**: 1.0
**Status**: ✅ All workflows implemented and documented
