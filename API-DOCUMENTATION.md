# Documentation API - Système de Contrôle d'Accès

Base URL: `http://localhost:8080`

Tous les endpoints (sauf `/api/auth/login`) nécessitent un token JWT dans le header:
```
Authorization: Bearer <token>
```

---

## 1. Authentication (`/api/auth`)

### 1.1 Login
**Endpoint:** `POST /api/auth/login`

**Description:** Authentifier un utilisateur et obtenir des tokens JWT

**Entrée:**
```json
{
  "email": "admin@example.com",
  "password": "admin123"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "email": "admin@example.com",
      "firstname": "System",
      "lastname": "Admin",
      "posts": ["SYSTEM_ADMIN", "DEVELOPER"],
      "department": "IT",
      "isActive": true,
      "hireDate": null,
      "photoUrl": null,
      "failedPinAttempts": 0,
      "accountLockedUntil": null,
      "createdAt": "2025-11-04T19:22:32.3929",
      "updatedAt": "2025-11-04T19:22:32.3929"
    }
  },
  "errors": null,
  "timestamp": "2025-11-04T19:31:24.0452507"
}
```

### 1.2 Refresh Token
**Endpoint:** `POST /api/auth/refresh`

**Description:** Rafraîchir l'access token avec un refresh token

**Entrée:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

**Sortie:** (Identique au login)

### 1.3 Logout
**Endpoint:** `POST /api/auth/logout`

**Description:** Déconnecter l'utilisateur (invalider le refresh token)

**Entrée:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Logout successful",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:31:26.9044575"
}
```

---

## 2. Users (`/api/users`)

### 2.1 Get All Users
**Endpoint:** `GET /api/users`

**Description:** Récupérer la liste de tous les utilisateurs

**Entrée:** Aucune

**Sortie:**
```json
{
  "success": true,
  "message": "Users retrieved",
  "data": [
    {
      "id": 1,
      "email": "admin@example.com",
      "firstname": "System",
      "lastname": "Admin",
      "posts": ["SYSTEM_ADMIN", "DEVELOPER"],
      "department": "IT",
      "isActive": true,
      "hireDate": null,
      "photoUrl": null,
      "failedPinAttempts": 0,
      "accountLockedUntil": null,
      "createdAt": "2025-11-04T19:22:32.3929",
      "updatedAt": "2025-11-04T19:22:32.3929"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 2.2 Get User by ID
**Endpoint:** `GET /api/users/{id}`

**Description:** Récupérer un utilisateur par son ID

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Sortie:** (Même structure que Get All Users, mais avec un seul utilisateur)

### 2.3 Create User
**Endpoint:** `POST /api/users` 🔒 Admin only

**Description:** Créer un nouvel utilisateur

**Entrée:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "firstname": "John",
  "lastname": "Doe",
  "posts": ["EMPLOYEE"],
  "department": "Engineering",
  "phone": "+261340000000",
  "employeeNumber": "EMP001",
  "hireDate": "2025-01-01"
}
```

**Sortie:** (UserResponse de l'utilisateur créé)

### 2.4 Update User
**Endpoint:** `PUT /api/users/{id}` 🔒 Admin only

**Description:** Mettre à jour un utilisateur

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Entrée:**
```json
{
  "firstname": "Jane",
  "lastname": "Doe",
  "posts": ["MANAGER"],
  "department": "Management",
  "phone": "+261340000001"
}
```

**Sortie:** (UserResponse mis à jour)

### 2.5 Delete User
**Endpoint:** `DELETE /api/users/{id}` 🔒 Admin only

**Description:** Supprimer un utilisateur (soft delete)

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Sortie:**
```json
{
  "success": true,
  "message": "User deleted successfully",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 2.6 Activate User
**Endpoint:** `PUT /api/users/{id}/activate` 🔒 Admin only

**Description:** Activer un utilisateur

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Sortie:**
```json
{
  "success": true,
  "message": "User activated successfully",
  "data": { /* UserResponse */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 2.7 Deactivate User
**Endpoint:** `PUT /api/users/{id}/deactivate` 🔒 Admin only

**Description:** Désactiver un utilisateur

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Sortie:** (Identique à Activate)

### 2.8 Reset PIN
**Endpoint:** `PUT /api/users/{id}/reset-pin` 🔒 Admin only

**Description:** Réinitialiser le code PIN d'un utilisateur

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Sortie:**
```json
{
  "success": true,
  "message": "PIN reset successfully",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 2.9 Get User Access Zones
**Endpoint:** `GET /api/users/{id}/access-zones`

**Description:** Récupérer les zones accessibles pour un utilisateur

**Paramètres URL:** `id` (Long) - ID de l'utilisateur

**Sortie:**
```json
{
  "success": true,
  "message": "Access zones retrieved",
  "data": [
    {
      "id": 1,
      "name": "Server Room",
      "building": "Building A",
      "floor": "1st Floor",
      "securityLevel": "HIGH",
      "isActive": true,
      "isOpenToAll": false,
      "qrCode": "ZONE-SERVER-ROOM",
      "allowedPosts": ["SYSTEM_ADMIN", "DEVELOPER"],
      "createdAt": "2025-11-04T19:22:32.123456",
      "updatedAt": "2025-11-04T19:22:32.123456"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

---

## 3. Zones (`/api/zones`)

### 3.1 Get All Zones
**Endpoint:** `GET /api/zones`

**Description:** Récupérer la liste de toutes les zones

**Sortie:**
```json
{
  "success": true,
  "message": "Zones retrieved",
  "data": [
    {
      "id": 1,
      "name": "Server Room",
      "building": "Building A",
      "floor": "1st Floor",
      "securityLevel": "HIGH",
      "isActive": true,
      "isOpenToAll": false,
      "qrCode": "ZONE-SERVER-ROOM",
      "allowedPosts": ["SYSTEM_ADMIN", "DEVELOPER"],
      "createdAt": "2025-11-04T19:22:32.123456",
      "updatedAt": "2025-11-04T19:22:32.123456"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 3.2 Get Zone by ID
**Endpoint:** `GET /api/zones/{id}`

**Description:** Récupérer une zone par son ID

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:** (Même structure que Get All Zones, mais avec une seule zone)

### 3.3 Create Zone
**Endpoint:** `POST /api/zones` 🔒 Admin only

**Description:** Créer une nouvelle zone

**Entrée:**
```json
{
  "name": "Meeting Room A",
  "building": "Building B",
  "floor": "2nd Floor",
  "description": "Large meeting room",
  "securityLevel": "MEDIUM",
  "isOpenToAll": false,
  "allowedPosts": ["MANAGER", "DEVELOPER"],
  "maxCapacity": 20
}
```

**Sortie:** (ZoneResponse de la zone créée)

### 3.4 Update Zone
**Endpoint:** `PUT /api/zones/{id}` 🔒 Admin only

**Description:** Mettre à jour une zone

**Paramètres URL:** `id` (Long) - ID de la zone

**Entrée:** (Même structure que Create Zone)

**Sortie:** (ZoneResponse mis à jour)

### 3.5 Delete Zone
**Endpoint:** `DELETE /api/zones/{id}` 🔒 Admin only

**Description:** Supprimer une zone (soft delete)

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:**
```json
{
  "success": true,
  "message": "Zone deleted successfully",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 3.6 Activate Zone
**Endpoint:** `PUT /api/zones/{id}/activate` 🔒 Admin only

**Description:** Activer une zone

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:**
```json
{
  "success": true,
  "message": "Zone activated successfully",
  "data": { /* ZoneResponse */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 3.7 Deactivate Zone
**Endpoint:** `PUT /api/zones/{id}/deactivate` 🔒 Admin only

**Description:** Désactiver une zone

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:** (Identique à Activate)

### 3.8 Get Zone QR Code
**Endpoint:** `GET /api/zones/{id}/qrcode` 🔒 Admin only

**Description:** Récupérer le QR code d'une zone (image PNG)

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:** Image PNG (Content-Type: image/png)

### 3.9 Regenerate QR Code
**Endpoint:** `POST /api/zones/{id}/regenerate-qr` 🔒 Admin only

**Description:** Régénérer le QR code d'une zone

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:**
```json
{
  "success": true,
  "message": "QR code regenerated successfully",
  "data": { /* ZoneResponse avec nouveau QR code */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 3.10 Get Zone Statistics
**Endpoint:** `GET /api/zones/{id}/stats`

**Description:** Récupérer les statistiques d'une zone

**Paramètres URL:** `id` (Long) - ID de la zone

**Sortie:**
```json
{
  "success": true,
  "message": "Zone statistics retrieved",
  "data": {
    "totalAccesses": 150,
    "accessesGranted": 140,
    "accessesDenied": 10,
    "uniqueUsers": 25,
    "lastAccessTime": "2025-11-04T18:30:00"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 3.11 Get Current Occupants
**Endpoint:** `GET /api/zones/{id}/current-occupants`

**Description:** Récupérer les personnes actuellement présentes dans une zone en temps réel. Retourne tous les utilisateurs qui ont eu un accès GRANTED à cette zone aujourd'hui avec le temps écoulé depuis leur dernier accès.

**Paramètres URL:** `id` (Long) - ID de la zone

**Exemple:** `GET /api/zones/1/current-occupants`

**Sortie:**
```json
{
  "success": true,
  "message": "Current occupants retrieved",
  "data": [
    {
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFirstname": "Alice",
      "userLastname": "Developer",
      "userFullName": "Alice Developer",
      "lastAccessTime": "2025-11-05T08:03:45.481088",
      "minutesSinceLastAccess": 127
    },
    {
      "userId": 2,
      "userEmail": "manager@example.com",
      "userFirstname": "Bob",
      "userLastname": "Manager",
      "userFullName": "Bob Manager",
      "lastAccessTime": "2025-11-05T09:15:30.123456",
      "minutesSinceLastAccess": 55
    }
  ],
  "errors": null,
  "timestamp": "2025-11-05T20:10:45.123456"
}
```

**Note:**
- Les données sont basées sur les accès accordés aujourd'hui (depuis 00:00:00)
- `minutesSinceLastAccess` indique combien de minutes se sont écoulées depuis le dernier accès
- Utile pour afficher en temps réel qui est présent dans une zone

---

## 4. Access Control (`/api/access`)

### 4.1 Verify Access (QR Code Scan)
**Endpoint:** `POST /api/access/verify`

**Description:** Vérifier l'accès d'un utilisateur à une zone (scan QR code)

**Entrée:**
```json
{
  "userId": 1,
  "qrCode": "ZONE-SERVER-ROOM",
  "deviceInfo": "Mobile Android",
  "ipAddress": "192.168.1.100"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Access granted",
  "data": {
    "status": "GRANTED",
    "requiresPin": false,
    "eventId": 123,
    "zoneName": "Server Room",
    "timestamp": "2025-11-04T19:32:00.123456"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

**Sortie (Accès refusé):**
```json
{
  "success": false,
  "message": "Access denied",
  "data": {
    "status": "DENIED",
    "reason": "Insufficient permissions",
    "eventId": 124,
    "zoneName": "Server Room",
    "timestamp": "2025-11-04T19:32:00.123456"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 4.2 Verify PIN
**Endpoint:** `POST /api/access/verify-pin`

**Description:** Vérifier le code PIN après scan QR

**Entrée:**
```json
{
  "userId": 1,
  "pinCode": "1234",
  "eventId": 123
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "PIN verified - Access granted",
  "data": {
    "status": "GRANTED",
    "deviceUnlocked": true,
    "timestamp": "2025-11-04T19:32:00.123456"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 4.3 Get Access History
**Endpoint:** `GET /api/access/history`

**Description:** Récupérer l'historique des accès

**Paramètres Query:**
- `userId` (optionnel) - Filtrer par utilisateur
- `zoneId` (optionnel) - Filtrer par zone
- `dateStart` (optionnel) - Date de début (ISO DateTime)
- `dateEnd` (optionnel) - Date de fin (ISO DateTime)

**Exemple:** `GET /api/access/history?userId=3`

**Sortie:**
```json
{
  "success": true,
  "message": "Access history retrieved",
  "data": [
    {
      "id": 2,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "zoneId": 2,
      "zoneName": "Office Space",
      "timestamp": "2025-11-05T08:03:45.481088",
      "status": "GRANTED",
      "method": "QR",
      "reason": null,
      "deviceUnlocked": null,
      "ipAddress": null
    },
    {
      "id": 1,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "zoneId": 1,
      "zoneName": "Entrance Hall",
      "timestamp": "2025-11-05T07:53:45.481088",
      "status": "GRANTED",
      "method": "QR",
      "reason": null,
      "deviceUnlocked": null,
      "ipAddress": null
    },
    {
      "id": 9,
      "userId": 5,
      "userEmail": "guest@example.com",
      "userFullName": "Guest User",
      "zoneId": 3,
      "zoneName": "Server Room",
      "timestamp": "2025-11-05T12:53:45.481088",
      "status": "DENIED",
      "method": "QR",
      "reason": "Postes non autorisés pour cette zone",
      "deviceUnlocked": null,
      "ipAddress": null
    }
  ],
  "errors": null,
  "timestamp": "2025-11-05T17:33:26.2435495"
}
```

### 4.4 Get Access Statistics
**Endpoint:** `GET /api/access/stats`

**Description:** Récupérer les statistiques des accès

**Paramètres Query (obligatoires):**
- `dateStart` - Date de début (ISO DateTime)
- `dateEnd` - Date de fin (ISO DateTime)

**Exemple:** `GET /api/access/stats?dateStart=2025-11-04T00:00:00&dateEnd=2025-11-05T23:59:59`

**Sortie:**
```json
{
  "success": true,
  "message": "Access statistics retrieved",
  "data": {
    "totalAccesses": 15,
    "grantedAccesses": 12,
    "deniedAccesses": 3,
    "pendingPinAccesses": 0,
    "accessesByStatus": null,
    "accessesByMethod": null,
    "topZones": null,
    "topUsers": null,
    "accessesByHour": null,
    "startDate": "2025-11-04T00:00:00",
    "endDate": "2025-11-05T23:59:59",
    "generatedAt": "2025-11-05T17:36:06.5295946"
  },
  "errors": null,
  "timestamp": "2025-11-05T17:36:06.5316034"
}
```

**Note:** Les champs `accessesByStatus`, `accessesByMethod`, `topZones`, `topUsers`, et `accessesByHour` peuvent être null si non implémentés ou si insuffisamment de données.

### 4.5 Get All Access Events
**Endpoint:** `GET /api/access/all` 🔒 Admin only

**Description:** Récupérer tous les événements d'accès de tous les utilisateurs dans toutes les zones. Permet à l'admin de superviser tous les accès au système.

**Paramètres Query (tous optionnels):**
- `startDate` - Date de début (ISO DateTime format)
- `endDate` - Date de fin (ISO DateTime format)

**Exemple:** `GET /api/access/all`

**Exemple avec filtres:** `GET /api/access/all?startDate=2025-11-05T00:00:00&endDate=2025-11-05T23:59:59`

**Sortie:**
```json
{
  "success": true,
  "message": "All access events retrieved",
  "data": [
    {
      "id": 18,
      "userId": 5,
      "userEmail": "guest@example.com",
      "userFullName": "Guest User",
      "zoneId": 4,
      "zoneName": "Meeting Room A",
      "timestamp": "2025-11-05T14:53:45.481088",
      "status": "GRANTED",
      "method": "QR",
      "reason": null,
      "deviceUnlocked": null,
      "ipAddress": null
    },
    {
      "id": 15,
      "userId": 4,
      "userEmail": "qa@example.com",
      "userFullName": "Charlie QA",
      "zoneId": 2,
      "zoneName": "Office Space",
      "timestamp": "2025-11-05T13:53:45.481088",
      "status": "GRANTED",
      "method": "QR",
      "reason": null,
      "deviceUnlocked": null,
      "ipAddress": null
    },
    {
      "id": 9,
      "userId": 5,
      "userEmail": "guest@example.com",
      "userFullName": "Guest User",
      "zoneId": 3,
      "zoneName": "Server Room",
      "timestamp": "2025-11-05T12:53:45.481088",
      "status": "DENIED",
      "method": "QR",
      "reason": "Postes non autorisés pour cette zone",
      "deviceUnlocked": null,
      "ipAddress": null
    }
  ],
  "errors": null,
  "timestamp": "2025-11-05T20:15:00.123456"
}
```

**Note:**
- Par défaut (sans filtres), retourne TOUS les accès enregistrés
- Les résultats sont triés par timestamp décroissant (plus récent en premier)
- Inclut tous les statuts: GRANTED, DENIED, PENDING_PIN
- Utile pour la supervision globale et l'audit

---

## 5. Access Requests (`/api/access-requests`)

### 5.1 Get My Requests
**Endpoint:** `GET /api/access-requests/my-requests`

**Description:** Récupérer mes demandes d'accès

**Paramètres Query:** `userId` (Long) - ID de l'utilisateur

**Exemple:** `GET /api/access-requests/my-requests?userId=1`

**Sortie:**
```json
{
  "success": true,
  "message": "My access requests retrieved",
  "data": [
    {
      "id": 1,
      "userId": 1,
      "userEmail": "user@example.com",
      "userFullName": "John Doe",
      "zoneId": 4,
      "zoneName": "Meeting Room A",
      "startDate": "2025-11-05T09:00:00",
      "endDate": "2025-11-05T17:00:00",
      "justification": "Client meeting",
      "status": "PENDING",
      "adminNote": null,
      "reviewedById": null,
      "reviewedByEmail": null,
      "reviewedAt": null,
      "createdAt": "2025-11-04T19:22:35.123456",
      "updatedAt": "2025-11-04T19:22:35.123456"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 5.2 Create Access Request
**Endpoint:** `POST /api/access-requests`

**Description:** Créer une nouvelle demande d'accès temporaire

**Entrée:**
```json
{
  "userId": 5,
  "zoneId": 4,
  "startDate": "2025-11-05T09:00:00",
  "endDate": "2025-11-05T17:00:00",
  "justification": "Need access for client meeting"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Access request created successfully",
  "data": { /* AccessRequestResponse */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 5.3 Get Pending Requests
**Endpoint:** `GET /api/access-requests/pending` 🔒 Admin only

**Description:** Récupérer toutes les demandes en attente

**Sortie:**
```json
{
  "success": true,
  "message": "Pending access requests retrieved",
  "data": [
    { /* AccessRequestResponse avec status: PENDING */ }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 5.4 Get Request History
**Endpoint:** `GET /api/access-requests/history` 🔒 Admin only

**Description:** Récupérer l'historique des demandes traitées (APPROVED + REJECTED)

**Sortie:**
```json
{
  "success": true,
  "message": "Access requests history retrieved",
  "data": [
    {
      "id": 2,
      "userId": 5,
      "userEmail": "guest@example.com",
      "userFullName": "Guest User",
      "zoneId": 4,
      "zoneName": "Meeting Room A",
      "startDate": "2025-11-04T19:22:35.611717",
      "endDate": "2025-11-04T21:22:35.611717",
      "justification": "Réunion client",
      "status": "APPROVED",
      "adminNote": "Approuvé pour la réunion",
      "reviewedById": 2,
      "reviewedByEmail": "manager@example.com",
      "reviewedAt": "2025-11-04T19:30:00",
      "createdAt": "2025-11-04T19:22:35.627715",
      "updatedAt": "2025-11-04T19:22:35.627715"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 5.5 Get Request by ID
**Endpoint:** `GET /api/access-requests/{id}`

**Description:** Récupérer une demande par son ID

**Paramètres URL:** `id` (Long) - ID de la demande

**Sortie:** (AccessRequestResponse)

### 5.6 Approve Request
**Endpoint:** `PUT /api/access-requests/{id}/approve` 🔒 Admin only

**Description:** Approuver une demande d'accès

**Paramètres URL:** `id` (Long) - ID de la demande

**Entrée:**
```json
{
  "adminId": 1,
  "adminNote": "Approved for client meeting"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Access request approved successfully",
  "data": { /* AccessRequestResponse avec status: APPROVED */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 5.7 Reject Request
**Endpoint:** `PUT /api/access-requests/{id}/reject` 🔒 Admin only

**Description:** Rejeter une demande d'accès

**Paramètres URL:** `id` (Long) - ID de la demande

**Entrée:**
```json
{
  "adminId": 1,
  "adminNote": "Insufficient justification"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Access request rejected successfully",
  "data": { /* AccessRequestResponse avec status: REJECTED */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

---

## 6. Alerts (`/api/alerts`)

### 6.1 Get All Alerts
**Endpoint:** `GET /api/alerts`

**Description:** Récupérer toutes les alertes avec filtres

**Paramètres Query (tous optionnels):**
- `type` - Type d'alerte (ACCESS_DENIED, MULTIPLE_ATTEMPTS, PIN_FAILED)
- `severity` - Sévérité (LOW, MEDIUM, HIGH, CRITICAL)
- `isHandled` - Statut traité (true/false)
- `dateStart` - Date de début (ISO DateTime)
- `dateEnd` - Date de fin (ISO DateTime)

**Exemple:** `GET /api/alerts?isHandled=false&severity=HIGH`

**Sortie:**
```json
{
  "success": true,
  "message": "Alerts retrieved",
  "data": [
    {
      "id": 1,
      "type": "ACCESS_DENIED",
      "severity": "HIGH",
      "message": "Multiple access denied attempts detected",
      "userId": 5,
      "userEmail": "user@example.com",
      "zoneId": 1,
      "zoneName": "Server Room",
      "timestamp": "2025-11-04T19:20:00",
      "isHandled": false,
      "handledAt": null,
      "handledById": null,
      "handledByEmail": null,
      "adminNote": null,
      "createdAt": "2025-11-04T19:20:00"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 6.2 Get Alert by ID
**Endpoint:** `GET /api/alerts/{id}`

**Description:** Récupérer une alerte par son ID

**Paramètres URL:** `id` (Long) - ID de l'alerte

**Sortie:** (AlertResponse)

### 6.3 Handle Alert
**Endpoint:** `PUT /api/alerts/{id}/handle` 🔒 Admin only

**Description:** Marquer une alerte comme traitée

**Paramètres URL:** `id` (Long) - ID de l'alerte

**Entrée:**
```json
{
  "handledBy": 1,
  "adminNote": "Issue resolved - user permissions updated"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Alert handled successfully",
  "data": { /* AlertResponse avec isHandled: true */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 6.4 Get Alert Statistics
**Endpoint:** `GET /api/alerts/stats`

**Description:** Récupérer les statistiques des alertes

**Paramètres Query (optionnels):**
- `dateStart` - Date de début (ISO DateTime)
- `dateEnd` - Date de fin (ISO DateTime)

**Sortie:**
```json
{
  "success": true,
  "message": "Alert statistics retrieved",
  "data": {
    "totalAlerts": 50,
    "unhandledAlerts": 10,
    "alertsByType": {
      "ACCESS_DENIED": 30,
      "MULTIPLE_ATTEMPTS": 15,
      "PIN_FAILED": 5
    },
    "alertsBySeverity": {
      "CRITICAL": 5,
      "HIGH": 15,
      "MEDIUM": 20,
      "LOW": 10
    }
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

---

## 7. Anomalies (`/api/anomalies`)

### 7.1 Get All Anomalies
**Endpoint:** `GET /api/anomalies`

**Description:** Récupérer toutes les anomalies avec filtres

**Paramètres Query (tous optionnels):**
- `status` - Statut (NEW, PENDING, INVESTIGATED, INVESTIGATING, SUSPECT, FALSE_POSITIVE, RESOLVED)
- `severity` - Sévérité (LOW, MEDIUM, HIGH, CRITICAL)
- `userId` - Filtrer par utilisateur
- `dateStart` - Date de début (ISO DateTime)
- `dateEnd` - Date de fin (ISO DateTime)

**Exemple:** `GET /api/anomalies?status=NEW&severity=HIGH`

**Sortie:**
```json
{
  "success": true,
  "message": "Anomalies retrieved",
  "data": [
    {
      "id": 1,
      "type": "UNUSUAL_TIME",
      "severity": "HIGH",
      "status": "NEW",
      "description": "Access detected outside normal hours",
      "score": 0.85,
      "userId": 3,
      "userEmail": "user@example.com",
      "zoneId": 1,
      "zoneName": "Server Room",
      "detectionDate": "2025-11-04T03:00:00",
      "investigatedAt": null,
      "investigatedById": null,
      "investigatedByEmail": null,
      "investigationNotes": null,
      "resolvedAt": null,
      "shapBarImage": null,
      "shapWaterfallImage": null,
      "featuresData": null,
      "topReasons": ["Access at 3:00 AM", "Unusual pattern detected"],
      "createdAt": "2025-11-04T03:01:00"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 7.2 Get Anomaly by ID
**Endpoint:** `GET /api/anomalies/{id}`

**Description:** Récupérer une anomalie par son ID

**Paramètres URL:** `id` (Long) - ID de l'anomalie

**Sortie:** (AnomalyResponse)

### 7.3 Investigate Anomaly
**Endpoint:** `PUT /api/anomalies/{id}/investigate` 🔒 Admin only

**Description:** Marquer une anomalie comme en cours d'investigation

**Paramètres URL:** `id` (Long) - ID de l'anomalie

**Entrée:**
```json
{
  "investigatedBy": 1,
  "investigationNotes": "Checking user activity logs",
  "newStatus": "INVESTIGATING"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Anomaly investigation updated successfully",
  "data": { /* AnomalyResponse avec status: INVESTIGATING */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 7.4 Mark as False Positive
**Endpoint:** `PUT /api/anomalies/{id}/mark-false-positive` 🔒 Admin only

**Description:** Marquer une anomalie comme faux positif

**Paramètres URL:** `id` (Long) - ID de l'anomalie

**Entrée:**
```json
{
  "investigatedBy": 1,
  "investigationNotes": "Verified with user - legitimate overtime work"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Anomaly marked as false positive successfully",
  "data": { /* AnomalyResponse avec status: FALSE_POSITIVE */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 7.5 Create Anomaly Exception
**Endpoint:** `POST /api/anomalies/{id}/exceptions` 🔒 Admin only

**Description:** Créer une exception pour une anomalie (ne plus détecter ce pattern)

**Paramètres URL:** `id` (Long) - ID de l'anomalie

**Entrée:**
```json
{
  "createdBy": 1,
  "conditions": "User ID: 3, Time: 03:00-05:00, Zone: Server Room - Approved night shift"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Anomaly exception created successfully",
  "data": {
    "id": 1,
    "anomalyId": 1,
    "userId": 3,
    "conditions": "User ID: 3, Time: 03:00-05:00, Zone: Server Room - Approved night shift",
    "createdById": 1,
    "createdByEmail": "admin@example.com",
    "createdAt": "2025-11-04T19:32:00"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 7.6 Get Anomaly Statistics
**Endpoint:** `GET /api/anomalies/stats`

**Description:** Récupérer les statistiques des anomalies

**Sortie:**
```json
{
  "success": true,
  "message": "Anomaly statistics retrieved",
  "data": {
    "totalAnomalies": 100,
    "newAnomalies": 20,
    "investigating": 10,
    "resolved": 50,
    "falsePositives": 20,
    "anomaliesByType": {
      "UNUSUAL_TIME": 40,
      "UNUSUAL_ZONE": 30,
      "SUSPICIOUS_BEHAVIOR": 20,
      "MULTIPLE_FAILED_ATTEMPTS": 10
    },
    "anomaliesBySeverity": {
      "CRITICAL": 10,
      "HIGH": 30,
      "MEDIUM": 40,
      "LOW": 20
    }
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

---

## 8. Attendance (`/api/attendance`)

### 8.1 Check-In
**Endpoint:** `POST /api/attendance/check-in`

**Description:** Pointer l'arrivée (nécessite QR code + PIN)

**Entrée:**
```json
{
  "userId": 1,
  "qrCode": "ZONE-ENTRANCE",
  "pinCode": "1234",
  "checkInTime": "2025-11-04T08:30:00",
  "location": "Main Entrance"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Check-in successful",
  "data": {
    "id": 1,
    "userId": 1,
    "userEmail": "user@example.com",
    "date": "2025-11-04",
    "checkIn": "2025-11-04T08:30:00",
    "checkOut": null,
    "hoursWorked": null,
    "isLate": true,
    "createdAt": "2025-11-04T08:30:00",
    "updatedAt": "2025-11-04T08:30:00"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 8.2 Check-Out
**Endpoint:** `POST /api/attendance/check-out`

**Description:** Pointer la sortie (nécessite QR code + PIN)

**Entrée:**
```json
{
  "userId": 1,
  "qrCode": "ZONE-ENTRANCE",
  "pinCode": "1234",
  "checkOutTime": "2025-11-04T17:30:00",
  "location": "Main Entrance"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Check-out successful",
  "data": {
    "id": 1,
    "userId": 1,
    "userEmail": "user@example.com",
    "date": "2025-11-04",
    "checkIn": "2025-11-04T08:30:00",
    "checkOut": "2025-11-04T17:30:00",
    "hoursWorked": 9.0,
    "isLate": true,
    "createdAt": "2025-11-04T08:30:00",
    "updatedAt": "2025-11-04T17:30:00"
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 8.3 Get My Attendance Today
**Endpoint:** `GET /api/attendance/today`

**Description:** Récupérer mon pointage du jour

**Paramètres Query:** `userId` (Long) - ID de l'utilisateur

**Exemple:** `GET /api/attendance/today?userId=3`

**Sortie:**
```json
{
  "success": true,
  "message": "Today's attendance retrieved",
  "data": {
    "id": 1,
    "userId": 3,
    "userEmail": "developer@example.com",
    "userFullName": "Alice Developer",
    "date": "2025-11-05",
    "checkIn": "2025-11-05T07:05:45.58809",
    "checkOut": null,
    "hoursWorked": null,
    "isLate": false,
    "isCompleted": false,
    "isOngoing": true,
    "createdAt": "2025-11-05T15:53:45.591088",
    "updatedAt": "2025-11-05T15:53:45.591088"
  },
  "errors": null,
  "timestamp": "2025-11-05T17:35:19.7770109"
}
```

### 8.4 Get Attendance History
**Endpoint:** `GET /api/attendance/history`

**Description:** Récupérer l'historique des pointages

**Paramètres Query:**
- `userId` (obligatoire) - ID de l'utilisateur
- `startDate` (optionnel) - Date de début (ISO Date)
- `endDate` (optionnel) - Date de fin (ISO Date)

**Exemple:** `GET /api/attendance/history?userId=3&startDate=2025-10-01&endDate=2025-11-30`

**Sortie:**
```json
{
  "success": true,
  "message": "Attendance history retrieved",
  "data": [
    {
      "id": 12,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "date": "2025-11-02",
      "checkIn": "2025-11-02T09:05:45.58809",
      "checkOut": "2025-11-02T18:00:45.58809",
      "hoursWorked": 8.92,
      "isLate": false,
      "isCompleted": true,
      "isOngoing": false,
      "createdAt": "2025-11-05T15:53:45.62409",
      "updatedAt": "2025-11-05T15:53:45.62409"
    },
    {
      "id": 10,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "date": "2025-11-03",
      "checkIn": "2025-11-03T09:25:45.58809",
      "checkOut": "2025-11-03T18:30:45.58809",
      "hoursWorked": 9.08,
      "isLate": true,
      "isCompleted": true,
      "isOngoing": false,
      "createdAt": "2025-11-05T15:53:45.620089",
      "updatedAt": "2025-11-05T15:53:45.620089"
    },
    {
      "id": 6,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "date": "2025-11-04",
      "checkIn": "2025-11-04T09:00:45.58809",
      "checkOut": "2025-11-04T18:15:45.58809",
      "hoursWorked": 9.25,
      "isLate": false,
      "isCompleted": true,
      "isOngoing": false,
      "createdAt": "2025-11-05T15:53:45.60909",
      "updatedAt": "2025-11-05T15:53:45.60909"
    },
    {
      "id": 1,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "date": "2025-11-05",
      "checkIn": "2025-11-05T07:05:45.58809",
      "checkOut": null,
      "hoursWorked": null,
      "isLate": false,
      "isCompleted": false,
      "isOngoing": true,
      "createdAt": "2025-11-05T15:53:45.591088",
      "updatedAt": "2025-11-05T15:53:45.591088"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-05T17:35:36.4948945"
}
```

### 8.5 Correct Attendance
**Endpoint:** `PUT /api/attendance/{id}/correct` 🔒 Admin only

**Description:** Corriger un pointage (erreur ou oubli)

**Paramètres URL:** `id` (Long) - ID du pointage

**Entrée:**
```json
{
  "newCheckIn": "2025-11-06T08:00:00",
  "newCheckOut": "2025-11-06T17:00:00",
  "reason": "Test de correction"
}
```

**Sortie:**
```json
{
  "success": true,
  "message": "Attendance corrected successfully",
  "data": { /* AttendanceResponse corrigé */ },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 8.6 Get Monthly Statistics
**Endpoint:** `GET /api/attendance/stats`

**Description:** Récupérer les statistiques mensuelles de pointage

**Paramètres Query:**
- `userId` (obligatoire) - ID de l'utilisateur
- `month` (optionnel) - Mois (1-12, défaut: mois actuel)
- `year` (optionnel) - Année (défaut: année actuelle)

**Exemple:** `GET /api/attendance/stats?userId=3`

**Sortie:**
```json
{
  "success": true,
  "message": "Attendance statistics retrieved",
  "data": {
    "userId": 3,
    "userFullName": "Alice Developer",
    "startDate": "2025-11-01",
    "endDate": "2025-11-30",
    "totalDaysWorked": 4,
    "totalHoursWorked": 27.25,
    "averageHoursPerDay": 6.8125,
    "totalLateArrivals": 1,
    "generatedAt": "2025-11-05T17:35:40.7839802"
  },
  "errors": null,
  "timestamp": "2025-11-05T17:35:40.7849798"
}
```

### 8.7 Get All Attendances
**Endpoint:** `GET /api/attendance/all` 🔒 Admin only

**Description:** Récupérer tous les pointages de tous les utilisateurs. Permet à l'admin de superviser l'assiduité globale de l'entreprise.

**Paramètres Query (tous optionnels):**
- `startDate` - Date de début (ISO Date format: YYYY-MM-DD)
- `endDate` - Date de fin (ISO Date format: YYYY-MM-DD)

**Exemple:** `GET /api/attendance/all`

**Exemple avec filtres:** `GET /api/attendance/all?startDate=2025-11-01&endDate=2025-11-30`

**Sortie:**
```json
{
  "success": true,
  "message": "All attendances retrieved",
  "data": [
    {
      "id": 1,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "date": "2025-11-05",
      "checkIn": "2025-11-05T07:05:45.58809",
      "checkOut": null,
      "hoursWorked": null,
      "isLate": false,
      "isCompleted": false,
      "isOngoing": true,
      "createdAt": "2025-11-05T15:53:45.591088",
      "updatedAt": "2025-11-05T15:53:45.591088"
    },
    {
      "id": 6,
      "userId": 3,
      "userEmail": "developer@example.com",
      "userFullName": "Alice Developer",
      "date": "2025-11-04",
      "checkIn": "2025-11-04T09:00:45.58809",
      "checkOut": "2025-11-04T18:15:45.58809",
      "hoursWorked": 9.25,
      "isLate": false,
      "isCompleted": true,
      "isOngoing": false,
      "createdAt": "2025-11-05T15:53:45.60909",
      "updatedAt": "2025-11-05T15:53:45.60909"
    },
    {
      "id": 2,
      "userId": 2,
      "userEmail": "manager@example.com",
      "userFullName": "Bob Manager",
      "date": "2025-11-05",
      "checkIn": "2025-11-05T08:30:45.58809",
      "checkOut": null,
      "hoursWorked": null,
      "isLate": true,
      "isCompleted": false,
      "isOngoing": true,
      "createdAt": "2025-11-05T15:53:45.594087",
      "updatedAt": "2025-11-05T15:53:45.594087"
    }
  ],
  "errors": null,
  "timestamp": "2025-11-05T20:20:00.123456"
}
```

**Note:**
- Par défaut (sans filtres), retourne TOUS les pointages enregistrés
- Les résultats sont triés par date décroissante (plus récent en premier)
- `isOngoing` = true indique un pointage en cours (check-in effectué mais pas encore check-out)
- `isCompleted` = true indique un pointage terminé (check-in et check-out effectués)
- Utile pour générer des rapports globaux d'assiduité

---

### 8.8 Correct Attendance
**Endpoint:** `PUT /api/attendance/{id}/correct` 🔒 Admin only

**Description:** Corriger un pointage existant. Permet à l'admin de modifier les heures de check-in et check-out en cas d'erreur ou d'oubli. Les heures travaillées sont automatiquement recalculées. L'ID de l'administrateur est automatiquement extrait du JWT Bearer token pour des raisons de sécurité.

**Paramètres Path:**
- `id` (required) - ID du pointage à corriger

**Authentication:**
- `Authorization: Bearer {token}` (required) - JWT token de l'administrateur. L'ID admin est automatiquement extrait du token.

**Corps de la requête (AttendanceCorrectRequest):**
```json
{
  "newCheckIn": "2025-11-04T08:00:00",
  "newCheckOut": "2025-11-04T17:00:00",
  "reason": "Correction manuelle - Erreur de pointage"
}
```

**Champs:**
- `newCheckIn` (required) - Nouvelle heure de check-in (ISO DateTime format)
- `newCheckOut` (required) - Nouvelle heure de check-out (ISO DateTime format)
- `reason` (required) - Raison de la correction (pour audit)

**Exemple complet:**
```bash
PUT /api/attendance/11/correct
Authorization: Bearer {token}
Content-Type: application/json

{
  "newCheckIn": "2025-11-04T08:00:00",
  "newCheckOut": "2025-11-04T17:00:00",
  "reason": "Correction manuelle - Oubli de pointage"
}
```

**Note:** L'ID de l'administrateur (adminId) n'est plus requis dans l'URL. Il est automatiquement extrait du JWT Bearer token fourni dans le header Authorization.

**Sortie (succès):**
```json
{
  "success": true,
  "message": "Attendance corrected successfully",
  "data": {
    "id": 11,
    "userId": 1,
    "userEmail": "admin@example.com",
    "userFullName": "System Admin",
    "date": "2025-11-04",
    "checkIn": "2025-11-04T08:00:00",
    "checkOut": "2025-11-04T17:00:00",
    "hoursWorked": 9.0,
    "isLate": false,
    "isCompleted": true,
    "isOngoing": false,
    "createdAt": "2025-11-05T23:29:08.602941",
    "updatedAt": "2025-11-06T10:45:23.123456"
  },
  "errors": null,
  "timestamp": "2025-11-06T10:45:23.123456"
}
```

**Sortie (erreur - Pointage non trouvé):**
```json
{
  "success": false,
  "message": "Attendance not found with id: 999",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-06T10:45:23.123456"
}
```

**Sortie (erreur - Non autorisé):**
```json
{
  "success": false,
  "message": "Access Denied",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-06T10:45:23.123456"
}
```

**Note:**
- ⚠️ **Admin uniquement** : Seuls les administrateurs peuvent corriger les pointages
- 🔐 **Sécurité renforcée** : L'ID de l'admin est automatiquement extrait du JWT Bearer token (pas de paramètre adminId dans l'URL)
- ✅ **Recalcul automatique** : Les heures travaillées sont automatiquement recalculées (newCheckOut - newCheckIn)
- ✅ **Audit trail** : La correction est tracée avec l'ID de l'admin (du JWT) et la raison fournie
- ✅ **Validation** : newCheckOut doit être après newCheckIn
- ✅ **Date mise à jour** : Le champ `updatedAt` est automatiquement mis à jour
- 📝 La raison de correction est obligatoire pour des raisons d'audit
- 🔒 Requiert authentification JWT + rôle ADMIN
- ⏰ Les dates doivent être au format ISO 8601 (YYYY-MM-DDTHH:mm:ss)
- 🛡️ L'extraction automatique de l'adminId du token empêche l'usurpation d'identité

**Cas d'usage:**
- Employé a oublié de pointer en arrivant → L'admin corrige le check-in
- Erreur de scan QR → L'admin rectifie les heures correctes
- Problème technique lors du pointage → L'admin ajuste manuellement
- Correction après vérification des présences → L'admin corrige les écarts

**Workflow recommandé:**
1. Récupérer le pointage à corriger via `GET /api/attendance/history?userId={id}`
2. Vérifier les données actuelles (checkIn, checkOut, hoursWorked)
3. Appeler `PUT /api/attendance/{id}/correct` avec les nouvelles valeurs
4. Vérifier que hoursWorked a été recalculé correctement
5. Un log d'audit est automatiquement créé avec la raison de la correction

---

## 9. Dashboard (`/api/dashboard`)

### 9.1 Get KPIs
**Endpoint:** `GET /api/dashboard/kpis`

**Description:** Récupérer les indicateurs clés de performance

**Sortie:**
```json
{
  "success": true,
  "message": "Dashboard KPIs retrieved",
  "data": {
    "employeesPresent": 45,
    "employeesTotal": 50,
    "accessesToday": 250,
    "accessesGranted": 230,
    "accessesDenied": 20,
    "lateToday": 5,
    "pendingAccessRequests": 3,
    "unhandledAlerts": 8,
    "newAnomalies": 2,
    "criticalAnomalies": 1
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

### 9.2 Get Graphs Data
**Endpoint:** `GET /api/dashboard/graphs`

**Description:** Récupérer les données pour les graphiques du tableau de bord

**Sortie:**
```json
{
  "success": true,
  "message": "Dashboard graphs retrieved",
  "data": {
    "accessesByHour": [
      { "hour": "08:00", "count": 35 },
      { "hour": "09:00", "count": 50 },
      { "hour": "10:00", "count": 45 }
    ],
    "accessesByZone": [
      { "zoneName": "Server Room", "count": 80 },
      { "zoneName": "Meeting Room A", "count": 120 }
    ],
    "attendanceTrend": [
      { "date": "2025-11-01", "present": 48, "late": 3 },
      { "date": "2025-11-02", "present": 47, "late": 5 }
    ],
    "alertsBySeverity": {
      "CRITICAL": 2,
      "HIGH": 10,
      "MEDIUM": 15,
      "LOW": 20
    }
  },
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

---

## Codes d'Erreur

### Erreurs Communes

**400 Bad Request** - Requête invalide
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "data": null,
  "errors": ["Field 'email' is required"],
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

**401 Unauthorized** - Non authentifié
```json
{
  "path": "/api/users",
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource",
  "status": 401
}
```

**403 Forbidden** - Accès refusé (permissions insuffisantes)
```json
{
  "success": false,
  "message": "Access denied - Admin privileges required",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

**404 Not Found** - Ressource non trouvée
```json
{
  "success": false,
  "message": "User not found with id: 999",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

**500 Internal Server Error** - Erreur serveur
```json
{
  "success": false,
  "message": "Une erreur interne s'est produite. Veuillez réessayer plus tard.",
  "data": null,
  "errors": null,
  "timestamp": "2025-11-04T19:32:00.123456"
}
```

---

## Enums Importants

### Post (Postes/Rôles)
- `SYSTEM_ADMIN` - Administrateur système
- `ADMIN` - Administrateur
- `EXECUTIVE` - Exécutif
- `MANAGER` - Manager
- `DEVELOPER` - Développeur
- `ENGINEER` - Ingénieur
- `DEVOPS` - DevOps
- `QA_ENGINEER` - Ingénieur QA
- `SECURITY` - Sécurité
- `SECURITY_MANAGER` - Manager sécurité
- `HR_MANAGER` - Manager RH
- `ACCOUNTANT` - Comptable
- `FINANCE_MANAGER` - Manager finance
- `RECEPTIONIST` - Réceptionniste
- `FACILITY_MANAGER` - Manager des installations
- `INTERN` - Stagiaire
- `CONTRACTOR` - Contractant
- `GUEST` - Invité
- `EMPLOYEE` - Employé

### SecurityLevel (Niveaux de sécurité)
- `LOW` - Faible
- `MEDIUM` - Moyen
- `HIGH` - Élevé

### AlertType (Types d'alerte)
- `ACCESS_DENIED` - Accès refusé
- `MULTIPLE_ATTEMPTS` - Tentatives multiples
- `PIN_FAILED` - Échec PIN

### AlertSeverity / AnomalySeverity (Sévérité)
- `LOW` - Faible
- `MEDIUM` - Moyen
- `HIGH` - Élevé
- `CRITICAL` - Critique

### AnomalyStatus (Statut d'anomalie)
- `NEW` - Nouveau
- `PENDING` - En attente
- `INVESTIGATED` - Investigué
- `INVESTIGATING` - En cours d'investigation
- `SUSPECT` - Suspect
- `FALSE_POSITIVE` - Faux positif
- `RESOLVED` - Résolu

### AnomalyType (Type d'anomalie)
- `UNUSUAL_TIME` - Horaire inhabituel
- `UNUSUAL_ZONE` - Zone inhabituelle
- `UNUSUAL_LOCATION` - Localisation inhabituelle
- `UNUSUAL_FREQUENCY` - Fréquence inhabituelle
- `SUSPICIOUS_BEHAVIOR` - Comportement suspect
- `SUSPICIOUS_PATTERN` - Pattern suspect
- `ML_DETECTED` - Détecté par ML
- `MULTIPLE_FAILED_ATTEMPTS` - Tentatives d'échec multiples
- `AFTER_HOURS_ACCESS` - Accès hors horaires
- `OTHER` - Autre

### AccessRequestStatus (Statut de demande d'accès)
- `PENDING` - En attente
- `APPROVED` - Approuvé
- `REJECTED` - Rejeté

### AccessMethod (Méthode d'accès)
- `QR` - QR code uniquement
- `QR_PIN` - QR code + PIN

### AccessStatus (Statut d'accès)
- `GRANTED` - Accordé
- `DENIED` - Refusé
- `PENDING_PIN` - En attente du PIN

---

## Notes Importantes

1. 🔒 = Endpoint réservé aux administrateurs (nécessite le post `SYSTEM_ADMIN` ou `ADMIN`)
2. Tous les timestamps sont au format ISO 8601: `YYYY-MM-DDTHH:mm:ss`
3. Les dates pour les filtres doivent être au format ISO DateTime: `2025-11-04T19:32:00`
4. Le token JWT expire après 1 heure (3600 secondes)
5. Le refresh token expire après 7 jours
6. Les paramètres de query sont sensibles à la casse
7. Les codes PIN doivent avoir exactement 4 chiffres
8. Les QR codes sont uniques par zone et régénérables

---

## Exemple de Flux Complet

### 1. Authentification
```bash
POST /api/auth/login
{
  "email": "admin@example.com",
  "password": "admin123"
}
```

### 2. Vérifier un accès (Scan QR)
```bash
POST /api/access/verify
Headers: Authorization: Bearer <token>
{
  "userId": 1,
  "qrCode": "ZONE-SERVER-ROOM"
}
```

### 3. Vérifier le PIN (si nécessaire)
```bash
POST /api/access/verify-pin
Headers: Authorization: Bearer <token>
{
  "userId": 1,
  "pinCode": "1234",
  "eventId": 123
}
```

### 4. Consulter l'historique
```bash
GET /api/access/history?userId=1
Headers: Authorization: Bearer <token>
```
