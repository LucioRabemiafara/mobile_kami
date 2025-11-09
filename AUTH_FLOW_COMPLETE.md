# ✅ Auth Flow - Implémentation Complète

## 🎉 Ce qui a été créé

Authentification complète avec AuthBloc, SplashScreen et LoginScreen !

---

## 📦 AuthBloc (Pattern BLoC)

### Structure

```
presentation/blocs/auth/
├── auth_event.dart    ✅ (3 events)
├── auth_state.dart    ✅ (5 states)
└── auth_bloc.dart     ✅ (logique complète)
```

---

### 1️⃣ auth_event.dart

**3 Events créés** :

✅ **AppStarted**
```dart
const AppStarted()
```
- Dispatché au démarrage de l'app (SplashScreen)
- Vérifie si user déjà authentifié (token existe)
- Récupère user caché si token valide

✅ **LoginRequested**
```dart
LoginRequested({
  required String email,
  required String password,
})
```
- Dispatché quand user clique "Se connecter"
- Appelle LoginUseCase
- Stocke tokens et user si succès

✅ **LogoutRequested**
```dart
const LogoutRequested()
```
- Dispatché quand user clique logout
- Clear tokens et user du storage
- Appelle API logout

---

### 2️⃣ auth_state.dart

**5 States créés** :

✅ **AuthInitial**
- État initial de l'app
- Statut d'authentification inconnu

✅ **AuthLoading**
- Opération en cours (login, logout, vérification token)
- Affiche loading spinner

✅ **AuthAuthenticated(user)**
```dart
AuthAuthenticated(UserModel user)
```
- User authentifié avec succès
- Contient les données user complètes
- Navigate vers Dashboard

✅ **AuthUnauthenticated**
- User pas authentifié
- Navigate vers LoginScreen

✅ **AuthError(message)**
```dart
AuthError(String message)
```
- Erreur d'authentification
- Affiche message user-friendly
- Puis retourne à AuthUnauthenticated

---

### 3️⃣ auth_bloc.dart

**Dépendances** :
- `LoginUseCase` : Authentification
- `LogoutUseCase` : Déconnexion
- `GetCachedUserUseCase` : Récupère user du cache
- `IsAuthenticatedUseCase` : Vérifie si token existe

**3 Event Handlers** :

#### _onAppStarted

**Flow** :
```
1. emit AuthLoading
2. Vérifie si token existe (IsAuthenticatedUseCase)
3. Si non → emit AuthUnauthenticated
4. Si oui → Récupère user caché (GetCachedUserUseCase)
5. Si user trouvé → emit AuthAuthenticated(user)
6. Si user pas trouvé → emit AuthUnauthenticated
```

**Code** :
```dart
Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
  emit(const AuthLoading());

  final isAuthenticated = await _isAuthenticatedUseCase();

  if (!isAuthenticated) {
    emit(const AuthUnauthenticated());
    return;
  }

  final result = await _getCachedUserUseCase();

  result.fold(
    (failure) => emit(const AuthUnauthenticated()),
    (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    },
  );
}
```

---

#### _onLoginRequested

**Flow** :
```
1. emit AuthLoading (affiche spinner)
2. Appelle LoginUseCase(email, password)
3. Si succès → emit AuthAuthenticated(user)
4. Si échec → emit AuthError(message) puis AuthUnauthenticated
```

**Gestion d'erreurs** :
- Convertit Failures techniques en messages user-friendly
- Utilise `_mapFailureToMessage()`

**Code** :
```dart
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
  emit(const AuthLoading());

  final result = await _loginUseCase(
    email: event.email,
    password: event.password,
  );

  result.fold(
    (failure) {
      final errorMessage = _mapFailureToMessage(failure);
      emit(AuthError(errorMessage));
      emit(const AuthUnauthenticated());
    },
    (user) {
      emit(AuthAuthenticated(user));
    },
  );
}
```

---

#### _onLogoutRequested

**Flow** :
```
1. emit AuthLoading
2. Appelle LogoutUseCase (clear storage + API call)
3. emit AuthUnauthenticated
```

**Code** :
```dart
Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
  emit(const AuthLoading());
  await _logoutUseCase();
  emit(const AuthUnauthenticated());
}
```

---

#### _mapFailureToMessage

**Messages user-friendly** :

| Failure | Message |
|---------|---------|
| `UnauthorizedFailure` | "Email ou mot de passe incorrect" |
| `AccountLockedFailure` | "Compte bloqué pendant X minutes" |
| `ForbiddenFailure` | "Compte inactif. Contactez l'administrateur." |
| `NetworkFailure` | "Pas de connexion internet" |
| `TimeoutFailure` | "Délai d'attente dépassé. Réessayez." |
| `ServerFailure` | "Erreur serveur. Réessayez plus tard." |
| Autre | Message du failure ou "Une erreur est survenue" |

**Gestion spéciale AccountLockedFailure** :
```dart
if (failure is AccountLockedFailure) {
  final lockedUntil = failure.lockedUntil;
  final duration = lockedUntil.difference(now);
  final minutes = duration.inMinutes;

  if (minutes > 60) {
    return 'Compte bloqué pendant ${(minutes / 60).ceil()} heures';
  } else {
    return 'Compte bloqué pendant $minutes minutes';
  }
}
```

---

## 📱 SplashScreen

**Fichier** : `lib/presentation/screens/splash/splash_screen.dart`

### Rôle

Écran de démarrage qui vérifie si user déjà connecté.

### Design

**Fond** : Bleu (AppColors.primary)

**Contenu** :
- Logo centré (cercle blanc avec icône lock)
  - Width/Height : 140px
  - Border radius : 28px
  - Shadow
- Titre : "Access Control" (36px, bold, blanc)
- Sous-titre : "Système de Gestion d'Accès" (16px, blanc 90%)
- CircularProgressIndicator (blanc, 45px)
- Texte : "Initialisation..." (15px, blanc 85%)

### Logique

**initState** :
```dart
@override
void initState() {
  super.initState();
  context.read<AuthBloc>().add(const AppStarted());
}
```

**BlocListener** :
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // Navigate to Dashboard (placeholder pour l'instant)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _PlaceholderDashboard()),
      );
    } else if (state is AuthUnauthenticated) {
      // Navigate to Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  },
  child: ...,
)
```

### Navigation

**Automatique** (2-3 secondes) :
- Si `AuthAuthenticated` → Dashboard (placeholder)
- Si `AuthUnauthenticated` → LoginScreen

**Placeholder Dashboard** :
- Écran temporaire qui affiche "Authentification réussie !"
- Bouton logout
- Sera remplacé par vrai Dashboard dans Phase 7

---

## 🔑 LoginScreen

**Fichier** : `lib/presentation/screens/auth/login_screen.dart`

### Rôle

Écran d'authentification avec formulaire email/password.

### Design

**Fond** : Gris clair (AppColors.scaffoldBackground)

**Layout** :
- SafeArea + Center + SingleChildScrollView
- Padding horizontal : 24px

**Contenu** :

1. **Logo** (110×110px)
   - Fond bleu (AppColors.primary)
   - Border radius : 22px
   - Icône lock blanche (55px)
   - Shadow

2. **Titre** : "Connexion" (32px, bold, noir)

3. **Sous-titre** : "Bienvenue ! Connectez-vous pour continuer" (16px, gris)

4. **Form** avec GlobalKey

5. **Email Field**
   - Label : "Email"
   - Hint : "exemple@company.com"
   - Icône : email_outlined
   - Validation : Non vide + contient "@"
   - Keyboard : emailAddress
   - TextInputAction : next

6. **Password Field**
   - Label : "Mot de passe"
   - Hint : "••••••••"
   - Icône : lock_outlined
   - Toggle visibility (visibility_outlined / visibility_off_outlined)
   - obscureText avec toggle
   - Validation : Non vide
   - TextInputAction : done
   - onFieldSubmitted : _onLoginPressed()

7. **Login Button**
   - Width : double.infinity
   - Height : 56px
   - Text : "Se connecter" (17px, bold, blanc)
   - Si loading : CircularProgressIndicator blanc (24px)
   - Disabled si loading
   - Border radius : 12px

8. **Version** : "Version 1.0.0" (13px, gris clair)

### Validation

```dart
final _formKey = GlobalKey<FormState>();

// Email
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Veuillez saisir votre email';
  }
  if (!value.contains('@')) {
    return 'Email invalide';
  }
  return null;
}

// Password
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez saisir votre mot de passe';
  }
  return null;
}
```

### Logique

**onLoginPressed** :
```dart
void _onLoginPressed() {
  FocusScope.of(context).unfocus(); // Dismiss keyboard

  if (_formKey.currentState!.validate()) {
    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}
```

**BlocConsumer** :

**Listener** (navigation et erreurs) :
```dart
listener: (context, state) {
  if (state is AuthAuthenticated) {
    // Navigate to Dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  } else if (state is AuthError) {
    // Show error SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row([
          Icon(Icons.error_outline, color: white),
          Text(state.message),
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
```

**Builder** (UI states) :
```dart
builder: (context, state) {
  final isLoading = state is AuthLoading;

  return Form(
    // Disable fields if loading
    enabled: !isLoading,
    child: ...,
  );
}
```

### States UI

| State | UI |
|-------|-----|
| `AuthLoading` | Button disabled, CircularProgressIndicator, fields disabled |
| `AuthAuthenticated` | Navigate to Dashboard |
| `AuthUnauthenticated` | Form normal, ready for input |
| `AuthError` | SnackBar rouge avec message, puis form normal |

---

## 🔧 Configuration

### injection_container.dart

**AuthBloc enregistré avec registerFactory** :
```dart
import 'presentation/blocs/auth/auth_bloc.dart';

getIt.registerFactory<AuthBloc>(
  () => AuthBloc(
    loginUseCase: getIt<LoginUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
    getCachedUserUseCase: getIt<GetCachedUserUseCase>(),
    isAuthenticatedUseCase: getIt<IsAuthenticatedUseCase>(),
  ),
);
```

**Pourquoi `registerFactory` ?**
- Nouvelle instance à chaque fois
- Évite state partagé entre écrans
- BLoC fermé automatiquement avec BlocProvider

---

### main.dart

**MultiBlocProvider** :
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/screens/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        // Other BLoCs will be added here
      ],
      child: MaterialApp(
        home: const SplashScreen(),
        ...
      ),
    );
  }
}
```

**Home** : `const SplashScreen()`

---

## 📊 Flow Complet

### Démarrage App

```
1. main() → configureDependencies() (GetIt)
2. runApp(MyApp())
3. MultiBlocProvider crée AuthBloc
4. MaterialApp affiche SplashScreen
5. SplashScreen.initState() → dispatch AppStarted
6. AuthBloc vérifie token
   ├─ Token existe + user caché → emit AuthAuthenticated(user)
   │                              → Navigate Dashboard
   └─ Pas de token → emit AuthUnauthenticated
                   → Navigate LoginScreen
```

---

### Login Flow

```
1. User arrive sur LoginScreen
2. User saisit email + password
3. User clique "Se connecter"
4. Validation formulaire
5. Si OK → dispatch LoginRequested(email, password)
6. AuthBloc → emit AuthLoading
7. AuthBloc → LoginUseCase(email, password)
8. LoginUseCase → AuthRepository.login()
9. AuthRepository → AuthApi.login()
10. AuthApi → POST /auth/login
11. Backend répond :
    ├─ Succès : {accessToken, refreshToken, user}
    │  → Repository stocke tokens + user
    │  → Repository retourne Right(user)
    │  → AuthBloc emit AuthAuthenticated(user)
    │  → LoginScreen navigate Dashboard
    └─ Échec : 401 Unauthorized
       → Exception → Failure
       → AuthBloc emit AuthError("Email ou mot de passe incorrect")
       → SnackBar rouge
       → AuthBloc emit AuthUnauthenticated
       → Form prêt pour retry
```

---

### Logout Flow

```
1. User clique logout (Dashboard placeholder)
2. dispatch LogoutRequested
3. AuthBloc → emit AuthLoading
4. AuthBloc → LogoutUseCase()
5. LogoutUseCase → AuthRepository.logout()
6. AuthRepository → AuthApi.logout() (ignore erreurs)
7. AuthRepository → StorageService.clear()
8. AuthBloc → emit AuthUnauthenticated
9. Navigate LoginScreen
```

---

## 🎯 Points Critiques Implémentés

### ✅ BLoC Pattern
- Séparation UI / Logique
- Events → BLoC → UseCases → Repositories → APIs
- States → UI

### ✅ Either<Failure, Success>
- Gestion d'erreurs fonctionnelle
- `.fold()` pour gérer succès et échec
- Messages user-friendly

### ✅ Storage automatique
- Tokens JWT stockés par AuthRepository après login
- User caché récupéré au démarrage
- Clear complet au logout

### ✅ Navigation automatique
- SplashScreen décide Dashboard ou Login
- LoginScreen navigate Dashboard si succès
- Logout navigate LoginScreen

### ✅ Loading States
- CircularProgressIndicator pendant requêtes
- Champs désactivés pendant loading
- Button disabled pendant loading

### ✅ Error Handling
- Messages clairs pour l'utilisateur
- SnackBar rouge avec icône
- AccountLocked affiche durée restante
- Retour automatique à AuthUnauthenticated après erreur

---

## 📁 Structure Fichiers

```
lib/
├── presentation/
│   ├── blocs/
│   │   └── auth/
│   │       ├── auth_event.dart       ✅
│   │       ├── auth_state.dart       ✅
│   │       └── auth_bloc.dart        ✅
│   │
│   └── screens/
│       ├── splash/
│       │   └── splash_screen.dart    ✅
│       │
│       └── auth/
│           └── login_screen.dart     ✅
│
├── injection_container.dart          ✅ (AuthBloc registered)
└── main.dart                         ✅ (MultiBlocProvider)
```

---

## 🚀 Prochaines Étapes

**Phase 7 : Access Flow ⭐ PRIORITÉ**

1. **AccessBloc** (Events, States, Bloc)
   - QRCodeScanned
   - DeviceUnlockRequested
   - PINSubmitted
   - States : AccessGranted, AccessDenied, PendingPIN, etc.

2. **DeviceUnlockScreen** ⭐
   - Utilise DeviceUnlockService
   - Déverrouillage natif téléphone
   - Envoie `device_unlocked: true` au backend

3. **QRScannerScreen**
   - Scanner QR code avec qr_code_scanner
   - Dispatch QRCodeScanned(qrCode)
   - Vérifie accès zone

4. **PinEntryScreen**
   - Saisir PIN 4 chiffres
   - Pour zones HIGH security
   - 3 tentatives max

5. **AccessGrantedScreen**
   - Animation succès
   - Affiche zone accessible

6. **AccessDeniedScreen**
   - Affiche raison refus
   - Option demander accès temporaire

---

**Auth Flow : 100% Complété** ✅
**5 fichiers créés** (3 BLoC + 2 Screens) 🎉
**Prochaine étape : Access Flow (le plus important !)** 🚀
