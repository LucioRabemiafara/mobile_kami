# Debug Guide - QR Scanner

## Problème: Le scan QR ne fonctionne pas

### ✅ Vérifications ajoutées

J'ai ajouté des logs de débogage dans les fichiers suivants :
- `qr_scanner_screen.dart` - Logs du scanner
- `access_bloc.dart` - Logs du BLoC et de l'API

### 📱 Comment tester

1. **Lancez l'application en mode debug**
   ```bash
   flutter run
   ```

2. **Ouvrez le scanner QR** (après device unlock)

3. **Regardez les logs dans la console**

### 🔍 Logs à surveiller

#### Étape 1: Scanner démarre
```
🎥 QR Scanner initialized
✅ Scanner started successfully
```
❌ **Si vous voyez** : `❌ Scanner start error` → Problème de permissions caméra

#### Étape 2: Détection QR Code
Scannez un QR code, vous devriez voir :
```
🔍 QR Scanner: _onDetect called
🔍 isScanning: true
🔍 Barcodes found: 1
🔍 QR Code value: ZONE-EXAMPLE
✅ Sending QRCodeScanned event with code: ZONE-EXAMPLE
```

❌ **Si vous voyez** : `⚠️ No barcodes found` → Le scanner ne détecte pas le QR
❌ **Si vous ne voyez rien** → Le callback onDetect n'est pas appelé

#### Étape 3: BLoC reçoit l'événement
```
📱 AccessBloc: QRCodeScanned event received
📱 QR Code: ZONE-EXAMPLE
📱 State: AccessVerifying emitted
📱 AuthState: AuthAuthenticated(...)
📱 User ID: 1
```

❌ **Si vous voyez** : `❌ User not authenticated` → Problème d'authentification

#### Étape 4: Appel API
```
📱 Calling verifyAccessUseCase...
📱 API Result received
✅ API Success: AccessVerifyResponseModel(...)
📱 Zone: Server Room, Status: GRANTED
✅ Access GRANTED
```

❌ **Si vous voyez** : `❌ API Failure` → Problème de connexion API

---

## 🐛 Solutions selon les erreurs

### 1. Scanner ne démarre pas
**Erreur** : `❌ Scanner start error`

**Solutions** :
- Vérifier les permissions caméra dans les paramètres Android
- Redémarrer l'application
- Tester sur un appareil physique (pas émulateur)

### 2. QR Code non détecté
**Erreur** : `⚠️ No barcodes found` répété

**Solutions** :
- Vérifier que le QR code est clair et bien éclairé
- Essayer avec un autre QR code
- Vérifier le format du QR code (doit être un simple texte)

### 3. Callback non appelé
**Aucun log** quand vous scannez

**Solutions** :
- Vérifier que `mobile_scanner` est à jour
- Rebuild l'app : `flutter clean && flutter pub get && flutter run`

### 4. API ne répond pas
**Erreur** : `❌ API Failure: NetworkFailure`

**Solutions** :
- Vérifier que l'API backend est démarrée
- Vérifier l'URL : `http://192.168.88.28:8080/api`
- Tester l'API avec curl :
  ```bash
  curl -X POST http://192.168.88.28:8080/api/access/verify \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer YOUR_TOKEN" \
    -d '{
      "userId": 1,
      "qrCode": "ZONE-EXAMPLE"
    }'
  ```

---

## 🧪 Générer un QR Code de test

Pour tester, générez un QR code simple avec le texte :
```
ZONE-SERVER-ROOM
```

Sites pour générer :
- https://www.qr-code-generator.com/
- https://www.the-qrcode-generator.com/

---

## 📋 Checklist complète

- [ ] Les permissions caméra sont accordées
- [ ] L'API backend est démarrée
- [ ] L'utilisateur est authentifié (token valide)
- [ ] Le QR code est au bon format
- [ ] Le téléphone peut accéder au réseau (WiFi même réseau que l'API)
- [ ] Les logs montrent que le scanner démarre
- [ ] Les logs montrent que _onDetect est appelé

---

## 🆘 Si rien ne fonctionne

Envoyez-moi une capture d'écran des **logs complets** depuis :
```
🎥 QR Scanner initialized
```
jusqu'à l'erreur.
