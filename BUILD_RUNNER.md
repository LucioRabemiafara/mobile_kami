# 🔧 Build Runner - Génération de Code

## 📦 Ce qui va être généré

Build Runner va générer automatiquement les fichiers suivants pour chaque model :

### Fichiers générés par Freezed
Pour chaque model (par exemple `user_model.dart`) :
- `user_model.freezed.dart` : Code Freezed (immutabilité, copyWith, etc.)
- `user_model.g.dart` : Code JSON (fromJson, toJson)

### Liste complète des fichiers à générer

**Models** :
- ✅ `user_model.freezed.dart` + `user_model.g.dart`
- ✅ `zone_model.freezed.dart` + `zone_model.g.dart`
- ✅ `access_verify_response_model.freezed.dart` + `access_verify_response_model.g.dart`
- ✅ `access_event_model.freezed.dart` + `access_event_model.g.dart`
- ✅ `attendance_model.freezed.dart` + `attendance_model.g.dart`
- ✅ `access_request_model.freezed.dart` + `access_request_model.g.dart`
- ✅ `dashboard_kpis_model.freezed.dart` + `dashboard_kpis_model.g.dart`
- ✅ `auth_response_model.freezed.dart` + `auth_response_model.g.dart`

**Dependency Injection** :
- ✅ `injection_container.config.dart` (GetIt + Injectable)

---

## 🚀 Commandes Build Runner

### 1. Installer les dépendances (si pas déjà fait)

```bash
flutter pub get
```

### 2. Générer le code (one-time)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Options** :
- `build` : Génère le code une fois
- `--delete-conflicting-outputs` : Supprime les fichiers existants en conflit

**Durée estimée** : 30-60 secondes

### 3. Watch mode (régénération automatique)

Pour développer activement et régénérer automatiquement à chaque modification :

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Options** :
- `watch` : Surveille les changements et régénère automatiquement
- `--delete-conflicting-outputs` : Supprime les fichiers en conflit

**Utilisation** :
- Lancez cette commande dans un terminal séparé
- Elle reste active et régénère à chaque sauvegarde
- Utilisez Ctrl+C pour l'arrêter

### 4. Nettoyer les fichiers générés

Pour supprimer tous les fichiers générés :

```bash
flutter pub run build_runner clean
```

Ensuite, relancez `build` pour les régénérer.

### 5. Si vous rencontrez des erreurs

En cas d'erreurs de génération, essayez :

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Erreurs Courantes

### Erreur : "Conflicting outputs"

**Solution** : Utilisez `--delete-conflicting-outputs`
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur : "Missing part directive"

**Cause** : Vous avez oublié d'ajouter les directives `part` dans le fichier
**Solution** : Vérifiez que chaque model contient :
```dart
part 'user_model.freezed.dart';
part 'user_model.g.dart';
```

### Erreur : "No file to generate"

**Cause** : Le package build_runner n'est pas installé
**Solution** : Vérifiez `pubspec.yaml` et lancez `flutter pub get`

### Erreur : "Build failed"

**Cause** : Erreur de syntaxe dans un model
**Solution** : Lisez le message d'erreur, corrigez le fichier, relancez `build`

---

## ✅ Vérifier que tout fonctionne

Après la génération, vérifiez que les fichiers ont été créés :

### Models générés (16 fichiers)
```
lib/data/models/
├── user_model.dart
├── user_model.freezed.dart        ← Généré
├── user_model.g.dart               ← Généré
├── zone_model.dart
├── zone_model.freezed.dart         ← Généré
├── zone_model.g.dart               ← Généré
├── access_verify_response_model.dart
├── access_verify_response_model.freezed.dart  ← Généré
├── access_verify_response_model.g.dart        ← Généré
├── access_event_model.dart
├── access_event_model.freezed.dart ← Généré
├── access_event_model.g.dart       ← Généré
├── attendance_model.dart
├── attendance_model.freezed.dart   ← Généré
├── attendance_model.g.dart         ← Généré
├── access_request_model.dart
├── access_request_model.freezed.dart  ← Généré
├── access_request_model.g.dart        ← Généré
├── dashboard_kpis_model.dart
├── dashboard_kpis_model.freezed.dart  ← Généré
├── dashboard_kpis_model.g.dart        ← Généré
├── auth_response_model.dart
├── auth_response_model.freezed.dart   ← Généré
└── auth_response_model.g.dart         ← Généré
```

### Dependency Injection (1 fichier)
```
lib/
└── injection_container.config.dart  ← Généré
```

---

## 🎯 Utilisation des Models après Génération

### Créer une instance

```dart
final user = UserModel(
  id: '1',
  email: 'john@example.com',
  firstName: 'John',
  lastName: 'Doe',
  role: 'EMPLOYEE',
  posts: ['DEVELOPER', 'DEVOPS'], // ⭐ MULTI-POSTES
  department: 'IT',
  isActive: true,
  isAdmin: false,
);
```

### Utiliser copyWith (immutabilité)

```dart
final updatedUser = user.copyWith(
  firstName: 'Jane',
  posts: ['DEVELOPER', 'DEVOPS', 'SECURITY_AGENT'], // ⭐ MULTI-POSTES
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
//   "posts": ["DEVELOPER", "DEVOPS"],  ← MULTI-POSTES
//   ...
// }
```

### Désérialiser depuis JSON

```dart
final user = UserModel.fromJson(json);
```

### Comparaison (Freezed génère == et hashCode)

```dart
final user1 = UserModel(...);
final user2 = UserModel(...);

if (user1 == user2) {
  // Même contenu
}
```

---

## 🔄 Workflow de Développement Recommandé

### Option 1 : Build manuel (recommandé pour débuter)

1. Créer/modifier les models
2. Lancer `flutter pub run build_runner build --delete-conflicting-outputs`
3. Vérifier que tout compile
4. Continuer le développement

### Option 2 : Watch mode (recommandé pour développement actif)

1. Lancer `flutter pub run build_runner watch --delete-conflicting-outputs` dans un terminal
2. Créer/modifier les models
3. La génération se fait automatiquement à chaque sauvegarde
4. Vérifier les erreurs dans le terminal watch

---

## 📊 Temps Estimés

- **Première génération** : 30-60 secondes
- **Régénération (watch)** : 5-10 secondes
- **Clean + Rebuild** : 40-70 secondes

---

## ⚠️ Points Importants

### 1. MULTI-POSTES
- ✅ `UserModel.posts` est `List<String>` (pas `String`)
- ✅ `ZoneModel.allowedPosts` est `List<String>` (pas `String`)

### 2. Fichiers .gitignore
Les fichiers générés (`.freezed.dart`, `.g.dart`, `.config.dart`) peuvent être :
- **Ignorés** dans git (générés à chaque build)
- **Commités** dans git (pour faciliter CI/CD)

**Recommandation** : Commitez-les pour faciliter la collaboration

### 3. Ne PAS modifier les fichiers générés
Les fichiers `.freezed.dart`, `.g.dart`, et `.config.dart` sont générés automatiquement.
**Ne les modifiez jamais manuellement** car vos modifications seront écrasées.

---

## 🎉 Résultat Final

Après `flutter pub run build_runner build --delete-conflicting-outputs` :
- ✅ 8 models avec leurs fichiers générés (16 fichiers .freezed + .g)
- ✅ injection_container.config.dart généré
- ✅ Tout compile sans erreur
- ✅ Prêt à utiliser les models dans les APIs et Repositories

---

**Commande à lancer maintenant** :
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Durée** : ~60 secondes

**Résultat attendu** : `[INFO] Succeeded after XX.Xs with Y outputs`
