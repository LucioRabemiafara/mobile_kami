# ✅ UseCases (Domain Layer) - Implémentation Complète

## 🎉 Ce qui a été créé

Tous les UseCases ont été créés avec le pattern Either<Failure, Success> !

**Total : 16 UseCases**

---

## 📦 Structure des UseCases

Tous les UseCases suivent le même pattern :

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/repositories/[repository].dart';
import '../../../data/models/[model].dart';

@injectable
class SomeUseCase {
  final SomeRepository _repository;

  SomeUseCase(this._repository);

  Future<Either<Failure, ReturnType>> call({
    required params,
  }) async {
    return await _repository.method(params);
  }
}
```

**Principes** :
- ✅ Un UseCase = Une action unique
- ✅ Appelle le Repository correspondant
- ✅ Retourne Either<Failure, Success>
- ✅ Annoté avec @injectable pour GetIt
- ✅ Utilise `call()` pour syntaxe simplifiée

**Utilisation** :
```dart
final result = await useCase(params);
// OU
final result = await useCase.call(params);
```

---

## 1️⃣ Auth UseCases (4)

### LoginUseCase

**Fichier** : `lib/domain/usecases/auth/login_usecase.dart`

**Rôle** : Authentifie un utilisateur avec email et mot de passe

**Signature** :
```dart
Future<Either<Failure, UserModel>> call({
  required String email,
  required String password,
})
```

**Retours possibles** :
- `Right(UserModel)` → Succès, utilisateur authentifié
- `Left(UnauthorizedFailure)` → Email ou mot de passe incorrect
- `Left(AccountLockedFailure)` → Compte bloqué (trop de tentatives)
- `Left(NetworkFailure)` → Erreur réseau
- `Left(TimeoutFailure)` → Timeout

**Exemple d'utilisation** :
```dart
final result = await loginUseCase(
  email: 'jean.dupont@company.com',
  password: 'SecurePass123',
);

result.fold(
  (failure) {
    if (failure is AccountLockedFailure) {
      print('Compte bloqué jusqu\'à ${failure.lockedUntil}');
    } else {
      print('Erreur: ${failure.message}');
    }
  },
  (user) {
    print('Bienvenue ${user.fullName}');
    // Navigate to Dashboard
  },
);
```

---

### LogoutUseCase

**Fichier** : `lib/domain/usecases/auth/logout_usecase.dart`

**Rôle** : Déconnecte l'utilisateur et efface les données stockées

**Signature** :
```dart
Future<Either<Failure, void>> call()
```

**Retours possibles** :
- `Right(void)` → Succès
- `Left(GenericFailure)` → Erreur inattendue

**Exemple d'utilisation** :
```dart
final result = await logoutUseCase();

result.fold(
  (failure) => print('Erreur lors de la déconnexion'),
  (_) {
    // Navigate to Login screen
  },
);
```

---

### GetCachedUserUseCase

**Fichier** : `lib/domain/usecases/auth/get_cached_user_usecase.dart`

**Rôle** : Récupère l'utilisateur depuis le cache local (StorageService)

**Signature** :
```dart
Future<Either<Failure, UserModel?>> call()
```

**Retours possibles** :
- `Right(UserModel)` → Utilisateur trouvé
- `Right(null)` → Pas d'utilisateur en cache
- `Left(GenericFailure)` → Erreur de lecture

**Exemple d'utilisation** :
```dart
final result = await getCachedUserUseCase();

result.fold(
  (failure) => print('Erreur cache'),
  (user) {
    if (user != null) {
      print('Utilisateur : ${user.fullName}');
    } else {
      print('Pas d\'utilisateur en cache');
    }
  },
);
```

---

### IsAuthenticatedUseCase

**Fichier** : `lib/domain/usecases/auth/is_authenticated_usecase.dart`

**Rôle** : Vérifie si un utilisateur est authentifié (a un token valide)

**Signature** :
```dart
Future<bool> call()
```

**Retours** :
- `true` → Utilisateur authentifié
- `false` → Pas authentifié

**Exemple d'utilisation** :
```dart
final isAuth = await isAuthenticatedUseCase();

if (isAuth) {
  // Navigate to Dashboard
} else {
  // Navigate to Login
}
```

---

## 2️⃣ Access UseCases ⭐ (3)

### VerifyAccessUseCase ⭐

**Fichier** : `lib/domain/usecases/access/verify_access_usecase.dart`

**Rôle** : Vérifie si un utilisateur peut accéder à une zone via QR code

**⚠️ IMPORTANT** : Nécessite le déverrouillage natif du téléphone (`deviceUnlocked: true`)

**Signature** :
```dart
Future<Either<Failure, AccessVerifyResponseModel>> call({
  required String userId,
  required String qrCode,
  required bool deviceUnlocked, // ⭐ MUST be true
})
```

**Retours possibles** :
- `Right(AccessVerifyResponseModel)` → Succès
  - `status: 'GRANTED'` → Accès autorisé
  - `status: 'PENDING_PIN'` → PIN requis (zone HIGH security)
  - `status: 'DENIED'` → Accès refusé
- `Left(QRCodeFailure)` → QR code invalide
- `Left(AccountLockedFailure)` → Compte bloqué
- `Left(UnauthorizedFailure)` → Token invalide
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
// 1. D'abord, déverrouiller le téléphone
final deviceUnlocked = await deviceUnlockService.authenticate();

if (!deviceUnlocked) {
  // Show error
  return;
}

// 2. Ensuite, vérifier l'accès
final result = await verifyAccessUseCase(
  userId: currentUser.id,
  qrCode: scannedQRCode,
  deviceUnlocked: true, // ⭐ Confirmé
);

result.fold(
  (failure) {
    if (failure is QRCodeFailure) {
      print('QR code invalide');
    } else if (failure is AccountLockedFailure) {
      print('Compte bloqué jusqu\'à ${failure.lockedUntil}');
    }
  },
  (response) {
    if (response.status == 'GRANTED') {
      print('Accès autorisé à ${response.zone.name}');
      // Navigate to AccessGrantedScreen
    } else if (response.status == 'PENDING_PIN') {
      print('PIN requis');
      // Navigate to PinEntryScreen with tempToken
    } else {
      print('Accès refusé: ${response.reason}');
      // Navigate to AccessDeniedScreen
    }
  },
);
```

---

### VerifyPinUseCase

**Fichier** : `lib/domain/usecases/access/verify_pin_usecase.dart`

**Rôle** : Vérifie le code PIN pour les zones haute sécurité

**Signature** :
```dart
Future<Either<Failure, AccessVerifyResponseModel>> call({
  required String tempToken,
  required String pinCode,
})
```

**Retours possibles** :
- `Right(AccessVerifyResponseModel)` → Succès
  - `status: 'GRANTED'` → PIN correct, accès autorisé
  - `status: 'DENIED'` → PIN incorrect
- `Left(InvalidPinFailure)` → PIN incorrect (avec tentatives restantes)
- `Left(AccountLockedFailure)` → Compte bloqué (trop de tentatives)

**Exemple d'utilisation** :
```dart
final result = await verifyPinUseCase(
  tempToken: response.tempToken!, // De verifyAccess
  pinCode: '1234',
);

result.fold(
  (failure) {
    if (failure is InvalidPinFailure) {
      print('PIN incorrect. ${failure.attemptsRemaining} tentatives restantes');
    } else if (failure is AccountLockedFailure) {
      print('Compte bloqué jusqu\'à ${failure.lockedUntil}');
    }
  },
  (response) {
    if (response.status == 'GRANTED') {
      print('Accès autorisé');
      // Navigate to AccessGrantedScreen
    } else {
      print('PIN refusé');
    }
  },
);
```

---

### GetAccessHistoryUseCase

**Fichier** : `lib/domain/usecases/access/get_access_history_usecase.dart`

**Rôle** : Récupère l'historique des accès d'un utilisateur

**Signature** :
```dart
Future<Either<Failure, List<AccessEventModel>>> call({
  required String userId,
  DateTime? startDate,
  DateTime? endDate,
})
```

**Retours possibles** :
- `Right(List<AccessEventModel>)` → Succès
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getAccessHistoryUseCase(
  userId: currentUser.id,
  startDate: DateTime.now().subtract(Duration(days: 7)),
  endDate: DateTime.now(),
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (events) {
    for (var event in events) {
      print('${event.timestamp}: ${event.status} à ${event.zone.name}');
    }
  },
);
```

---

## 3️⃣ Attendance UseCases (4)

### CheckInUseCase

**Fichier** : `lib/domain/usecases/attendance/check_in_usecase.dart`

**Rôle** : Enregistre l'arrivée de l'employé

**Signature** :
```dart
Future<Either<Failure, AttendanceModel>> call({
  required String userId,
  required String qrCode,
  required String pinCode,
})
```

**Retours possibles** :
- `Right(AttendanceModel)` → Succès
- `Left(InvalidPinFailure)` → PIN incorrect
- `Left(QRCodeFailure)` → QR code invalide

**Exemple d'utilisation** :
```dart
final result = await checkInUseCase(
  userId: currentUser.id,
  qrCode: scannedQRCode,
  pinCode: '1234',
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (attendance) {
    print('Pointage enregistré à ${attendance.checkInTime}');
  },
);
```

---

### CheckOutUseCase

**Fichier** : `lib/domain/usecases/attendance/check_out_usecase.dart`

**Rôle** : Enregistre le départ de l'employé

**Signature** :
```dart
Future<Either<Failure, AttendanceModel>> call({
  required String userId,
  required String qrCode,
  required String pinCode,
})
```

**Retours possibles** :
- `Right(AttendanceModel)` → Succès
- `Left(InvalidPinFailure)` → PIN incorrect

**Exemple d'utilisation** :
```dart
final result = await checkOutUseCase(
  userId: currentUser.id,
  qrCode: scannedQRCode,
  pinCode: '1234',
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (attendance) {
    print('Départ enregistré à ${attendance.checkOutTime}');
    print('Heures travaillées: ${attendance.hoursWorkedFormatted}');
  },
);
```

---

### GetTodayAttendanceUseCase

**Fichier** : `lib/domain/usecases/attendance/get_today_attendance_usecase.dart`

**Rôle** : Récupère le pointage du jour

**Signature** :
```dart
Future<Either<Failure, AttendanceModel?>> call({
  required String userId,
})
```

**Retours possibles** :
- `Right(AttendanceModel)` → Pointage trouvé
- `Right(null)` → Pas pointé aujourd'hui
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getTodayAttendanceUseCase(
  userId: currentUser.id,
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (attendance) {
    if (attendance != null) {
      if (attendance.hasCheckedIn && !attendance.hasCheckedOut) {
        print('Pointé depuis ${attendance.checkInTime}');
      } else if (attendance.hasCheckedOut) {
        print('Journée terminée: ${attendance.hoursWorkedFormatted}');
      }
    } else {
      print('Pas encore pointé aujourd\'hui');
    }
  },
);
```

---

### GetAttendanceHistoryUseCase

**Fichier** : `lib/domain/usecases/attendance/get_attendance_history_usecase.dart`

**Rôle** : Récupère l'historique des pointages pour un mois

**Signature** :
```dart
Future<Either<Failure, List<AttendanceModel>>> call({
  required String userId,
  required String month, // Format: "yyyy-MM"
})
```

**Retours possibles** :
- `Right(List<AttendanceModel>)` → Succès
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getAttendanceHistoryUseCase(
  userId: currentUser.id,
  month: '2024-01',
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (attendances) {
    for (var attendance in attendances) {
      print('${attendance.date}: ${attendance.hoursWorkedFormatted}');
    }
  },
);
```

---

## 4️⃣ User UseCases (2)

### GetUserUseCase

**Fichier** : `lib/domain/usecases/user/get_user_usecase.dart`

**Rôle** : Récupère les détails d'un utilisateur depuis le backend

**Signature** :
```dart
Future<Either<Failure, UserModel>> call({
  required String userId,
})
```

**Retours possibles** :
- `Right(UserModel)` → Succès
- `Left(NotFoundFailure)` → Utilisateur introuvable
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getUserUseCase(
  userId: 'user_123',
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (user) {
    print('Utilisateur: ${user.fullName}');
    print('Postes: ${formatPostsList(user.posts)}'); // MULTI-POSTES
  },
);
```

---

### GetAccessZonesUseCase

**Fichier** : `lib/domain/usecases/user/get_access_zones_usecase.dart`

**Rôle** : Récupère toutes les zones accessibles par un utilisateur (MULTI-POSTES)

**Signature** :
```dart
Future<Either<Failure, List<Map<String, dynamic>>>> call({
  required String userId,
})
```

**Retours possibles** :
- `Right(List<Map<String, dynamic>>)` → Succès
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getAccessZonesUseCase(
  userId: currentUser.id,
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (zones) {
    print('Vous avez accès à ${zones.length} zones');
    for (var zone in zones) {
      print('- ${zone['name']}');
    }
  },
);
```

---

## 5️⃣ Access Request UseCases (2)

### GetMyRequestsUseCase

**Fichier** : `lib/domain/usecases/access_request/get_my_requests_usecase.dart`

**Rôle** : Récupère toutes les demandes d'accès d'un utilisateur

**Signature** :
```dart
Future<Either<Failure, List<AccessRequestModel>>> call({
  required String userId,
})
```

**Retours possibles** :
- `Right(List<AccessRequestModel>)` → Succès
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getMyRequestsUseCase(
  userId: currentUser.id,
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (requests) {
    final pending = requests.where((r) => r.isPending).toList();
    print('Vous avez ${pending.length} demandes en attente');
  },
);
```

---

### CreateRequestUseCase

**Fichier** : `lib/domain/usecases/access_request/create_request_usecase.dart`

**Rôle** : Crée une nouvelle demande d'accès temporaire

**Signature** :
```dart
Future<Either<Failure, AccessRequestModel>> call({
  required String userId,
  required String zoneId,
  required DateTime startDate,
  required DateTime endDate,
  required String justification,
})
```

**Retours possibles** :
- `Right(AccessRequestModel)` → Succès
- `Left(ValidationFailure)` → Données invalides
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await createRequestUseCase(
  userId: currentUser.id,
  zoneId: 'zone_123',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 7)),
  justification: 'Besoin d\'accès pour maintenance urgente',
);

result.fold(
  (failure) {
    if (failure is ValidationFailure) {
      print('Erreurs: ${failure.fieldErrors}');
    } else {
      print('Erreur: ${failure.message}');
    }
  },
  (request) {
    print('Demande créée avec succès');
    print('Statut: ${request.status}');
  },
);
```

---

## 6️⃣ Dashboard UseCase (1)

### GetKpisUseCase

**Fichier** : `lib/domain/usecases/dashboard/get_kpis_usecase.dart`

**Rôle** : Récupère les KPIs du tableau de bord

**Signature** :
```dart
Future<Either<Failure, DashboardKpisModel>> call({
  required String userId,
})
```

**Retours possibles** :
- `Right(DashboardKpisModel)` → Succès
- `Left(NetworkFailure)` → Erreur réseau

**Exemple d'utilisation** :
```dart
final result = await getKpisUseCase(
  userId: currentUser.id,
);

result.fold(
  (failure) => print('Erreur: ${failure.message}'),
  (kpis) {
    print('Accès cette semaine: ${kpis.weekAccesses}');
    print('Heures aujourd\'hui: ${kpis.todayHours}');
    print('Heures cette semaine: ${kpis.weekHours}');
  },
);
```

---

## 📊 Résumé

### UseCases par catégorie

**Auth** (4 UseCases)
- ✅ LoginUseCase
- ✅ LogoutUseCase
- ✅ GetCachedUserUseCase
- ✅ IsAuthenticatedUseCase

**Access** ⭐ (3 UseCases)
- ✅ VerifyAccessUseCase (avec deviceUnlocked)
- ✅ VerifyPinUseCase
- ✅ GetAccessHistoryUseCase

**Attendance** (4 UseCases)
- ✅ CheckInUseCase
- ✅ CheckOutUseCase
- ✅ GetTodayAttendanceUseCase
- ✅ GetAttendanceHistoryUseCase

**User** (2 UseCases)
- ✅ GetUserUseCase
- ✅ GetAccessZonesUseCase

**Access Request** (2 UseCases)
- ✅ GetMyRequestsUseCase
- ✅ CreateRequestUseCase

**Dashboard** (1 UseCase)
- ✅ GetKpisUseCase

**Total** : **16 UseCases**

---

## 📁 Structure des fichiers

```
lib/domain/usecases/
├── auth/
│   ├── login_usecase.dart                    ✅
│   ├── logout_usecase.dart                   ✅
│   ├── get_cached_user_usecase.dart          ✅
│   └── is_authenticated_usecase.dart         ✅
│
├── access/
│   ├── verify_access_usecase.dart            ✅ ⭐
│   ├── verify_pin_usecase.dart               ✅
│   └── get_access_history_usecase.dart       ✅
│
├── attendance/
│   ├── check_in_usecase.dart                 ✅
│   ├── check_out_usecase.dart                ✅
│   ├── get_today_attendance_usecase.dart     ✅
│   └── get_attendance_history_usecase.dart   ✅
│
├── user/
│   ├── get_user_usecase.dart                 ✅
│   └── get_access_zones_usecase.dart         ✅
│
├── access_request/
│   ├── get_my_requests_usecase.dart          ✅
│   └── create_request_usecase.dart           ✅
│
└── dashboard/
    └── get_kpis_usecase.dart                 ✅
```

---

## 🎯 Points Critiques Implémentés

### ✅ Either<Failure, Success>
- Tous les UseCases utilisent `Either<Failure, Success>`
- Pattern fonctionnel avec dartz
- Gestion d'erreurs explicite avec `.fold()`

### ✅ deviceUnlocked ⭐
- `VerifyAccessUseCase` requiert `deviceUnlocked: true`
- Confirmé par `DeviceUnlockService` avant l'appel
- Envoyé au backend via AccessRepository

### ✅ Dependency Injection
- Tous les UseCases annotés avec `@injectable`
- Prêts pour GetIt configuration
- Injection automatique des repositories

### ✅ Single Responsibility
- Chaque UseCase a une seule responsabilité
- Délègue la logique métier au Repository
- Code maintenable et testable

### ✅ Documentation complète
- Chaque UseCase documenté avec :
  - Rôle
  - Signature
  - Retours possibles
  - Exemples d'utilisation

---

## 🚀 Prochaines Étapes

**Phase 5 : Injection Container**

1. Configurer `injection_container.dart`
2. Enregistrer tous les services
3. Enregistrer tous les APIs
4. Enregistrer tous les repositories
5. Enregistrer tous les UseCases
6. Générer code : `flutter pub run build_runner build --delete-conflicting-outputs`

**Exemple de configuration** :
```dart
@module
abstract class AppModule {
  // Services
  @lazySingleton
  StorageService get storageService;

  // APIs
  @LazySingleton(as: AuthApi)
  AuthApiImpl get authApi;

  // Repositories
  @LazySingleton(as: AuthRepository)
  AuthRepositoryImpl get authRepository;

  // UseCases
  @injectable
  LoginUseCase get loginUseCase;
}
```

---

**UseCases : 100% Complétés** ✅
**16 fichiers créés** 🎉
**Prochaine étape : Injection Container** 🚀
