# 📱 Application Mobile Employé - Système de Gestion d'Accès et Présence

## 🎯 VISION GLOBALE DU PROJET

### Qu'est-ce que c'est ?

Un **système complet de contrôle d'accès intelligent** composé de 3 parties :

1. **BACKEND** (Spring Boot) : API REST qui gère toute la logique métier
2. **WEB** (React) : Interface administrateur pour gérer le système
3. **MOBILE** (Flutter) ← **TU ES ICI** : Application employé pour scanner QR codes et pointer

### Le rôle de cette app mobile

L'application mobile transforme le smartphone de l'employé en **badge d'accès intelligent**. L'employé peut :
- Scanner un QR code pour entrer dans une zone sécurisée
- Pointer son arrivée et son départ
- Consulter ses statistiques personnelles
- Demander des accès temporaires à des zones interdites

---

## 📊 CONTEXTE MÉTIER - COMPRENDRE LE DOMAINE

### Les Acteurs

**EMPLOYÉ** (User dans le code) :
- A un email, prénom, nom, département
- A **PLUSIEURS POSTES** (développeur, devops, RH, comptable, etc.) ← **IMPORTANT : MULTI-POSTES**
- Peut être actif ou inactif
- Peut avoir un compte bloqué temporairement (après 3 échecs PIN)

**ZONE** (Zone dans le code) :
- Représente un lieu physique (bureau, salle serveurs, parking, etc.)
- A un bâtiment, un étage, un nom
- A un **niveau de sécurité** : LOW, MEDIUM, HIGH
- A un **QR code unique** collé sur la porte
- Est ouverte à tous OU réservée à **certains postes** ← **IMPORTANT : MULTI-POSTES**

**BORNE DE POINTAGE** :
- Dispositif avec QR code pour check-in/check-out
- Toujours niveau HIGH (nécessite PIN)

### Les Règles Métier Critiques

#### Règle 1 : Vérification d'accès à une zone

Quand un employé scanne un QR code de zone, le backend vérifie dans cet ordre :

1. ✅ **Employé actif ?** (isActive = true)
2. ✅ **Employé pas bloqué ?** (accountLocked = false)
3. ✅ **Zone active ?** (isActive = true)
4. ✅ **QR code valide ?** (existe dans la base)
5. ✅ **Employé autorisé ?** :
   - **Option A** : Zone ouverte à tous (isOpenToAll = true) → ✅ Accès OK
   - **Option B** : Au moins UN de ses postes est dans `zone.allowedPosts` → ✅ Accès OK
   - **Option C** : A une permission temporaire valide aujourd'hui → ✅ Accès OK
   - **Sinon** : ❌ Accès refusé

6. ✅ **Niveau sécurité** :
   - **LOW** ou **MEDIUM** : Accès direct ✅
   - **HIGH** : Demander code PIN (4 chiffres) 🔒

#### Règle 2 : Code PIN (zones HIGH uniquement)

- L'employé a un code PIN à 4 chiffres dans `user.pinCode`
- Le backend génère un `tempToken` valide 5 minutes
- L'employé a **3 tentatives maximum**
- Après 3 échecs : Compte bloqué 30 minutes (`accountLockedUntil`)

#### Règle 3 : Pointage (Check-in / Check-out)

- Un employé peut pointer **UNE FOIS par jour** (arrivée)
- Puis pointer UNE FOIS (départ)
- Le pointage nécessite **TOUJOURS un PIN** (considéré niveau HIGH)
- Si arrivée après 9h00 → `isLate = true`
- Le backend calcule automatiquement `hoursWorked` (checkOut - checkIn)

#### Règle 4 : MULTI-POSTES (CRITIQUE !)

**UN EMPLOYÉ PEUT AVOIR PLUSIEURS POSTES** :
- Exemple : Jean est à la fois `DEVELOPER`, `DEVOPS` et `SECURITY_AGENT`
- Dans la base : `user.posts = ["DEVELOPER", "DEVOPS", "SECURITY_AGENT"]`
- Dans le code mobile : `List<String> posts`

**UNE ZONE PEUT AUTORISER PLUSIEURS POSTES** :
- Exemple : "Lab R&D" autorise `DEVELOPER` et `DEVOPS`
- Dans la base : `zone.allowedPosts = ["DEVELOPER", "DEVOPS"]`
- Dans le code mobile : `List<String> allowedPosts`

**Vérification d'accès** : Il suffit qu'**UN SEUL** poste de l'employé soit dans `zone.allowedPosts`.

Exemple :
```
Jean : posts = ["DEVELOPER", "DEVOPS", "ACCOUNTANT"]
Zone Lab : allowedPosts = ["DEVELOPER", "DEVOPS"]
→ Jean a accès ✅ (car DEVELOPER match)

Marie : posts = ["ACCOUNTANT", "HR_MANAGER"]
Zone Lab : allowedPosts = ["DEVELOPER", "DEVOPS"]
→ Marie n'a PAS accès ❌ (aucun match)
```

#### Règle 5 : Déverrouillage Téléphone Natif (CRITIQUE !)

**AVANT CHAQUE SCAN QR** (accès zone OU pointage), l'employé DOIT déverrouiller son téléphone avec le système de sécurité natif du téléphone :
- **Android** : 
  - Empreinte digitale (Fingerprint)
  - Reconnaissance faciale (Face Unlock)
  - Schéma (Pattern)
  - Code PIN du téléphone
  - Mot de passe du téléphone
- **iOS** :
  - Touch ID (empreinte)
  - Face ID
  - Code du téléphone

**IMPORTANT** : 
- Ce n'est PAS un déverrouillage biométrique spécifique à l'app
- C'est le déverrouillage **NATIF du téléphone** (le même que pour déverrouiller l'écran)
- L'app vérifie simplement si le téléphone a été déverrouillé récemment avec `local_auth`
- Le paramètre `device_unlocked: true` est envoyé au backend pour confirmer

**Pourquoi** :
- Sécurité supplémentaire : L'employé doit prouver qu'il possède physiquement le téléphone
- Éviter qu'un téléphone laissé ouvert soit utilisé par quelqu'un d'autre
- Le backend vérifie `device_unlocked: true` avant d'autoriser l'accès

**Comment ça marche** :
1. Employé ouvre l'app → Clic "Scanner QR Code" ou "Pointer"
2. L'app affiche un écran : "Déverrouillez votre appareil"
3. Le système natif du téléphone demande : Empreinte / Face / Schéma / PIN / Mot de passe
4. Employé déverrouille avec SA méthode habituelle
5. Si succès : `device_unlocked = true` → Scanner QR activé
6. Si échec : Impossible de scanner

---

## 🏗️ ARCHITECTURE TECHNIQUE

### Stack Technologique

**Framework** : Flutter 3.19+  
**Langage** : Dart 3.3+  
**Architecture** : Clean Architecture (3 couches)  
**State Management** : BLoC pattern (flutter_bloc)  
**HTTP Client** : Dio  
**Dependency Injection** : GetIt  
**Models** : Freezed (immutables + JSON auto)  
**Sécurité** : flutter_secure_storage (tokens JWT)  
**Déverrouillage Natif** : local_auth (vérifie déverrouillage téléphone)  
**QR Scanner** : qr_code_scanner  
**Graphiques** : fl_chart  

### Architecture en 3 Couches (Clean Architecture)
```
┌─────────────────────────────────────────────┐
│      PRESENTATION LAYER                      │
│  (UI + BLoC)                                │
│                                             │
│  • Screens (15 écrans)                      │
│  • Widgets réutilisables                    │
│  • BLoCs (gestion état)                     │
│    - AuthBloc                               │
│    - AccessBloc ⭐ (le plus important)      │
│    - AttendanceBloc                         │
│    - DashboardBloc                          │
└─────────────────┬───────────────────────────┘
                  │
                  │ Appelle UseCases
                  ↓
┌─────────────────────────────────────────────┐
│      DOMAIN LAYER                            │
│  (Logique métier pure)                      │
│                                             │
│  • Entities (User, Zone, etc.)              │
│  • UseCases (1 action = 1 usecase)          │
│    - LoginUseCase                           │
│    - VerifyAccessUseCase ⭐                 │
│    - VerifyPinUseCase ⭐                    │
│    - CheckInUseCase                         │
│    - CheckOutUseCase                        │
└─────────────────┬───────────────────────────┘
                  │
                  │ Appelle Repositories
                  ↓
┌─────────────────────────────────────────────┐
│      DATA LAYER                              │
│  (Communication avec backend)               │
│                                             │
│  • Models (Freezed + JSON)                  │
│  • Repositories (contrats + implémentations)│
│  • Data Sources (APIs)                      │
│    - AuthApi                                │
│    - AccessApi ⭐                           │
│    - AttendanceApi                          │
│  • Services                                 │
│    - StorageService (tokens JWT)            │
│    - DeviceUnlockService (local_auth)       │
└─────────────────┬───────────────────────────┘
                  │
                  │ API REST (HTTP)
                  ↓
        ┌──────────────────┐
        │  BACKEND         │
        │  Spring Boot     │
        │  localhost:8080  │
        └──────────────────┘
```

### Pattern BLoC (Business Logic Component)

Le BLoC est le cœur de la gestion d'état. Il sépare strictement l'UI de la logique.

**Flow complet** :
```
USER ACTION → EVENT → BLoC → UseCase → Repository → API
                                                      ↓
USER sees UI ← STATE ← BLoC ← Result ←────────────────┘
```

**Exemple concret** :
```
1. User clique "Se connecter"
2. UI dispatch LoginRequested(email, password)
3. AuthBloc reçoit l'event
4. AuthBloc appelle LoginUseCase
5. LoginUseCase appelle AuthRepository
6. AuthRepository appelle AuthApi (POST /auth/login)
7. API répond avec {accessToken, refreshToken, user}
8. Repository stocke tokens et user
9. Repository retourne Right(user) (succès)
10. BLoC emit AuthAuthenticated(user)
11. UI écoute le state
12. UI navigate vers Dashboard
```

**Concepts clés** :
- **Event** = Action de l'utilisateur (LoginRequested, QRCodeScanned, etc.)
- **State** = État de l'UI (AuthLoading, AuthAuthenticated, AccessGranted, etc.)
- **BLoC** = Transforme Events en States en appelant les UseCases
- **Either<Failure, Success>** = Gestion d'erreurs fonctionnelle (package dartz)

---

## 📱 LES 15 ÉCRANS DE L'APPLICATION

### Navigation Flow
```
Splash Screen
    ↓
    ├─ (token existe) → Dashboard ──────────┐
    │                      ↓                 │
    │   ┌─────────────────────────────────┐ │
    │   │  4 KPI Cards                    │ │
    │   │  Graphique 7 jours              │ │
    │   │  2 Gros Boutons                 │ │
    │   │  - SCANNER QR CODE ────────┐    │ │
    │   │  - POINTER ──────────────┐ │    │ │
    │   └──────────────────────────│─│────┘ │
    │                              │ │      │
    │   ┌──────────────────────────┘ │      │
    │   ↓                            │      │
    │  Device Unlock Screen          │      │
    │  (déverrouillage natif)        │      │
    │   ↓                            │      │
    │  QR Scanner Screen             │      │
    │   ↓                            │      │
    │  ├─ Zone LOW/MED ──→ Access Granted  │
    │  ├─ Zone HIGH ──→ PIN Entry          │
    │  │                    ↓               │
    │  │                 Access Granted     │
    │  └─ Refusé ──→ Access Denied          │
    │                                       │
    │   ┌───────────────────────────────────┘
    │   ↓
    │  Device Unlock Screen
    │  (déverrouillage natif)
    │   ↓
    │  QR Scanner Screen (borne)
    │   ↓
    │  PIN Entry (pointage)
    │   ↓
    │  Check-in ou Check-out Success
    │
    └─ (pas de token) → Login Screen
```

### Écran 1 : Splash Screen 🚀

**Rôle** : Écran de démarrage, vérifier si user déjà connecté

**Contenu visuel** :
- Logo centré (grande taille)
- Nom application "Access Control"
- Loader (CircularProgressIndicator)

**Logique** :
1. Vérifier si `accessToken` existe dans FlutterSecureStorage
2. Si oui : Récupérer user caché → Navigate Dashboard
3. Si non : Navigate Login

**Navigation** :
- Automatique (pas d'interaction)
- 2-3 secondes max

---

### Écran 2 : Login Screen 🔑

**Rôle** : Authentification employé

**Contenu visuel** :
- Logo en haut
- TextField Email (icône @)
- TextField Password (icône 🔒, masqué, toggle visible/caché)
- Bouton "Se connecter" (pleine largeur)
- Loader pendant requête

**Validation formulaire** :
- Email : Non vide + contient "@"
- Password : Non vide

**Logique** :
1. User remplit email + password
2. Clic "Se connecter"
3. Validation formulaire
4. Si OK : Dispatch `LoginRequested(email, password)`
5. AuthBloc appelle API POST /auth/login
6. Si succès : Stocker tokens + user → Navigate Dashboard
7. Si échec : Afficher erreur (SnackBar rouge)

**Messages erreur possibles** :
- "Email ou mot de passe incorrect"
- "Compte inactif"
- "Compte bloqué jusqu'à [date]"
- "Pas de connexion internet"

**Navigation après succès** :
- Dashboard (remplace Login, pas de retour possible)

---

### Écran 3 : Dashboard Screen 🏠

**Rôle** : Page d'accueil employé, vue d'ensemble personnelle

**Contenu visuel** :

**En-tête** :
- Avatar (photo ou initiales dans cercle)
- "Bonjour, **[Prénom]** !" (gras, 24px)
- Date du jour
- Badges postes (chips) : "Dev • DevOps • Security"

**Section KPI** (Grid 2×2) :
- Card 1 : "Heures ce mois" (valeur + progress bar)
- Card 2 : "Zones accessibles" (nombre)
- Card 3 : "Accès aujourd'hui" (nombre)
- Card 4 : "Pointé arrivée" (badge vert OUI / rouge NON)

**Section Graphique** :
- Titre "Heures travaillées - 7 derniers jours"
- LineChart (courbe bleue)
- Axe X : Lun, Mar, Mer, Jeu, Ven, Sam, Dim
- Axe Y : Heures (0-12h)

**Section Actions** (2 gros boutons) :
- Bouton 1 : "SCANNER QR CODE" (fond bleu, icône 📷)
  → Clic : Navigate /device-unlock
- Bouton 2 : "POINTER" (fond vert, icône ⏰)
  → Clic : Navigate /attendance → /device-unlock

**Section Menu rapide** (4 petits boutons) :
- Mes Zones
- Mes Pointages
- Demander Accès
- Mon Profil

**Bottom Navigation Bar** (5 items) :
- 🏠 Accueil (actif)
- 📷 Scanner
- ⏰ Pointer
- 📊 Historique
- 👤 Profil

**Logique** :
1. Au chargement : Dispatch `DashboardDataRequested(userId)`
2. DashboardBloc appelle API GET /dashboard/kpis?userId=X
3. Afficher les données
4. Pull-to-refresh pour recharger

---

### Écran 4 : Device Unlock Screen 🔓 ⭐ CRITIQUE

**Rôle** : Vérifier que le téléphone a été déverrouillé avec le système natif AVANT de scanner QR

**Contenu visuel** :
- Grande icône cadenas ouvert 🔓 (120px)
- Animation pulse (scale 0.8 → 1.0 en boucle)
- Texte "Déverrouillez votre téléphone" (gras, 22px)
- Sous-texte "Utilisez votre méthode habituelle (empreinte, face, schéma, PIN, mot de passe)"
- Bouton "Annuler" (retour dashboard)

**Logique CRITIQUE** :
1. Écran s'ouvre
2. Appeler immédiatement `local_auth.authenticate()` qui déclenche le système de déverrouillage **NATIF** du téléphone
3. Le téléphone affiche SA PROPRE interface de déverrouillage :
   - Android : Empreinte / Face / Schéma / PIN / Mot de passe
   - iOS : Touch ID / Face ID / Code téléphone
4. **SI déverrouillage réussi** :
   - `device_unlocked = true`
   - Navigate /qr-scanner
   - Fermer cet écran
5. **SI déverrouillage échoué** :
   - SnackBar "Déverrouillage échoué"
   - Bouton "Réessayer"
   - Bouton "Annuler" → Dashboard
6. **SI aucune méthode de déverrouillage configurée** :
   - Message "Aucune sécurité configurée sur votre téléphone"
   - "Configurez un déverrouillage dans les paramètres de votre téléphone"
   - Bouton "OK" → Dashboard

**IMPORTANT** :
- Ce n'est PAS une biométrie spécifique à l'app
- C'est le déverrouillage **NATIF** du téléphone (le même pour déverrouiller l'écran)
- L'app ne fait que vérifier si le téléphone a été déverrouillé récemment
- Le backend reçoit `device_unlocked: true` pour s'assurer que l'employé a bien déverrouillé
- Cet écran est OBLIGATOIRE avant CHAQUE scan QR (accès zone ET pointage)

**Navigation** :
- Vient de : Dashboard ou AttendanceScreen
- Va vers : QRScannerScreen (si succès) ou Dashboard (si annule/échec)

---

### Écran 5 : QR Scanner Screen 📷 ⭐ CRITIQUE

**Rôle** : Scanner le QR code de la zone ou de la borne

**Contenu visuel** :
- Caméra plein écran
- Overlay carré de scan (300×300px, coins arrondis)
- Bordure bleue animée
- Texte en haut : "Scannez le QR code de la zone"
- Bouton torche (toggle flash) en haut à droite
- Bouton fermer ✖️ en haut à gauche

**Logique** :
1. Demander permission caméra
2. Si refusée : Dialog + "Ouvrir paramètres"
3. Si OK : Ouvrir caméra avec QRView
4. Écouter détection QR :
```
   controller.scannedDataStream.listen((scanData) {
     // QR détecté !
   })
```
5. **Quand QR détecté** :
   - Vibration feedback
   - Extraire `qrCode` (string)
   - Désactiver scan temporairement
   - Fermer caméra
   - Afficher loader "Vérification..."
   - Dispatch `QRCodeScanned(qrCode: qrCode)`
6. AccessBloc appelle API POST /access/verify avec `device_unlocked: true`
7. **3 réponses possibles** :
   - **GRANTED** → Navigate /access-granted
   - **PENDING_PIN** → Navigate /pin-entry
   - **DENIED** → Navigate /access-denied

**Gestion erreurs** :
- Erreur réseau : SnackBar + réactiver scan
- QR invalide : SnackBar "QR code non reconnu"

**Navigation** :
- Vient de : DeviceUnlockScreen
- Va vers : AccessGrantedScreen, PinEntryScreen ou AccessDeniedScreen

---

### Écran 6 : PIN Entry Screen 🔢 (Zones HIGH uniquement)

**Rôle** : Saisir code PIN à 4 chiffres

**Contenu visuel** :
- Nom zone (ex: "Salle des Serveurs") (gras, 20px)
- Badge rouge "Sécurité Maximale"
- Texte "Entrez votre code PIN"
- **4 cercles indicateurs** (○○○○ → ●●●● quand remplis)
- **Clavier numérique** (3×4 grid) :
```
  1  2  3
  4  5  6
  7  8  9
     0  ←
```
- Lien "Code oublié ?" (en bas)

**Logique** :
1. User tape un chiffre → Cercle se remplit
2. Quand 4 chiffres tapés :
   - Auto-submit après 300ms
   - Loader "Vérification du code..."
   - Dispatch `PINSubmitted(tempToken, pinCode)`
3. AccessBloc appelle API POST /access/verify-pin
4. **3 réponses possibles** :
   - **GRANTED** :
     → Navigate /access-granted
   - **DENIED** (PIN incorrect) :
     → SnackBar "Code incorrect (2 tentatives restantes)"
     → Vider les 4 cercles
     → Permettre réessayer
   - **DENIED** (compte bloqué) :
     → Dialog modal "Compte bloqué 30 minutes"
     → Bouton "OK" → Navigate Dashboard

**User tape Backspace** :
- Supprimer dernier chiffre
- Vider cercle correspondant

**Navigation** :
- Vient de : QRScannerScreen
- Va vers : AccessGrantedScreen, AccessDeniedScreen ou Dashboard

---

### Écran 7 : Access Granted Screen ✅

**Rôle** : Confirmation accès autorisé

**Contenu visuel** :
- **Fond vert clair** (#E8F5E9)
- **Grande icône ✓** (120px, vert foncé)
- Animation : Scale 0 → 1 avec elastic curve
- Texte "**Accès Autorisé**" (gras, 28px, vert)
- Nom zone (ex: "Bureau Principal")
- Badge niveau sécurité (LOW/MEDIUM/HIGH avec couleur)
- Message "Bienvenue !"
- Bouton "Retour Dashboard"

**Logique** :
1. Afficher animation checkmark
2. Vibration succès
3. **Auto-retour Dashboard après 3 secondes**
4. User peut cliquer "Retour Dashboard" avant

**Navigation** :
- Vient de : QRScannerScreen ou PinEntryScreen
- Va vers : Dashboard (popUntil route.isFirst)

---

### Écran 8 : Access Denied Screen ❌

**Rôle** : Notification accès refusé avec raison

**Contenu visuel** :
- **Fond rouge clair** (#FFEBEE)
- **Grande icône ✗** (120px, rouge foncé)
- Animation : Shake (tremblement gauche-droite)
- Texte "**Accès Refusé**" (gras, 28px, rouge)
- Nom zone
- **Card blanche avec raison complète** :
  - "Vos postes [ACCOUNTANT] non autorisés. Postes requis : [DEVELOPER, DEVOPS]"
  - "Zone désactivée"
  - "Compte bloqué jusqu'à [date]"
- **SI `canRequestAccess = true`** :
  - Bouton "Demander un Accès Temporaire" (orange)
  - Clic → Navigate /create-request (zone pré-remplie)
- Bouton "Retour Dashboard" (gris)

**Logique** :
1. Afficher animation shake
2. Vibration erreur
3. Attendre action user (pas d'auto-retour)

**Navigation** :
- Vient de : QRScannerScreen
- Va vers : Dashboard ou CreateRequestScreen

---

### Écran 9 : Attendance Screen ⏰

**Rôle** : Gérer pointage check-in et check-out

**Contenu dynamique selon état** :

**CAS A : Pas encore pointé arrivée** :
- Grande Card "Pointer Arrivée"
- Icône ☀️
- Heure actuelle (grande, actualisée chaque seconde) : "08:45:23"
- Date : "Mardi 15 Juillet 2025"
- Bouton "POINTER ARRIVÉE" (grand, vert)
  → Clic : Navigate /device-unlock

**CAS B : Arrivée pointée, pas départ** :
- Card "Arrivée enregistrée" :
  - Icône ✓ vert
  - Heure : "08:45"
  - Badge "À l'heure" (vert) OU "En retard" (orange)
- Card "Pointer Départ" :
  - Icône 🌙
  - **Chrono live** : "Temps travaillé : 9h 15m 23s"
  - Bouton "POINTER DÉPART" (grand, bleu)
    → Clic : Navigate /device-unlock

**CAS C : Arrivée ET départ pointés** :
- Card "Journée terminée" :
  - Icône ✓✓
  - Arrivée : "08:45"
  - Départ : "18:00"
  - **Heures travaillées** : "9h 15m" (grand, gras)
  - Message "Bonne soirée !"

**Section Stats du Mois** (toujours visible en bas) :
- Total heures : "152h"
- Moyenne/jour : "7h 36m"
- Jours travaillés : "20"
- Nombre retards : "2"

**Bouton "Voir Historique"** → Navigate /attendance-history

**Logique** :
1. Au chargement : GET /attendance/today?userId=X
2. Afficher CAS A, B ou C selon résultat
3. Chrono live (Timer.periodic chaque seconde)
4. Pointage nécessite : DeviceUnlock → QR → PIN → API

**Navigation** :
- Vient de : Dashboard (Bottom nav "Pointer")
- Va vers : DeviceUnlockScreen, AttendanceHistoryScreen

---

### Écran 10 : My Zones Screen 🏢

**Rôle** : Liste zones accessibles par l'employé

**Contenu visuel** :
- Titre "Mes Zones Accessibles"
- Sous-titre : "Vous avez accès à **28 zones**"
- **Filtres** (Chips horizontaux) :
  - Tous (28)
  - Via Poste (22)
  - Permissions Temporaires (6)
- **Liste Cards Zones** :
  - Nom zone (gras)
  - Bâtiment, Étage
  - Badge niveau sécurité (LOW/MEDIUM/HIGH)
  - **Raison d'accès** (IMPORTANT) :
    - "Via poste **DEVELOPER**" (icône 👤)
    - "Permission temporaire jusqu'au **20 Juillet**" (icône ⏰)
  - Divider entre cards

**Logique** :
1. Au chargement : GET /users/:id/access-zones
2. Afficher liste avec raison pour chaque zone
3. Filtrer selon chip sélectionné
4. Pull-to-refresh

**Navigation** :
- Vient de : Dashboard (Menu rapide)
- Va vers : (reste sur la page)

---

### Écran 11 : Access Requests Screen 📋

**Rôle** : Mes demandes d'accès temporaires

**Contenu visuel** :
- **FAB** (Floating Action Button) : "Nouvelle Demande"
  → Clic : Navigate /create-request
- **3 Tabs** :
  - En attente (badge 3)
  - Approuvées (badge 12)
  - Rejetées (badge 2)
- **Liste Cards** (pour chaque tab) :
  - Nom zone
  - Période : "Du 15/07 au 20/07"
  - Justification (aperçu tronqué)
  - Statut (chip coloré) : PENDING/APPROVED/REJECTED
  - Date demande
  - SI REJECTED : Card expandable avec motif admin

**Logique** :
1. Au chargement : GET /access-requests/my-requests?userId=X
2. Grouper par status
3. Afficher dans tabs

**Navigation** :
- Vient de : Dashboard (Menu rapide)
- Va vers : CreateRequestScreen

---

### Écran 12 : Create Access Request Screen ➕

**Rôle** : Formulaire demande accès temporaire

**Contenu visuel** :
- Titre "Demander un Accès Temporaire"
- **Dropdown "Zone"** (required) :
  - Options : Zones NON accessibles
  - Si vient de /access-denied : Pré-sélectionner zone
- **DatePicker "Date début"** (required) :
  - Min : Aujourd'hui
- **DatePicker "Date fin"** (required) :
  - Min : Date début
- **TextField "Justification"** (required, multiline) :
  - Placeholder : "Expliquez pourquoi..."
  - Min 20 caractères
  - Max 500 caractères
  - Compteur : "45/500"
- **Boutons** :
  - Annuler (gris) → Navigate back
  - Envoyer (bleu, disabled si invalide)

**Validation** :
- Zone sélectionnée
- Date début < Date fin
- Justification ≥ 20 caractères

**Logique** :
1. Remplir formulaire
2. Validation
3. Clic "Envoyer" : POST /access-requests
4. SnackBar "Demande envoyée ✓"
5. Navigate back

**Navigation** :
- Vient de : AccessRequestsScreen ou AccessDeniedScreen
- Va vers : AccessRequestsScreen

---

### Écran 13 : Attendance History Screen 📊

**Rôle** : Historique complet pointages

**Contenu visuel** :
- Dropdown "Mois" : Juillet 2025, Juin 2025, etc.
- **Stats du Mois** (Cards 2×2) :
  - Total heures
  - Moyenne/jour
  - Jours travaillés
  - Nombre retards
- **Liste Cards** (par jour, reverse chrono) :
  - Date : "Lundi 15 Juillet"
  - Arrivée : "08:45" (icône ☀️)
  - Départ : "18:00" (icône 🌙)
  - Heures : "9h 15m" (gras, bleu)
  - Badge retard (si isLate)

**Logique** :
1. Au chargement : GET /attendance/history?userId=X&month=2025-07
2. Calculer stats
3. Afficher liste
4. Changement mois : Recharger
5. Pull-to-refresh

**Navigation** :
- Vient de : AttendanceScreen, Dashboard (Bottom nav)
- Va vers : (reste sur la page)

---

### Écran 14 : My Access History Screen 📜 (optionnel)

**Rôle** : Historique tous mes accès zones

**Contenu visuel** :
- **Filtres** (Chips) : 7 jours | 30 jours | 90 jours | Personnalisé
- **Liste Cards** (reverse chrono) :
  - Date + Heure : "15 Juillet 2025 • 14:23"
  - Nom zone
  - **Statut** (badge) : AUTORISÉ ✓ (vert) | REFUSÉ ✗ (rouge)
  - Méthode : "QR" ou "QR + PIN"
  - SI REFUSÉ : Raison (expandable)

**Logique** :
1. Au chargement : GET /access/history?userId=X&dateStart=...&dateEnd=...
2. Afficher liste
3. Filtrer selon période

**Navigation** :
- Vient de : Dashboard (Bottom nav "Historique")
- Va vers : (reste sur la page)

---

### Écran 15 : Profile Screen 👤

**Rôle** : Profil utilisateur et paramètres

**Contenu visuel** :

**En-tête** :
- Photo profil (grande, 120px)
- Nom complet : "Jean Dupont" (gras, 24px)
- Email : "jean.dupont@company.com"
- **Postes** (chips) : "Dev • DevOps • Security" ← **MULTI-POSTES**
- Département : "IT"
- Date embauche : "Embauché le 15/01/2023"

**Section "Statistiques"** :
- Total accès : "1,245"
- Total heures : "1,520h"
- Taux présence : "95%"

**Section "Paramètres"** :
- **Notifications** (Switch)
- **Langue** (Chevron → Sélecteur)
- **Changer Code PIN** (Chevron → Dialog formulaire)

**Bouton "Déconnexion"** (rouge) :
- Dialog confirmation
- Si oui : Clear tokens → Navigate Login

**Navigation** :
- Vient de : Dashboard (Bottom nav "Profil")
- Va vers : Login (si déconnexion)

---

## 🎯 WORKFLOW CRITIQUE #1 : Accès à une Zone

**C'EST LE WORKFLOW LE PLUS IMPORTANT DE L'APP.**
```
┌─────────────────────────────────────────────────┐
│  ÉTAPE 1 : Dashboard                            │
│  User clique "SCANNER QR CODE"                  │
│  → Navigate DeviceUnlockScreen                  │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  ÉTAPE 2 : Device Unlock Screen                │
│  • Afficher "Déverrouillez votre téléphone"    │
│  • Appeler local_auth.authenticate()            │
│  • Système natif s'affiche :                    │
│    - Android : Empreinte/Face/Schéma/PIN/MDP    │
│    - iOS : Touch ID/Face ID/Code                │
│  • User déverrouille avec SA méthode            │
│  • SI succès : device_unlocked = true           │
│  • Navigate QRScannerScreen                     │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  ÉTAPE 3 : QR Scanner Screen                   │
│  • Ouvrir caméra                                │
│  • User scanne QR code zone                     │
│  • Extraire qrCode (string)                     │
│  • Dispatch QRCodeScanned(qrCode)               │
│  • AccessBloc → VerifyAccessUseCase             │
│  • API POST /access/verify                      │
│    Body: {                                      │
│      user_id,                                   │
│      qr_code,                                   │
│      device_unlocked: true  ⭐ IMPORTANT        │
│    }                                            │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  ÉTAPE 4 : Traitement Réponse Backend          │
│                                                 │
│  3 RÉPONSES POSSIBLES :                         │
│                                                 │
│  A) status = "GRANTED" (zones LOW/MEDIUM)       │
│     → Navigate AccessGrantedScreen              │
│                                                 │
│  B) status = "PENDING_PIN" (zones HIGH)         │
│     → Navigate PinEntryScreen                   │
│     → User tape PIN                             │
│     → API POST /access/verify-pin               │
│     → SI correct : Navigate AccessGrantedScreen │
│     → SI incorrect : Afficher erreur + réessayer│
│     → SI 3 échecs : Dialog "Bloqué 30min"      │
│                                                 │
│  C) status = "DENIED" (pas autorisé)            │
│     → Navigate AccessDeniedScreen               │
│     → Afficher raison complète                  │
│     → Option "Demander Accès" si possible       │
└─────────────────────────────────────────────────┘
```

**Points critiques** :
1. Déverrouillage téléphone natif est OBLIGATOIRE (pas de skip)
2. `device_unlocked: true` doit être envoyé au backend
3. Gérer les 3 cas de réponse (GRANTED, PENDING_PIN, DENIED)
4. PIN : 3 tentatives max → blocage 30min
5. Raison refus doit être affichée complète

---

## 🎯 WORKFLOW CRITIQUE #2 : Pointage
```
┌─────────────────────────────────────────────────┐
│  ÉTAPE 1 : Attendance Screen                   │
│  User voit statut actuel (pointé ou pas)       │
│  User clique "POINTER ARRIVÉE" ou "DÉPART"     │
│  → Navigate DeviceUnlockScreen                  │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  ÉTAPE 2 : Device Unlock Screen                │
│  Déverrouillage natif téléphone                 │
│  → Navigate QRScannerScreen(mode: ATTENDANCE)   │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  ÉTAPE 3 : QR Scanner Screen                   │
│  Texte : "Scannez QR borne de pointage"        │
│  User scanne QR borne                           │
│  → Navigate PinEntryScreen(mode: ATTENDANCE)    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  ÉTAPE 4 : PIN Entry Screen                    │
│  ⚠️ POINTAGE NÉCESSITE TOUJOURS PIN ⚠️         │
│  (niveau HIGH)                                  │
│  User tape PIN                                  │
│                                                 │
│  SI CHECK_IN :                                  │
│  → API POST /attendance/check-in                │
│    Body: {user_id, qr_code, pin_code}           │
│  → Response: {checkIn, isLate}                  │
│  → Dialog "Arrivée enregistrée ✓"              │
│    "Pointé à 08:45 - À l'heure !"              │
│                                                 │
│  SI CHECK_OUT :                                 │
│  → API POST /attendance/check-out               │
│    Body: {user_id, qr_code, pin_code}           │
│  → Response: {checkOut, hoursWorked}            │
│  → Dialog "Départ enregistré ✓"                │
│    "Vous avez travaillé 9h15"                  │
└─────────────────────────────────────────────────┘
```

**Points critiques** :
1. Déverrouillage natif téléphone OBLIGATOIRE avant scan
2. Pointage nécessite TOUJOURS un PIN (considéré HIGH)
3. Backend calcule `isLate` (après 9h00)
4. Backend calcule `hoursWorked` automatiquement
5. Un seul check-in et un seul check-out par jour

---

## 🔗 INTÉGRATION BACKEND (API REST)

### Configuration de Base

**URL Backend** : `http://localhost:8080/api`  
**Format** : JSON  
**Authentification** : JWT Bearer token  
**Headers requis** :
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

### Gestion JWT (Critique)

**Flow complet** :
1. Login → Recevoir `accessToken` + `refreshToken`
2. Stocker dans FlutterSecureStorage (sécurisé)
3. Dio Interceptor ajoute header automatiquement
4. Si 401 (token expiré) :
   - Appeler POST /auth/refresh avec refreshToken
   - Récupérer nouveau accessToken
   - Stocker nouveau token
   - Retry requête originale
   - Transparent pour user
5. Si refresh échoue : Logout → Login

**Dio Request Interceptor** :
```
onRequest → Récupérer token depuis storage → Ajouter header Authorization
```

**Dio Response Interceptor** :
```
onError → Si 401 :
  → Appeler /auth/refresh
  → Si succès : Retry requête avec nouveau token
  → Si échec : Logout
```

### Endpoints Utilisés

**Authentification** :
- `POST /auth/login` : Connexion
- `POST /auth/refresh` : Refresh token
- `POST /auth/logout` : Déconnexion

**Contrôle d'Accès** ⭐ :
- `POST /access/verify` : Vérifier accès zone (après scan QR)
  - Body: `{user_id, qr_code, device_unlocked}`
- `POST /access/verify-pin` : Vérifier code PIN (zones HIGH)
- `GET /access/history` : Historique mes accès

**Pointage** :
- `POST /attendance/check-in` : Pointer arrivée
- `POST /attendance/check-out` : Pointer départ
- `GET /attendance/today` : Pointage aujourd'hui
- `GET /attendance/history` : Historique pointages

**Utilisateurs** :
- `GET /users/:id` : Infos employé
- `GET /users/:id/access-zones` : Zones accessibles avec raisons

**Demandes d'Accès** :
- `GET /access-requests/my-requests` : Mes demandes
- `POST /access-requests` : Créer demande

**Dashboard** :
- `GET /dashboard/kpis` : KPIs personnels

---

## 🔐 SÉCURITÉ

### 1. Stockage Sécurisé (FlutterSecureStorage)

**Pourquoi** : Les tokens JWT sont sensibles et ne doivent JAMAIS être stockés en clair.

**Comment** :
- iOS : Keychain (crypté système)
- Android : EncryptedSharedPreferences (AES256)

**Stocké** :
- `accessToken`
- `refreshToken`
- `user` (JSON sérialisé)

**NE JAMAIS** :
- Utiliser SharedPreferences pour tokens
- Logger les tokens en console
- Stocker le mot de passe

### 2. Déverrouillage Téléphone Natif Obligatoire

**Pourquoi** : 
- Sécurité : L'employé doit prouver qu'il possède physiquement le téléphone
- Éviter qu'un téléphone laissé déverrouillé soit utilisé par quelqu'un d'autre
- Le backend vérifie `device_unlocked: true` avant d'autoriser l'accès

**Comment** : Package `local_auth`
- **NE FAIT PAS** une biométrie spécifique à l'app
- **VÉRIFIE** simplement que le téléphone a été déverrouillé avec le système natif
- Android : Supporte Fingerprint, Face, Pattern, PIN, Password
- iOS : Supporte Touch ID, Face ID, Code téléphone

**Options importantes** :
- `biometricOnly: false` : Autoriser toutes les méthodes de déverrouillage (pas seulement biométrie)
- `stickyAuth: true` : Demande déverrouillage même si app en background
- `useErrorDialogs: true` : Dialog erreur système

**Code exemple** :
```dart
// Ce code DÉCLENCHE le déverrouillage natif du téléphone
await _localAuth.authenticate(
  localizedReason: 'Déverrouillez votre téléphone pour continuer',
  options: AuthenticationOptions(
    biometricOnly: false, // ⭐ Autoriser PIN/Schéma/MDP aussi
    stickyAuth: true,
    useErrorDialogs: true,
  ),
);
```

### 3. Permissions

**Android** (AndroidManifest.xml) :
- INTERNET
- CAMERA
- USE_BIOMETRIC (pour local_auth)
- USE_FINGERPRINT (pour local_auth)

**iOS** (Info.plist) :
- NSCameraUsageDescription
- NSFaceIDUsageDescription (pour local_auth)

### 4. Gestion Erreurs Réseau

**Pattern Either<Failure, Success>** (package dartz) :

Au lieu de try-catch, utiliser :
```
Either<Failure, UserModel> result = await repository.login(...)

result.fold(
  (failure) => // Gérer l'erreur,
  (user) => // Gérer le succès
)
```

**Types de Failures** :
- `ServerFailure` : Erreur backend (400, 500)
- `NetworkFailure` : Pas de connexion internet
- `UnauthorizedFailure` : Token invalide (401)
- `DeviceUnlockFailure` : Déverrouillage téléphone échoué

---

## 🎨 DESIGN SYSTEM

### Couleurs Principales

**Primary** : Bleu (#1976D2)  
**Secondary** : Vert (#388E3C)  
**Success** : Vert (#4CAF50)  
**Error** : Rouge (#E53935)  
**Warning** : Orange (#FF9800)  

**Niveaux Sécurité** :
- LOW : Vert clair (#81C784)
- MEDIUM : Orange clair (#FFB74D)
- HIGH : Rouge clair (#E57373)

**Backgrounds** :
- Background : Gris clair (#F5F5F5)
- Surface : Blanc (#FFFFFF)
- Access Granted : Vert très clair (#E8F5E9)
- Access Denied : Rouge très clair (#FFEBEE)

### Styles de Texte

- **headline1** : 32px, bold (titres)
- **headline2** : 24px, bold (sous-titres)
- **bodyLarge** : 16px, normal (texte principal)
- **bodyMedium** : 14px, normal (texte secondaire)
- **caption** : 12px, normal (petits textes)

### Widgets Réutilisables

**AppButton** :
- Pleine largeur ou taille fixe
- Icône optionnelle
- Loader intégré (isLoading)
- Couleur personnalisable

**KpiCard** :
- Icône + Titre + Valeur
- Progress bar optionnelle
- Couleur personnalisable

**PinPad** :
- Clavier numérique 0-9
- Bouton backspace
- onNumberPressed callback
- onBackspacePressed callback

---

## 📚 DÉPENDANCES PRINCIPALES

### State Management
- `flutter_bloc: ^8.1.3` : Pattern BLoC
- `equatable: ^2.0.5` : Comparaison objects

### HTTP & API
- `dio: ^5.4.0` : Client HTTP
- `pretty_dio_logger: ^1.3.1` : Logs requêtes

### Dependency Injection
- `get_it: ^7.6.4` : Service locator
- `injectable: ^2.3.2` : Code generation DI

### Sécurité
- `flutter_secure_storage: ^9.0.0` : Stockage sécurisé
- `local_auth: ^2.2.0` : Vérification déverrouillage téléphone natif

### QR Code
- `qr_code_scanner: ^1.0.1` : Scanner QR
- `permission_handler: ^11.3.0` : Permissions

### Models
- `freezed: ^2.4.6` : Génération models immutables
- `json_serializable: ^6.7.1` : Sérialisation JSON

### UI
- `fl_chart: ^0.66.0` : Graphiques
- `intl: ^0.19.0` : Formatage dates/heures
- `cached_network_image: ^3.3.1` : Images optimisées

### Utils
- `dartz: ^0.10.1` : Programmation fonctionnelle (Either)

---

## 🧪 CRITÈRES DE SUCCÈS

### Fonctionnel ✅

- Login avec JWT fonctionne (tokens stockés sécurisés)
- Déverrouillage téléphone natif OBLIGATOIRE avant scan QR (pas seulement biométrie)
- Scanner QR détecte codes correctement
- Workflow accès complet : GRANTED / PENDING_PIN / DENIED
- Vérification PIN zones HIGH (3 tentatives → blocage)
- Pointage check-in/check-out avec PIN obligatoire
- Dashboard affiche 4 KPI + graphique temps réel
- Liste zones accessibles avec raisons correctes
- Demandes d'accès temporaires fonctionnent
- Refresh token automatique sur 401

### Technique ✅

- Architecture Clean (domain/data/presentation)
- BLoC pattern pour state management
- Freezed pour models immutables
- GetIt pour dependency injection
- Dio interceptors pour JWT + refresh
- FlutterSecureStorage pour tokens
- Gestion erreurs avec Either<Failure, Success>
- Tests unitaires > 70% couverture
- Responsive (smartphones 5" à 7")
- Performance : < 100ms changement écran

### UX ✅

- Animations fluides (checkmark, shake, pulse)
- Feedback haptique (vibrations)
- Messages erreur clairs
- Loaders pendant requêtes
- Pull-to-refresh sur listes
- Auto-retour dashboard après succès

---

## ⚠️ POINTS D'ATTENTION CRITIQUES

### 1. MULTI-POSTES (TRÈS IMPORTANT)

**Un employé peut avoir PLUSIEURS postes** :
- Dans la base : `user.posts = ["DEVELOPER", "DEVOPS", "SECURITY_AGENT"]`
- Dans le code mobile : `List<String> posts`
- PAS UN SEUL poste, MAIS UNE LISTE

**Une zone peut autoriser PLUSIEURS postes** :
- Dans la base : `zone.allowedPosts = ["DEVELOPER", "DEVOPS"]`
- Dans le code mobile : `List<String> allowedPosts`

**Vérification** : Il suffit qu'UN SEUL poste de l'employé soit dans `zone.allowedPosts`.

### 2. Déverrouillage Téléphone Natif OBLIGATOIRE (CRITIQUE !)

**C'EST LE DÉVERROUILLAGE NATIF DU TÉLÉPHONE, PAS UNE BIOMÉTRIE SPÉCIFIQUE À L'APP**

**Comprendre la différence** :
- ❌ PAS une authentification biométrique créée par l'app
- ✅ Vérification que le téléphone a été déverrouillé avec sa sécurité native

**Méthodes de déverrouillage acceptées** :
- Android : Empreinte, Face, Schéma, PIN téléphone, Mot de passe
- iOS : Touch ID, Face ID, Code du téléphone

**Configuration local_auth** :
```dart
biometricOnly: false  // ⭐ IMPORTANT : Accepter TOUTES les méthodes
```

**Flow** :
1. User clique "Scanner QR Code"
2. App affiche "Déverrouillez votre téléphone"
3. `local_auth.authenticate()` déclenche l'interface NATIVE du téléphone
4. User utilise SA méthode habituelle (celle qu'il utilise pour déverrouiller l'écran)
5. Si succès : `device_unlocked = true` → Envoyé au backend
6. Backend vérifie que `device_unlocked == true` avant d'autoriser

**Pourquoi c'est critique** :
- Éviter qu'un téléphone laissé ouvert soit utilisé par quelqu'un d'autre
- L'employé doit prouver qu'il a physiquement le téléphone
- Sécurité additionnelle demandée par le backend

### 3. PIN (Zones HIGH uniquement)

- 4 chiffres
- 3 tentatives max
- Après 3 échecs : Compte bloqué 30 minutes
- `tempToken` valide 5 minutes
- Pointage nécessite TOUJOURS un PIN

### 4. Refresh Token Automatique

- Sur 401, appeler /auth/refresh
- Retry requête originale
- Transparent pour user
- Si refresh échoue : Logout

### 5. Models Freezed

- Tous les models doivent utiliser Freezed
- Générer avec `build_runner`
- Immutables + JSON auto
- copyWith() automatique

### 6. Architecture Clean

**Respecter strictement** :
- `domain/` : Entities, UseCases (logique pure)
- `data/` : Models, Repositories, APIs (communication)
- `presentation/` : Screens, Widgets, BLoCs (UI)

**Règles** :
- domain/ ne dépend de RIEN
- data/ dépend de domain/
- presentation/ dépend de domain/ et data/

### 7. BLoC Pattern

**Toujours** :
- Events = Actions user
- States = États UI
- BLoC = Transforme Events en States
- UI écoute States avec BlocConsumer ou BlocBuilder

**Jamais** :
- Logique métier dans les Widgets
- Appels API directs depuis UI
- State management avec setState() pour logique complexe

---

## 📝 NOTES POUR CLAUDE CODE

### ✅ CE QUE TU DOIS FAIRE

1. **Architecture Clean** stricte (domain/data/presentation)
2. **BLoC pattern** pour state management (flutter_bloc)
3. **Freezed** pour TOUS les models
4. **GetIt** pour dependency injection
5. **Multi-postes** : `List<String>` pour `posts` et `allowedPosts`
6. **Déverrouillage natif téléphone** OBLIGATOIRE avant scan QR (pas seulement biométrie)
7. **FlutterSecureStorage** pour tokens JWT
8. **Dio interceptors** pour refresh token automatique
9. **Either<Failure, Success>** pour gestion erreurs
10. **Widgets réutilisables** (AppButton, KpiCard, PinPad)
11. **local_auth avec `biometricOnly: false`** pour accepter toutes méthodes de déverrouillage

### ❌ CE QUE TU NE DOIS PAS FAIRE

1. Ne génère PAS le backend (c'est Spring Boot)
2. Ne génère PAS le web (c'est React)
3. N'utilise PAS Provider ou Riverpod (uniquement BLoC)
4. N'utilise PAS SharedPreferences pour tokens (uniquement FlutterSecureStorage)
5. Ne permets PAS de scanner QR sans déverrouillage téléphone
6. Ne stocke PAS de données sensibles en clair
7. Ne mets PAS de logique métier dans les Widgets
8. N'utilise PAS `biometricOnly: true` dans local_auth (accepter toutes méthodes)

### 🔥 ORDRE DE GÉNÉRATION RECOMMANDÉ

**Phase 1 : Configuration**
1. pubspec.yaml (toutes les dépendances)
2. Structure dossiers complète
3. Constants (API URLs, couleurs, styles)
4. Exceptions et Failures

**Phase 2 : Services Core**
5. DioClient (configuration HTTP)
6. StorageService (FlutterSecureStorage)
7. DeviceUnlockService (local_auth avec `biometricOnly: false`)
8. Dio Interceptors (JWT + refresh token)

**Phase 3 : Models & Data**
9. Tous les models Freezed (User, Zone, Access, Attendance, etc.)
10. APIs (AuthApi, AccessApi, AttendanceApi, etc.)
11. Repositories (implémentations avec Either)

**Phase 4 : Domain**
12. Entities (classes simples)
13. UseCases (tous)

**Phase 5 : Injection**
14. GetIt setup complet (injection_container.dart)

**Phase 6 : Auth Flow**
15. AuthBloc (events, states, bloc)
16. SplashScreen
17. LoginScreen

**Phase 7 : Access Flow ⭐ PRIORITÉ**
18. AccessBloc (events, states, bloc)
19. DeviceUnlockScreen (déverrouillage natif téléphone)
20. QRScannerScreen
21. PinEntryScreen
22. AccessGrantedScreen
23. AccessDeniedScreen

**Phase 8 : Dashboard**
24. DashboardBloc
25. DashboardScreen (KPIs + graphique)
26. Widgets réutilisables

**Phase 9 : Attendance**
27. AttendanceBloc
28. AttendanceScreen
29. AttendanceHistoryScreen

**Phase 10 : Reste**
30. MyZonesScreen
31. AccessRequestsScreen
32. CreateRequestScreen
33. ProfileScreen

---

## 🎓 CONCEPTS CLÉS À COMPRENDRE

### Déverrouillage Natif vs Biométrie Spécifique

**Analogie** : C'est comme utiliser la clé de sa maison.

**Déverrouillage natif** (ce qu'on fait) :
- C'est la clé que tu utilises DÉJÀ pour déverrouiller ton téléphone
- Peut être : Empreinte, Face, Schéma, PIN, Mot de passe
- L'app vérifie juste "As-tu déverrouillé ton téléphone récemment ?"
- Comme demander : "As-tu ouvert la porte de ta maison ?"

**Biométrie spécifique** (ce qu'on NE fait PAS) :
- Créer une nouvelle serrure biométrique juste pour l'app
- Forcer uniquement empreinte ou face
- Comme installer une nouvelle porte avec sa propre clé

**Pourquoi natif** :
- Plus pratique : User utilise sa méthode habituelle
- Plus inclusif : Accepte toutes les méthodes (pas seulement biométrie)
- Plus simple : Pas besoin de configurer une nouvelle authentification

### BLoC Pattern

**Analogie** : Le BLoC est comme un chef d'orchestre.
- **Event** = Partition musicale (instruction)
- **BLoC** = Chef d'orchestre (décide quoi jouer)
- **State** = Musique jouée (résultat)
- **UI** = Audience (écoute et réagit)

### Either<Failure, Success>

**Analogie** : Comme un colis qu'on reçoit.
- Soit il contient ce qu'on voulait (Success)
- Soit il contient un message d'erreur (Failure)
- On ouvre le colis avec `.fold()` pour savoir

### Freezed

**Analogie** : Comme un moule à gâteau.
- On définit la forme (User, Zone, etc.)
- Freezed fabrique automatiquement le gâteau complet (avec toutes les méthodes)

### Clean Architecture

**Analogie** : Comme une maison à 3 étages.
- **Étage 3 (Presentation)** : Les pièces visibles (salon, cuisine)
- **Étage 2 (Domain)** : Les règles de la maison (interdictions, horaires)
- **Étage 1 (Data)** : Les fondations et la plomberie (invisible mais critique)

---

**Résumé en une phrase** : Application mobile Flutter avec architecture Clean et BLoC pattern, permettant aux employés multi-postes de scanner des QR codes (après déverrouillage natif du téléphone obligatoire) pour accéder aux zones, pointer leur présence, et gérer leurs demandes d'accès temporaires via une API REST sécurisée par JWT.