# ✅ APIs & Repositories - Implémentation Complète

## 🎉 Ce qui a été créé

Tous les APIs (Data Sources) et Repositories ont été créés avec gestion complète des erreurs !

---

## 📦 APIs (Data Sources) - 7 APIs

### 1. ✅ ApiErrorHandler (Helper)

**Fichier** : `lib/data/data_sources/remote/api_error_handler.dart`

**Rôle** : Gestion centralisée des erreurs DioException

**Fonctionnalités** :
- Convertit DioException en Exceptions appropriées
- Gère tous les cas d'erreurs HTTP (400, 401, 403, 404, 409, 500, etc.)
- Extrait les messages d'erreur du backend
- Gère les erreurs de validation (fieldErrors)
- Gère les comptes bloqués (AccountLockedException)

**Conversions** :
- Timeout → `TimeoutException`
- Connexion → `NetworkException`
- 400 → `ValidationException`
- 401 → `UnauthorizedException`
- 403 → `ForbiddenException`
- 404 → `NotFoundException`
- 409 → `AccountLockedException` (si accountLockedUntil présent)
- 500+ → `ServerException`

---

### 2. ✅ AuthApi

**Fichier** : `lib/data/data_sources/remote/auth_api.dart`

**Interface** :
```dart
abstract class AuthApi {
  Future<AuthResponseModel> login(String email, String password);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
}
```

**Endpoints** :
- `POST /auth/login` → AuthResponseModel
- `POST /auth/refresh` → String (accessToken)
- `POST /auth/logout` → void

**Gestion d'erreurs** : ApiErrorHandler.handleDioException()

---

### 3. ✅ AccessApi ⭐

**Fichier** : `lib/data/data_sources/remote/access_api.dart`

**Interface** :
```dart
abstract class AccessApi {
  Future<AccessVerifyResponseModel> verifyAccess({
    required String userId,
    required String qrCode,
    required bool deviceUnlocked, // ⭐ IMPORTANT
  });

  Future<AccessVerifyResponseModel> verifyPin({
    required String tempToken,
    required String pinCode,
  });

  Future<List<AccessEventModel>> getAccessHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
```

**Endpoints** :
- `POST /access/verify` (avec `device_unlocked: true`) ⭐
- `POST /access/verify-pin`
- `GET /access/history?userId=X&dateStart=...&dateEnd=...`

**Point critique** : `deviceUnlocked` est envoyé au backend pour confirmer le déverrouillage natif

---

### 4. ✅ AttendanceApi

**Fichier** : `lib/data/data_sources/remote/attendance_api.dart`

**Interface** :
```dart
abstract class AttendanceApi {
  Future<AttendanceModel> checkIn({
    required String userId,
    required String qrCode,
    required String pinCode,
  });

  Future<AttendanceModel> checkOut({
    required String userId,
    required String qrCode,
    required String pinCode,
  });

  Future<AttendanceModel?> getAttendanceToday({
    required String userId,
  }); // Returns null if 404

  Future<List<AttendanceModel>> getAttendanceHistory({
    required String userId,
    required String month,
  });
}
```

**Endpoints** :
- `POST /attendance/check-in`
- `POST /attendance/check-out`
- `GET /attendance/today?userId=X` (retourne null si 404)
- `GET /attendance/history?userId=X&month=yyyy-MM`

**Point critique** : `getAttendanceToday` retourne `null` si 404 (pas pointé aujourd'hui)

---

### 5. ✅ UserApi

**Fichier** : `lib/data/data_sources/remote/user_api.dart`

**Interface** :
```dart
abstract class UserApi {
  Future<UserModel> getUser(String userId);
  Future<List<Map<String, dynamic>>> getAccessZones(String userId);
}
```

**Endpoints** :
- `GET /users/{id}`
- `GET /users/{id}/access-zones`

---

### 6. ✅ AccessRequestApi

**Fichier** : `lib/data/data_sources/remote/access_request_api.dart`

**Interface** :
```dart
abstract class AccessRequestApi {
  Future<List<AccessRequestModel>> getMyRequests(String userId);

  Future<AccessRequestModel> createRequest({
    required String userId,
    required String zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  });
}
```

**Endpoints** :
- `GET /access-requests/my-requests?userId=X`
- `POST /access-requests`

---

### 7. ✅ DashboardApi

**Fichier** : `lib/data/data_sources/remote/dashboard_api.dart`

**Interface** :
```dart
abstract class DashboardApi {
  Future<DashboardKpisModel> getKpis(String userId);
}
```

**Endpoints** :
- `GET /dashboard/kpis?userId=X`

---

## 🗄️ Repositories - 6 Repositories

### Tous utilisent Either<Failure, Success> ⭐

Pattern :
```dart
Future<Either<Failure, Model>> methodName();
```

Gestion d'erreurs :
```dart
try {
  final result = await api.method();
  return Right(result);
} on SpecificException catch (e) {
  return Left(SpecificFailure(message: e.message));
} catch (e) {
  return Left(GenericFailure(message: 'Erreur: ${e.toString()}'));
}
```

---

### 1. ✅ AuthRepository

**Fichier** : `lib/data/repositories/auth_repository.dart`

**Interface** :
```dart
abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel?>> getCachedUser();
  Future<bool> isAuthenticated();
}
```

**Fonctionnalités critiques** :
- **login** : Appelle API, stocke tokens dans StorageService, parse user, retourne Right(user)
- **logout** : Appelle API (ignore erreurs), clear storage
- **getCachedUser** : Lit user depuis storage, parse JSON
- **isAuthenticated** : Vérifie si token existe

**Exemple d'utilisation** :
```dart
final result = await authRepository.login('email@example.com', 'password');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Success: ${user.fullName}'),
);
```

---

### 2. ✅ AccessRepository ⭐

**Fichier** : `lib/data/repositories/access_repository.dart`

**Interface** :
```dart
abstract class AccessRepository {
  Future<Either<Failure, AccessVerifyResponseModel>> verifyAccess({
    required String userId,
    required String qrCode,
    required bool deviceUnlocked, // ⭐
  });

  Future<Either<Failure, AccessVerifyResponseModel>> verifyPin({
    required String tempToken,
    required String pinCode,
  });

  Future<Either<Failure, List<AccessEventModel>>> getAccessHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
```

**Gestion d'erreurs spécifiques** :
- `QRCodeException` → `QRCodeFailure`
- `AccountLockedException` → `AccountLockedFailure`
- `InvalidPinException` → `InvalidPinFailure`

**Exemple d'utilisation** :
```dart
final result = await accessRepository.verifyAccess(
  userId: 'user_123',
  qrCode: 'QR_CODE',
  deviceUnlocked: true, // ⭐ Confirmé par DeviceUnlockService
);

result.fold(
  (failure) {
    if (failure is AccountLockedFailure) {
      print('Compte bloqué jusqu\'à ${failure.lockedUntil}');
    } else {
      print('Error: ${failure.message}');
    }
  },
  (response) {
    if (response.status == 'GRANTED') {
      print('Accès autorisé à ${response.zone.name}');
    } else if (response.status == 'PENDING_PIN') {
      print('PIN requis. Token: ${response.tempToken}');
    } else {
      print('Accès refusé: ${response.reason}');
    }
  },
);
```

---

### 3. ✅ AttendanceRepository

**Fichier** : `lib/data/repositories/attendance_repository.dart`

**Interface** :
```dart
abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceModel>> checkIn({
    required String userId,
    required String qrCode,
    required String pinCode,
  });

  Future<Either<Failure, AttendanceModel>> checkOut({
    required String userId,
    required String qrCode,
    required String pinCode,
  });

  Future<Either<Failure, AttendanceModel?>> getAttendanceToday({
    required String userId,
  });

  Future<Either<Failure, List<AttendanceModel>>> getAttendanceHistory({
    required String userId,
    required String month,
  });
}
```

**Gestion d'erreurs spécifiques** :
- `InvalidPinException` → `InvalidPinFailure`
- `AccountLockedException` → `AccountLockedFailure`

---

### 4. ✅ UserRepository

**Fichier** : `lib/data/repositories/user_repository.dart`

**Interface** :
```dart
abstract class UserRepository {
  Future<Either<Failure, UserModel>> getUser(String userId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAccessZones(String userId);
}
```

---

### 5. ✅ AccessRequestRepository

**Fichier** : `lib/data/repositories/access_request_repository.dart`

**Interface** :
```dart
abstract class AccessRequestRepository {
  Future<Either<Failure, List<AccessRequestModel>>> getMyRequests(String userId);

  Future<Either<Failure, AccessRequestModel>> createRequest({
    required String userId,
    required String zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  });
}
```

**Gestion d'erreurs spécifiques** :
- `ValidationException` → `ValidationFailure` (avec fieldErrors)

---

### 6. ✅ DashboardRepository

**Fichier** : `lib/data/repositories/dashboard_repository.dart`

**Interface** :
```dart
abstract class DashboardRepository {
  Future<Either<Failure, DashboardKpisModel>> getKpis(String userId);
}
```

---

## 📊 Résumé

### APIs (Data Sources)
- ✅ **ApiErrorHandler** : Gestion centralisée des erreurs
- ✅ **AuthApi** : login, refreshToken, logout
- ✅ **AccessApi** ⭐ : verifyAccess (deviceUnlocked), verifyPin, getAccessHistory
- ✅ **AttendanceApi** : checkIn, checkOut, getAttendanceToday (null si 404), getAttendanceHistory
- ✅ **UserApi** : getUser, getAccessZones
- ✅ **AccessRequestApi** : getMyRequests, createRequest
- ✅ **DashboardApi** : getKpis

**Total** : 7 fichiers (1 helper + 6 APIs)

### Repositories
- ✅ **AuthRepository** : login (stocke tokens), logout, getCachedUser, isAuthenticated
- ✅ **AccessRepository** ⭐ : verifyAccess, verifyPin, getAccessHistory
- ✅ **AttendanceRepository** : checkIn, checkOut, getAttendanceToday, getAttendanceHistory
- ✅ **UserRepository** : getUser, getAccessZones
- ✅ **AccessRequestRepository** : getMyRequests, createRequest
- ✅ **DashboardRepository** : getKpis

**Total** : 6 fichiers

**Grand Total** : **13 fichiers créés**

---

## 🎯 Points Critiques Implémentés

### ✅ Either<Failure, Success>
- Tous les repositories utilisent `Either<Failure, Success>`
- Gestion d'erreurs fonctionnelle (package dartz)
- Pattern `.fold()` pour gérer succès et échec

### ✅ deviceUnlocked ⭐
- `AccessApi.verifyAccess()` envoie `device_unlocked: true`
- Confirmé par `DeviceUnlockService` avant l'appel
- Le backend vérifie cette valeur

### ✅ StorageService (AuthRepository)
- Login stocke `accessToken`, `refreshToken`, `user`
- Logout clear tout le storage
- getCachedUser lit et parse le user depuis JSON

### ✅ Gestion d'erreurs complète
- Toutes les exceptions sont catchées
- Converties en Failures appropriées
- Messages d'erreur clairs

### ✅ Null-safety
- `getAttendanceToday` retourne `AttendanceModel?` (null si 404)
- `getCachedUser` retourne `UserModel?` (null si pas de cache)

---

## 📁 Structure

```
lib/data/
├── data_sources/
│   └── remote/
│       ├── api_error_handler.dart       ✅
│       ├── auth_api.dart                ✅
│       ├── access_api.dart              ✅
│       ├── attendance_api.dart          ✅
│       ├── user_api.dart                ✅
│       ├── access_request_api.dart      ✅
│       └── dashboard_api.dart           ✅
│
└── repositories/
    ├── auth_repository.dart             ✅
    ├── access_repository.dart           ✅
    ├── attendance_repository.dart       ✅
    ├── user_repository.dart             ✅
    ├── access_request_repository.dart   ✅
    └── dashboard_repository.dart        ✅
```

---

## 🚀 Prochaines Étapes

**Phase 3 : Domain Layer** (UseCases)

1. Créer tous les UseCases :
   - LoginUseCase
   - VerifyAccessUseCase ⭐
   - VerifyPinUseCase ⭐
   - CheckInUseCase
   - CheckOutUseCase
   - etc.

2. Un UseCase = Une action
3. Appelle le Repository correspondant
4. Retourne Either<Failure, Success>

**Exemple de UseCase** :
```dart
class VerifyAccessUseCase {
  final AccessRepository repository;

  Future<Either<Failure, AccessVerifyResponseModel>> call({
    required String userId,
    required String qrCode,
    required bool deviceUnlocked,
  }) {
    return repository.verifyAccess(
      userId: userId,
      qrCode: qrCode,
      deviceUnlocked: deviceUnlocked,
    );
  }
}
```

---

**APIs & Repositories : 100% Complétés** ✅
**13 fichiers créés** 🎉
**Prochaine étape : UseCases (Domain Layer)** 🚀
