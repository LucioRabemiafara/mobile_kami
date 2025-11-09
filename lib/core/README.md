# 📦 Core Layer - Infrastructure & Services

## 🏗️ Structure

```
core/
├── api/                    ✅ CRÉÉ
│   ├── dio_client.dart           # Configuration HTTP Dio
│   ├── api_interceptors.dart     # Interceptors (Auth, Logging, Timeout, Network)
│   └── api_endpoints.dart        # Toutes les URLs des endpoints
│
├── constants/              ✅ CRÉÉ
│   ├── app_constants.dart        # Constantes application
│   ├── colors.dart               # Palette couleurs
│   └── text_styles.dart          # Styles de texte
│
├── errors/                 ✅ CRÉÉ
│   ├── exceptions.dart           # Exceptions (DeviceUnlockException, etc.)
│   └── failures.dart             # Failures (Either<Failure, Success>)
│
├── services/               ✅ CRÉÉ
│   ├── storage_service.dart      # Stockage sécurisé (FlutterSecureStorage)
│   ├── device_unlock_service.dart # Déverrouillage natif téléphone (local_auth)
│   └── notification_service.dart  # Notifications (SnackBars, Dialogs)
│
└── utils/                  ✅ CRÉÉ
    ├── formatters.dart           # Formatters (dates, heures, etc.)
    ├── validators.dart           # Validators (formulaires)
    └── helpers.dart              # Fonctions helper
```

---

## 📚 Services Disponibles

### 1. StorageService

**Rôle** : Stockage sécurisé des tokens JWT et données utilisateur

**Usage** :
```dart
final storageService = sl<StorageService>();

// Save tokens
await storageService.saveAccessToken(token);
await storageService.saveRefreshToken(refreshToken);
await storageService.saveUser(userJson);

// Get tokens
final accessToken = await storageService.getAccessToken();
final refreshToken = await storageService.getRefreshToken();
final userJson = await storageService.getUser();

// Check
final hasToken = await storageService.hasToken();

// Clear all (logout)
await storageService.clear();
```

---

### 2. DeviceUnlockService ⭐ CRITIQUE

**Rôle** : Vérification du déverrouillage NATIF du téléphone

**Important** :
- `biometricOnly: false` → Accepte TOUTES les méthodes
- Empreinte, Face, Schéma, PIN, Mot de passe

**Usage** :
```dart
final deviceUnlockService = sl<DeviceUnlockService>();

// Check if device supports unlock
final canCheck = await deviceUnlockService.canCheckDeviceUnlock();

// Authenticate
try {
  final authenticated = await deviceUnlockService.authenticate(
    localizedReason: 'Déverrouillez votre téléphone pour continuer',
  );

  if (authenticated) {
    // Send device_unlocked: true to backend
    print('✅ Device unlocked!');
  } else {
    // User cancelled
    print('❌ User cancelled');
  }
} on DeviceUnlockException catch (e) {
  print('❌ Error: ${e.message}');
}

// Get available methods
final methods = await deviceUnlockService.getAvailableMethodsAsStrings();
print('Available: $methods');
```

---

### 3. DioClient

**Rôle** : Configuration du client HTTP

**Usage** :
```dart
final dioClient = sl<DioClient>();

// Add interceptor
dioClient.addInterceptor(authInterceptor);

// Use Dio
final response = await dioClient.dio.get('/users/123');
```

---

### 4. AuthInterceptor ⭐ CRITIQUE

**Rôle** : Gestion automatique des tokens JWT

**Features** :
1. Ajoute automatiquement `Bearer token` à toutes les requêtes
2. Refresh automatique sur 401
3. Retry requête originale après refresh
4. Logout si refresh échoue

**Usage** :
```dart
// Setup once in DI
final dioClient = sl<DioClient>();
final authInterceptor = sl<AuthInterceptor>();
dioClient.addInterceptor(authInterceptor);

// Now all requests automatically:
// 1. Add Bearer token
// 2. Refresh on 401
// 3. Retry original request
```

**Flow** :
```
Request → Add Bearer token → Send
  ↓
401 Error → Refresh token → Save new token → Retry request → Success
  ↓
Refresh failed → Clear storage → Logout
```

---

### 5. NotificationService

**Rôle** : Affichage de notifications

**Usage** :
```dart
final notificationService = sl<NotificationService>();

// Success
notificationService.showSuccessSnackBar(context, 'Accès autorisé !');

// Error
notificationService.showErrorSnackBar(context, 'Code PIN incorrect');

// Warning
notificationService.showWarningSnackBar(context, 'Attention !');

// Info
notificationService.showInfoSnackBar(context, 'Information');

// Alert Dialog
await notificationService.showAlertDialog(
  context,
  title: 'Erreur',
  message: 'Une erreur est survenue',
);

// Confirmation Dialog
final confirmed = await notificationService.showConfirmationDialog(
  context,
  title: 'Déconnexion',
  message: 'Voulez-vous vraiment vous déconnecter ?',
);

if (confirmed) {
  // Logout
}

// Loading Dialog
notificationService.showLoadingDialog(context, message: 'Chargement...');
// ... async operation ...
notificationService.hideLoadingDialog(context);
```

---

## 🔧 Utils

### Formatters

```dart
// Dates
Formatters.formatDate(DateTime.now()); // 15/07/2025
Formatters.formatDateLong(DateTime.now()); // Lundi 15 Juillet 2025
Formatters.formatTime(DateTime.now()); // 14:30

// Duration
Formatters.formatDuration(Duration(hours: 9, minutes: 15)); // 9h 15m
Formatters.formatHours(9.25); // 9h 15m

// Posts (MULTI-POSTES)
Formatters.formatPostsList(['DEVELOPER', 'DEVOPS']); // "Dev • DevOps"
Formatters.formatPostName('DEVELOPER'); // "Dev"

// Status
Formatters.formatSecurityLevel('LOW'); // "Faible"
Formatters.formatAccessStatus('GRANTED'); // "Autorisé"
Formatters.formatRequestStatus('PENDING'); // "En attente"

// Relative time
Formatters.formatRelativeTime(DateTime.now().subtract(Duration(minutes: 5)));
// "Il y a 5 minutes"

// Greeting
Formatters.getGreeting(); // "Bonjour" / "Bon après-midi" / "Bonsoir"
```

### Validators

```dart
// Email
final emailError = Validators.validateEmail('test@example.com');
if (emailError != null) {
  print(emailError); // "Format d'email invalide"
}

// Password
final passwordError = Validators.validatePassword('123456');

// PIN (4 digits)
final pinError = Validators.validatePin('1234');

// Required
final error = Validators.validateRequired(value, fieldName: 'Email');

// Length
final error = Validators.validateLength(
  value,
  minLength: 20,
  maxLength: 500,
  fieldName: 'Justification',
);

// Justification (20-500 chars)
final error = Validators.validateJustification(value);

// Date range
final error = Validators.validateDateRange(startDate, endDate);

// Bool checks
final isValid = Validators.isValidEmail('test@example.com');
final isValid = Validators.isValidPin('1234');
```

### Helpers

```dart
// SnackBars (wrapper sur NotificationService)
Helpers.showSuccessSnackBar(context, 'Success!');
Helpers.showErrorSnackBar(context, 'Error!');

// Dialogs
await Helpers.showAlertDialog(context, title: 'Title', message: 'Message');
final confirmed = await Helpers.showConfirmationDialog(
  context,
  title: 'Confirmation',
  message: 'Are you sure?',
);

// Haptic Feedback
Helpers.triggerSuccessFeedback(); // Vibration success
Helpers.triggerErrorFeedback(); // Vibration error
Helpers.triggerHapticFeedback(type: HapticFeedbackType.light);

// Keyboard
Helpers.hideKeyboard(context);

// Navigation
Helpers.navigateTo(context, '/dashboard');
Helpers.navigateAndRemoveUntil(context, '/login');
Helpers.goBack(context, result: data);
Helpers.popUntilFirst(context);

// Initials
Helpers.getInitials('Jean Dupont'); // "JD"

// Dates
Helpers.isToday(date); // bool
Helpers.isLate(time); // bool (after 9:00)
Helpers.calculateHoursWorked(checkIn, checkOut); // 9.25

// Access (MULTI-POSTES)
final hasAccess = Helpers.hasAccessToZone(
  ['DEVELOPER', 'DEVOPS'],  // user.posts
  ['DEVELOPER', 'SECURITY'], // zone.allowedPosts
); // true (DEVELOPER match)

final matchingPost = Helpers.getFirstMatchingPost(
  ['ACCOUNTANT', 'HR_MANAGER'],
  ['DEVELOPER', 'DEVOPS'],
); // null (no match)

// Account locked
Helpers.isAccountLocked(lockedUntil); // bool
Helpers.getRemainingLockTime(lockedUntil); // Duration?

// Clipboard
Helpers.copyToClipboard('Text to copy');
```

---

## 🎨 Constants

### AppConstants

```dart
// API
AppConstants.baseUrl // 'http://localhost:8080/api'
AppConstants.loginEndpoint // '/auth/login'
AppConstants.verifyAccessEndpoint // '/access/verify'

// Storage Keys
AppConstants.accessTokenKey // 'access_token'
AppConstants.refreshTokenKey // 'refresh_token'
AppConstants.userDataKey // 'user_data'

// Security
AppConstants.pinLength // 4
AppConstants.maxPinAttempts // 3
AppConstants.accountLockDuration // Duration(minutes: 30)

// Posts (MULTI-POSTES)
AppConstants.availablePosts // ['DEVELOPER', 'DEVOPS', ...]

// Security Levels
AppConstants.securityLevelLow // 'LOW'
AppConstants.securityLevelMedium // 'MEDIUM'
AppConstants.securityLevelHigh // 'HIGH'

// Status
AppConstants.accessStatusGranted // 'GRANTED'
AppConstants.accessStatusPendingPin // 'PENDING_PIN'
AppConstants.accessStatusDenied // 'DENIED'
```

### AppColors

```dart
// Primary
AppColors.primary // Bleu
AppColors.secondary // Vert

// Status
AppColors.success // Vert
AppColors.error // Rouge
AppColors.warning // Orange

// Security Levels
AppColors.securityLow // Vert clair
AppColors.securityMedium // Orange clair
AppColors.securityHigh // Rouge clair

// Backgrounds
AppColors.background // Gris clair
AppColors.surface // Blanc
AppColors.accessGrantedBackground // Vert très clair
AppColors.accessDeniedBackground // Rouge très clair

// Helpers
AppColors.getSecurityLevelColor('LOW'); // Color
AppColors.getRequestStatusColor('PENDING'); // Color
AppColors.getAttendanceStatusColor(isLate); // Color
```

### AppTextStyles

```dart
// Headlines
AppTextStyles.headline1 // 32px, bold
AppTextStyles.headline2 // 24px, bold

// Body
AppTextStyles.bodyLarge // 16px
AppTextStyles.bodyMedium // 14px

// Special
AppTextStyles.button // Button text
AppTextStyles.kpiValue // KPI value (32px, bold)
AppTextStyles.timeDisplay // Time display (48px, bold)
AppTextStyles.pinNumber // PIN number (32px, bold)

// Helpers
AppTextStyles.withColor(style, color);
AppTextStyles.withSize(style, 20);
```

---

## 🚨 Errors

### Exceptions

```dart
throw ServerException(message: 'Error', statusCode: 500);
throw NetworkException();
throw UnauthorizedException();
throw DeviceUnlockException(reason: 'Failed');
throw StorageException(message: 'Failed');
throw QRCodeException();
throw InvalidPinException(attemptsRemaining: 2);
throw AccountLockedException(lockedUntil: DateTime.now().add(Duration(minutes: 30)));
```

### Failures (for Either<Failure, Success>)

```dart
const ServerFailure(message: 'Error', statusCode: 500);
const NetworkFailure();
const UnauthorizedFailure();
const DeviceUnlockFailure(reason: 'Failed');
const StorageFailure();
const QRCodeFailure();
const InvalidPinFailure(attemptsRemaining: 2);
const AccountLockedFailure(lockedUntil: ...);
const GenericFailure();
```

---

## 🔗 API Endpoints

```dart
ApiEndpoints.login // '/auth/login'
ApiEndpoints.refresh // '/auth/refresh'
ApiEndpoints.verifyAccess // '/access/verify'
ApiEndpoints.verifyPin // '/access/verify-pin'
ApiEndpoints.checkIn // '/attendance/check-in'
ApiEndpoints.checkOut // '/attendance/check-out'
ApiEndpoints.dashboardKpis // '/dashboard/kpis'

// Helpers
ApiEndpoints.buildUrl('/auth/login');
ApiEndpoints.buildUrlWithParams('/users/{id}', {'id': '123'});
ApiEndpoints.buildUrlWithQuery('/access/history', {'userId': '123'});
```

---

## ✅ Services Core : 100% Complétés

Tous les services core sont prêts et testés. Prochaine étape : Models & Data.
