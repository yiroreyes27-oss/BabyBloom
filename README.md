# BabyBloom - prototipo Flutter

Este paquete contiene el primer prototipo navegable de BabyBloom.

## Incluye
- Selección inicial de tema visual (niña, niño o neutral).
- Paletas dinámicas de colores.
- Persistencia local del tema elegido.
- Inicio y navegación inferior.
- Secciones iniciales de Mis fotos, Crecimiento y Ajustes.

## Requisitos
- Flutter SDK instalado.
- Android Studio o Android SDK para compilar Android.

## Ejecutar
Desde esta carpeta:

```bash
flutter pub get
flutter run
```

## Generar APK
```bash
flutter build apk --release
```

## Estado
Es un prototipo de interfaz. Todavía no incluye cuentas reales, subida de fotografías,
generación de imágenes con IA, almacenamiento en la nube ni publicación en Google Play.
Esas funciones requieren configurar Firebase, backend seguro y proveedor de IA.
