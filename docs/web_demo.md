# Demo Web por Wi-Fi

## Objetivo

Ejecutar La Nota Barber Shop en navegadores de celulares usando una notebook
como servidor local. No se publica en internet.

## Arquitectura

```text
Celular / navegador
        |
        v
Flutter Web servido por el backend
        |
        v
API Dart Shelf
        |
        v
SQLite (server/data/demo.db)
```

El mismo servidor entrega Flutter Web y la API, por lo que no hay CORS en la
demo.

## Requisitos

- Flutter SDK.
- Dart SDK.
- Notebook y celulares en la misma red Wi-Fi.
- `server/.env` configurado.

## Configuración del servidor

1. Copiar `server/.env.example` a `server/.env`.
2. Completar:
   - `ADMIN_USER`
   - `ADMIN_PASSWORD`
   - `DEMO_RESET`
   - `DB_PATH`
   - `WEB_DIR`

`server/.env` está ignorado por Git. No commitearlo y no mostrarlo al cliente.

## Ejecutar

Desde la raíz del proyecto:

```powershell
.\run_demo.ps1
```

El script:

1. Compila Flutter Web en `build/web`.
2. Inicia el backend.
3. Muestra las IPs locales para abrir desde el celular.

También se puede ejecutar sin recompilar:

```powershell
.\run_demo.ps1 -SkipBuild
```

Manual:

```powershell
flutter build web --release
cd server
dart pub get
dart run bin/server.dart
```

## Acceso

- Notebook: `http://localhost:8080`
- Celular: `http://<IP-de-la-notebook>:8080`

Si el celular no conecta:

- Verificar que estén en la misma Wi-Fi.
- Permitir Dart en el Firewall de Windows.
- Verificar que el puerto 8080 no esté ocupado.
- Probar primero desde el navegador de la notebook.

## Login de administrador

- La reserva del cliente es pública.
- El panel admin requiere usuario y contraseña.
- Las credenciales están en `server/.env`.
- El token vive en memoria; al recargar la página hay que volver a iniciar
  sesión.
- No se usan cookies ni localStorage para el admin.

## API

Pública:

```text
GET  /api/health
GET  /api/services
GET  /api/config
GET  /api/ocupados?fecha=YYYY-MM-DD
POST /api/appointments
POST /api/auth/login
```

Administrador:

```text
GET    /api/appointments?fecha=YYYY-MM-DD
GET    /api/appointments?telefono=...
DELETE /api/appointments/:id
POST   /api/services
PATCH  /api/services/:id/price
PUT    /api/config
POST   /api/demo/reset
```

## Reset de la demo

Opción 1: borrar `server/data/demo.db` y reiniciar el servidor.

Opción 2: con sesión de admin, llamar:

```text
POST /api/demo/reset
```

Solo funciona si `DEMO_RESET=true`.

No se resetea automáticamente al iniciar el servidor: así se puede demostrar
persistencia.

## Desarrollo con Flutter Web

Si se ejecuta `flutter run -d chrome`, el frontend corre en otro puerto. En ese
caso usar:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

El backend permite CORS para la demo. Para la entrega final conviene usar el
build servido por el backend, que evita CORS.

## Seguridad

- No publicar el servidor en internet.
- No exponer `server/.env`.
- No loguear credenciales ni tokens.
- No usar datos personales reales en la demo.
- El cliente es anónimo.
- El reset está protegido por token y por `DEMO_RESET=true`.

## Limitaciones actuales

- Sin funcionamiento offline.
- Sin autenticación de clientes.
- Sin galería.
- Sin recordatorios.
- Sin bloqueos excepcionales ni almuerzo.
- Sin migraciones de esquema del servidor más allá de la versión inicial.
