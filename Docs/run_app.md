# Correr la Aplicación (Frontend)

La aplicación está construida utilizando el SDK de Flutter.

## Pre-requisitos
- Flutter SDK instalado (versión 3.10 o superior).
- Un emulador (Android / iOS) configurado, o un dispositivo físico conectado.
- Android Studio o VSCode con las extensiones de Flutter.

## Pasos de Instalación

1. Navegar a la carpeta de la App:
   ```bash
   cd APP/trivia_app
   ```

2. Instalar las dependencias:
   Descarga todos los paquetes necesarios especificados en el `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. Configurar la URL del Backend:
   La aplicación se conecta por defecto a `http://localhost:8000` (o la IP equivalente de tu emulador, como `10.0.2.2` para el emulador de Android). Revisa el archivo de configuración o constantes de la red en el código fuente para ajustar la IP al servidor donde estés ejecutando la API.

4. Iniciar la aplicación:
   ```bash
   flutter run
   ```

## Notas Importantes sobre SQLite
La persistencia local en SQLite se maneja automáticamente. Si necesitas probar el vaciado automático de la base de datos local al expirar el token, puedes cerrar la sesión, o limpiar los datos de la app en las configuraciones del dispositivo/emulador. No hay migraciones de datos de sesión persistidas en el tiempo.
