# 📦 Models (Data Layer)

## 🎯 Qu'est-ce qu'un Model ?

Les **Models** sont des classes de données dans la couche **Data Layer** :
- Utilisent **Freezed** pour l'immutabilité et le pattern `copyWith()`
- Utilisent **json_serializable** pour la sérialisation JSON automatique
- Communiquent avec l'API (fromJson / toJson)
- Sont convertis en **Entities** pour la couche Domain

---

## 📁 Models Disponibles (8)

### 1. UserModel ⭐ MULTI-POSTES

**Fichier** : `user_model.dart`

**Champs critiques** :
- **`posts: List<String>`** ⭐ Un utilisateur peut avoir PLUSIEURS postes

**Exemple** :
```dart
final user = UserModel(
  id: '1',
  email: 'john@example.com',
  firstName: 'John',
  lastName: 'Doe',
  role: 'EMPLOYEE',
  posts: ['DEVELOPER', 'DEVOPS'], // ⭐ LISTE
  department: 'IT',
  isActive: true,
  isAdmin: false,
);
```

---

### 2. ZoneModel ⭐ MULTI-POSTES

**Fichier** : `zone_model.dart`

**Champs critiques** :
- **`allowedPosts: List<String>`** ⭐ Une zone peut autoriser PLUSIEURS postes
- `securityLevel` : LOW, MEDIUM, HIGH
- `isOpenToAll` : Si true, zone ouverte à tous

**Exemple** :
```dart
final zone = ZoneModel(
  id: '1',
  name: 'Salle des Serveurs',
  building: 'Bâtiment A',
  floor: 3,
  securityLevel: 'HIGH',
  qrCode: 'QR_ZONE_001',
  isActive: true,
  isOpenToAll: false,
  allowedPosts: ['DEVELOPER', 'DEVOPS'], // ⭐ LISTE
);
```

---

### 3. AccessVerifyResponseModel

**Fichier** : `access_verify_response_model.dart`

**Réponse de** : `POST /access/verify`

**Status possibles** :
- `GRANTED` : Accès autorisé
- `PENDING_PIN` : PIN requis
- `DENIED` : Accès refusé

**Exemple GRANTED** :
```dart
final response = AccessVerifyResponseModel(
  status: 'GRANTED',
  message: 'Accès autorisé',
  zone: zoneModel,
  requiresPin: false,
);
```

**Exemple PENDING_PIN** :
```dart
final response = AccessVerifyResponseModel(
  status: 'PENDING_PIN',
  message: 'Code PIN requis',
  zone: zoneModel,
  requiresPin: true,
  tempToken: 'temp_token_123', // Valide 5 minutes
);
```

**Exemple DENIED** :
```dart
final response = AccessVerifyResponseModel(
  status: 'DENIED',
  message: 'Accès refusé',
  zone: zoneModel,
  reason: 'Vos postes [ACCOUNTANT] non autorisés',
  canRequestAccess: true,
);
```

---

### 4. AccessEventModel ⭐ deviceUnlocked

**Fichier** : `access_event_model.dart`

**Champs critiques** :
- **`deviceUnlocked: bool`** ⭐ Confirmé par l'app mobile

**Exemple** :
```dart
final event = AccessEventModel(
  id: '1',
  userId: 'user_123',
  zoneId: 'zone_456',
  timestamp: DateTime.now(),
  status: 'GRANTED',
  method: 'QR_PIN',
  deviceUnlocked: true, // ⭐ Téléphone déverrouillé
);
```

---

### 5. AttendanceModel

**Fichier** : `attendance_model.dart`

**Exemple** :
```dart
final attendance = AttendanceModel(
  id: '1',
  userId: 'user_123',
  date: DateTime(2025, 7, 15),
  checkIn: DateTime(2025, 7, 15, 8, 45),
  checkOut: DateTime(2025, 7, 15, 18, 0),
  hoursWorked: 9.25,
  isLate: false,
);
```

---

### 6. AccessRequestModel

**Fichier** : `access_request_model.dart`

**Exemple** :
```dart
final request = AccessRequestModel(
  id: '1',
  user: userModel,
  zone: zoneModel,
  startDate: DateTime(2025, 7, 15),
  endDate: DateTime(2025, 7, 20),
  justification: 'Maintenance serveurs',
  status: 'PENDING',
);
```

---

### 7. DashboardKpisModel

**Fichier** : `dashboard_kpis_model.dart`

**Sous-model** : `DayHoursModel`

**Exemple** :
```dart
final kpis = DashboardKpisModel(
  hoursThisMonth: 152.5,
  accessibleZones: 28,
  accessesToday: 5,
  checkedInToday: true,
  last7DaysHours: [
    DayHoursModel(date: '2025-07-09', hours: 8.5),
    DayHoursModel(date: '2025-07-10', hours: 9.0),
  ],
);
```

---

### 8. AuthResponseModel

**Fichier** : `auth_response_model.dart`

**Réponse de** : `POST /auth/login`

**Exemple** :
```dart
final authResponse = AuthResponseModel(
  accessToken: 'jwt_access_token',
  refreshToken: 'jwt_refresh_token',
  user: userModel,
);
```

---

## 🔧 Génération du Code

### Commande

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Fichiers générés

Pour chaque model, 2 fichiers sont générés :
- `xxx_model.freezed.dart` : Code Freezed
- `xxx_model.g.dart` : Code JSON

**Total** : 8 models × 2 = **16 fichiers générés**

### Vérifier la génération

Après build_runner, vérifiez que les fichiers existent :
```
user_model.freezed.dart
user_model.g.dart
zone_model.freezed.dart
zone_model.g.dart
...
```

---

## 📖 Utilisation

### Créer une instance

```dart
final user = UserModel(
  id: '1',
  email: 'john@example.com',
  firstName: 'John',
  lastName: 'Doe',
  role: 'EMPLOYEE',
  posts: ['DEVELOPER', 'DEVOPS'],
  department: 'IT',
  isActive: true,
  isAdmin: false,
);
```

### Modifier (immutabilité avec copyWith)

```dart
final updatedUser = user.copyWith(
  firstName: 'Jane',
  posts: [...user.posts, 'IT_SUPPORT'],
);
```

### Sérialiser vers JSON

```dart
final json = user.toJson();
// {
//   "id": "1",
//   "email": "john@example.com",
//   "firstName": "John",
//   "lastName": "Doe",
//   "role": "EMPLOYEE",
//   "posts": ["DEVELOPER", "DEVOPS"],
//   ...
// }
```

### Désérialiser depuis JSON

```dart
final user = UserModel.fromJson(json);
```

### Comparer

Freezed génère automatiquement `==` et `hashCode` :

```dart
final user1 = UserModel(...);
final user2 = UserModel(...);

if (user1 == user2) {
  // Même contenu
}
```

---

## ⭐ Points Critiques

### MULTI-POSTES
- ✅ `UserModel.posts` est `List<String>` (PAS `String`)
- ✅ `ZoneModel.allowedPosts` est `List<String>` (PAS `String`)

### deviceUnlocked
- ✅ `AccessEventModel.deviceUnlocked` est `bool`
- ✅ Envoyé au backend pour confirmation

### Status Values
- AccessVerifyResponseModel : `GRANTED`, `PENDING_PIN`, `DENIED`
- AccessRequestModel : `PENDING`, `APPROVED`, `REJECTED`
- ZoneModel.securityLevel : `LOW`, `MEDIUM`, `HIGH`

---

## 🔄 Conversion vers Entities

Les Models (data) sont convertis en Entities (domain) dans les Repositories.

**Exemple** :
```dart
// Model → Entity
User toEntity(UserModel model) {
  return User(
    id: model.id,
    email: model.email,
    firstName: model.firstName,
    lastName: model.lastName,
    role: model.role,
    posts: model.posts,
    department: model.department,
    isActive: model.isActive,
    isAdmin: model.isAdmin,
    photoUrl: model.photoUrl,
    hireDate: model.hireDate,
    createdAt: model.createdAt,
  );
}
```

---

## 📚 Documentation

- **BUILD_RUNNER.md** : Instructions complètes build_runner
- **MODELS_COMPLETE.md** : Documentation complète de tous les models
- **domain/entities/README.md** : Documentation des entities

---

**Models : 100% Complétés** ✅
**Prochaine étape : APIs & Repositories** 🚀
