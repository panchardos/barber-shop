# Backend de demo - La Nota Barber Shop

Servidor Dart + SQLite para la demo web por Wi-Fi.

## Requisitos

- Dart SDK.
- Flutter Web compilado en `build/web`.

## Configuración

1. Copiar `.env.example` a `.env`.
2. Completar:
   - `ADMIN_USER`
   - `ADMIN_PASSWORD`
   - `PORT`
   - `DEMO_RESET`
   - `DB_PATH`
   - `WEB_DIR`

`server/.env` está ignorado por Git. No commitearlo.

## Ejecutar

Desde la raíz del proyecto:

```powershell
.\run_demo.ps1
```

O manualmente:

```powershell
flutter build web --release
cd server
dart pub get
dart run bin/server.dart
```

El servidor sirve Flutter Web y la API en el mismo puerto, por lo que no hay
CORS en la demo.

## API pública

```text
GET  /api/health
GET  /api/services
GET  /api/config
GET  /api/ocupados?fecha=YYYY-MM-DD
POST /api/appointments
POST /api/auth/login
```

## API de administrador

Requiere `Authorization: Bearer <token>`.

```text
GET    /api/appointments?fecha=YYYY-MM-DD
GET    /api/appointments?telefono=...
DELETE /api/appointments/:id
POST   /api/services
PATCH  /api/services/:id/price
PUT    /api/config
POST   /api/demo/reset
```

## Seguridad de demo

- El admin se autentica con credenciales de `.env`.
- El token vive en memoria.
- El cliente es anónimo.
- No se usan cookies ni localStorage para el admin.
- `/api/demo/reset` está protegido y depende de `DEMO_RESET=true`.
- No publicar este servidor en internet.
