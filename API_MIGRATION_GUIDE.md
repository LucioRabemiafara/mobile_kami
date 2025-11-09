# Guide de Migration API - Conformité avec API-DOCUMENTATION.md

## 📅 Date : 2025-11-07

## ✅ Fichiers Modifiés

### 1. **access_api.dart** ✅ TERMINÉ
### 2. **attendance_api.dart** ✅ TERMINÉ
### 3. **user_api.dart** ✅ TERMINÉ
### 4. **dashboard_api.dart** ✅ TERMINÉ
### 5. **access_request_api.dart** ✅ TERMINÉ

---

## 🔄 Changements Détaillés par API

### 1. **AccessApi** (lib/data/data_sources/remote/access_api.dart)

#### `verifyAccess()`
**AVANT :**
```dart
Future<AccessVerifyResponseModel> verifyAccess({
  required String userId,
  required String qrCode,
  required bool deviceUnlocked,
});

// Corps :
data: {
  'user_id': userId,
  'qr_code': qrCode,
  'device_unlocked': deviceUnlocked,
}
```

**APRÈS :**
```dart
Future<AccessVerifyResponseModel> verifyAccess({
  required int userId,          // String → int
  required String qrCode,
  String? deviceInfo,           // Nouveau (optionnel)
  String? ipAddress,            // Nouveau (optionnel)
});

// Corps :
data: {
  'userId': userId,             // camelCase
  'qrCode': qrCode,             // camelCase
  if (deviceInfo != null) 'deviceInfo': deviceInfo,
  if (ipAddress != null) 'ipAddress': ipAddress,
}

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>;
return AccessVerifyResponseModel.fromJson(data);
```

#### `verifyPin()`
**AVANT :**
```dart
Future<AccessVerifyResponseModel> verifyPin({
  required String tempToken,
  required String pinCode,
});

// Corps :
data: {
  'temp_token': tempToken,
  'pin_code': pinCode,
}
```

**APRÈS :**
```dart
Future<AccessVerifyResponseModel> verifyPin({
  required int userId,          // Nouveau
  required String pinCode,      // Pas de changement
  required int eventId,         // Remplace tempToken
});

// Corps :
data: {
  'userId': userId,             // camelCase
  'pinCode': pinCode,           // camelCase
  'eventId': eventId,           // camelCase
}

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>;
return AccessVerifyResponseModel.fromJson(data);
```

#### `getAccessHistory()`
**AVANT :**
```dart
Future<List<AccessEventModel>> getAccessHistory({
  required String userId,
  DateTime? startDate,
  DateTime? endDate,
});

// Query params :
queryParams['dateStart'] = startDate.toIso8601String().split('T')[0];
```

**APRÈS :**
```dart
Future<List<AccessEventModel>> getAccessHistory({
  required int userId,                  // String → int
  DateTime? startDate,
  DateTime? endDate,
});

// Query params :
queryParams['dateStart'] = startDate.toIso8601String();  // Format complet

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final List<dynamic> data = responseData['data'] as List<dynamic>;
return data.map((json) => AccessEventModel.fromJson(json)).toList();
```

---

### 2. **AttendanceApi** (lib/data/data_sources/remote/attendance_api.dart)

#### `checkIn()`
**AVANT :**
```dart
Future<AttendanceModel> checkIn({
  required String userId,
  required String qrCode,
  required String pinCode,
});

// Corps :
data: {
  'user_id': userId,
  'qr_code': qrCode,
  'pin_code': pinCode,
}
```

**APRÈS :**
```dart
Future<AttendanceModel> checkIn({
  required int userId,              // String → int
  required String qrCode,
  required String pinCode,
  required DateTime checkInTime,    // Nouveau (obligatoire)
  String? location,                 // Nouveau (optionnel)
});

// Corps :
data: {
  'userId': userId,                          // camelCase
  'qrCode': qrCode,                          // camelCase
  'pinCode': pinCode,                        // camelCase
  'checkInTime': checkInTime.toIso8601String(),
  if (location != null) 'location': location,
}

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>;
return AttendanceModel.fromJson(data);
```

#### `checkOut()`
**AVANT :**
```dart
Future<AttendanceModel> checkOut({
  required String userId,
  required String qrCode,
  required String pinCode,
});
```

**APRÈS :**
```dart
Future<AttendanceModel> checkOut({
  required int userId,              // String → int
  required String qrCode,
  required String pinCode,
  required DateTime checkOutTime,   // Nouveau (obligatoire)
  String? location,                 // Nouveau (optionnel)
});

// Corps identique à checkIn avec checkOutTime
```

#### `getAttendanceToday()`
**AVANT :**
```dart
Future<AttendanceModel?> getAttendanceToday({
  required String userId,
});
```

**APRÈS :**
```dart
Future<AttendanceModel?> getAttendanceToday({
  required int userId,              // String → int
});

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>?;
return data != null ? AttendanceModel.fromJson(data) : null;
```

#### `getAttendanceHistory()`
**AVANT :**
```dart
Future<List<AttendanceModel>> getAttendanceHistory({
  required String userId,
  required String month,        // Format: yyyy-MM
});

// Query params :
queryParameters: {
  'userId': userId,
  'month': month,
}
```

**APRÈS :**
```dart
Future<List<AttendanceModel>> getAttendanceHistory({
  required int userId,          // String → int
  DateTime? startDate,          // Remplace month
  DateTime? endDate,            // Nouveau
});

// Query params :
queryParams['startDate'] = startDate.toIso8601String().split('T')[0];  // YYYY-MM-DD
queryParams['endDate'] = endDate.toIso8601String().split('T')[0];      // YYYY-MM-DD

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final List<dynamic> data = responseData['data'] as List<dynamic>;
return data.map((json) => AttendanceModel.fromJson(json)).toList();
```

---

### 3. **UserApi** (lib/data/data_sources/remote/user_api.dart)

#### `getUser()`
**AVANT :**
```dart
Future<UserModel> getUser(String userId);
```

**APRÈS :**
```dart
Future<UserModel> getUser(int userId);  // String → int

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>;
return UserModel.fromJson(data);
```

#### `getAccessZones()`
**AVANT :**
```dart
Future<List<Map<String, dynamic>>> getAccessZones(String userId);

// Retour :
final List<dynamic> data = response.data as List<dynamic>;
return data.cast<Map<String, dynamic>>();
```

**APRÈS :**
```dart
Future<List<ZoneModel>> getAccessZones(int userId);  // String → int, Type de retour changé

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final List<dynamic> data = responseData['data'] as List<dynamic>;
return data.map((json) => ZoneModel.fromJson(json)).toList();
```

---

### 4. **DashboardApi** (lib/data/data_sources/remote/dashboard_api.dart)

#### `getKpis()`
**AVANT :**
```dart
Future<DashboardKpisModel> getKpis(String userId);

// Appel :
final response = await _dioClient.get(
  ApiEndpoints.dashboardKpis,
  queryParameters: {
    'userId': userId,
  },
);
```

**APRÈS :**
```dart
Future<DashboardKpisModel> getKpis();  // Paramètre userId supprimé

// Appel :
final response = await _dioClient.get(
  ApiEndpoints.dashboardKpis,
  // Pas de query parameters
);

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>;
return DashboardKpisModel.fromJson(data);
```

---

### 5. **AccessRequestApi** (lib/data/data_sources/remote/access_request_api.dart)

#### `getMyRequests()`
**AVANT :**
```dart
Future<List<AccessRequestModel>> getMyRequests(String userId);
```

**APRÈS :**
```dart
Future<List<AccessRequestModel>> getMyRequests(int userId);  // String → int

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final List<dynamic> data = responseData['data'] as List<dynamic>;
return data.map((json) => AccessRequestModel.fromJson(json)).toList();
```

#### `createRequest()`
**AVANT :**
```dart
Future<AccessRequestModel> createRequest({
  required String userId,
  required String zoneId,
  required DateTime startDate,
  required DateTime endDate,
  required String justification,
});

// Corps :
data: {
  'userId': userId,
  'zoneId': zoneId,
  'startDate': startDate.toIso8601String().split('T')[0],  // Date seulement
  'endDate': endDate.toIso8601String().split('T')[0],      // Date seulement
  'justification': justification,
}
```

**APRÈS :**
```dart
Future<AccessRequestModel> createRequest({
  required int userId,          // String → int
  required int zoneId,          // String → int
  required DateTime startDate,
  required DateTime endDate,
  required String justification,
});

// Corps :
data: {
  'userId': userId,
  'zoneId': zoneId,
  'startDate': startDate.toIso8601String(),     // Format ISO DateTime complet
  'endDate': endDate.toIso8601String(),         // Format ISO DateTime complet
  'justification': justification,
}

// Format réponse :
final responseData = response.data as Map<String, dynamic>;
final data = responseData['data'] as Map<String, dynamic>;
return AccessRequestModel.fromJson(data);
```

---

## 🎯 Format de Réponse Standard

**Toutes les APIs retournent maintenant :**
```json
{
  "success": true,
  "message": "Message de succès",
  "data": {
    // Données réelles ici (objet ou tableau)
  },
  "errors": null,
  "timestamp": "2025-11-07T10:30:00.123456"
}
```

**Le code lit maintenant `responseData['data']` au lieu de `response.data` directement.**

---

## ⚠️ Impacts sur les Autres Fichiers

### Fichiers à Mettre à Jour

#### 1. **Repositories** (lib/data/repositories/)
Les repositories qui appellent ces APIs doivent être mis à jour pour passer des `int` au lieu de `String` pour les IDs.

**Exemple de changement nécessaire :**
```dart
// AVANT
await _accessApi.verifyAccess(
  userId: user.id.toString(),  // ❌
  qrCode: qrCode,
  deviceUnlocked: true,
);

// APRÈS
await _accessApi.verifyAccess(
  userId: user.id,  // ✅ int directement
  qrCode: qrCode,
  deviceInfo: 'Mobile Android',
  ipAddress: '192.168.1.100',
);
```

#### 2. **Use Cases** (lib/domain/usecases/)
Les use cases doivent être adaptés pour les nouveaux paramètres.

**Exemple : VerifyAccessUseCase**
```dart
// AVANT
final result = await _verifyAccessUseCase(
  userId: userId.toString(),
  qrCode: qrCode,
  deviceUnlocked: true,
);

// APRÈS
final result = await _verifyAccessUseCase(
  userId: userId,  // int
  qrCode: qrCode,
  deviceInfo: deviceInfo,
  ipAddress: ipAddress,
);
```

#### 3. **BLoCs** (lib/presentation/blocs/)
Les blocs qui interagissent avec ces use cases doivent passer les bons types.

**Exemple : AccessBloc**
```dart
// Dans _onQRCodeScanned
// AVANT
final result = await _verifyAccessUseCase(
  userId: userId,
  qrCode: event.qrCode,
  deviceUnlocked: true,
);

// APRÈS
final result = await _verifyAccessUseCase(
  userId: userId,  // Déjà int si authState.user.id est int
  qrCode: event.qrCode,
  deviceInfo: 'Mobile ${Platform.operatingSystem}',
  ipAddress: null,
);
```

#### 4. **Models** (lib/data/models/ & lib/domain/entities/)
Vérifier que les models parsent correctement le format de réponse standard avec `data`.

**Vérifier que les champs suivants sont `int` :**
- `user.id`
- `zone.id`
- `accessRequest.userId`
- `accessRequest.zoneId`
- `attendance.userId`
- `accessEvent.userId`
- `accessEvent.zoneId`

---

## 📝 Checklist de Migration

### Phase 1 : Vérification des Types ✅
- [x] AccessApi adapté
- [x] AttendanceApi adapté
- [x] UserApi adapté
- [x] DashboardApi adapté
- [x] AccessRequestApi adapté
- [x] Format de réponse standard implémenté partout

### Phase 2 : Adaptation des Repositories ⏳
- [ ] access_repository.dart
- [ ] attendance_repository.dart
- [ ] user_repository.dart
- [ ] dashboard_repository.dart
- [ ] access_request_repository.dart

### Phase 3 : Adaptation des Use Cases ⏳
- [ ] verify_access_usecase.dart
- [ ] verify_pin_usecase.dart
- [ ] check_in_usecase.dart
- [ ] check_out_usecase.dart
- [ ] get_attendance_history_usecase.dart
- [ ] get_dashboard_kpis_usecase.dart

### Phase 4 : Adaptation des BLoCs ⏳
- [ ] access_bloc.dart
- [ ] attendance_bloc.dart
- [ ] dashboard_bloc.dart

### Phase 5 : Tests ⏳
- [ ] Compiler le projet : `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Tester les appels API avec le backend
- [ ] Vérifier que toutes les réponses sont correctement parsées

---

## 🚀 Commandes Utiles

### Régénérer les fichiers générés
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Analyser le code
```bash
flutter analyze
```

### Compiler en mode debug
```bash
flutter run
```

---

## ⚠️ Notes Importantes

1. **Login inchangé** : Le processus d'authentification (`auth_api.dart`) n'a pas été modifié comme demandé

2. **IDs sont maintenant int** : Tous les IDs (userId, zoneId, eventId) sont maintenant de type `int` au lieu de `String`

3. **Dates en ISO 8601** :
   - Format complet pour les timestamps : `2025-11-07T10:30:00`
   - Format date uniquement pour les filtres attendance : `2025-11-07`

4. **Noms en camelCase** : Plus d'underscores dans les noms de champs JSON (`userId` au lieu de `user_id`)

5. **Format de réponse wrappé** : Toutes les réponses sont wrappées dans `{ success, message, data, errors, timestamp }`

---

## 📞 Support

Si vous rencontrez des problèmes lors de la migration :
1. Vérifiez que tous les models ont les bons types (`int` pour les IDs)
2. Vérifiez que le backend retourne bien le format de réponse standard
3. Utilisez `flutter analyze` pour détecter les erreurs de type
4. Consultez la documentation API : `API-DOCUMENTATION.md`

---

**Généré le : 2025-11-07**
**Statut : ✅ APIs adaptées - En attente de migration des repositories/use cases/blocs**
