# Guía para Agregar Avatares Predefinidos

## Ubicación de Archivos
Los avatares predefinidos deben colocarse en la carpeta `public/img/` con los siguientes nombres:
- `avatar-1.png`
- `avatar-2.png`
- `avatar-3.png`
- `avatar-4.png`
- `avatar-5.png`
- `avatar-6.png`
- `avatar-7.png`
- `avatar-8.png`

## Especificaciones Recomendadas
- **Formato**: PNG o JPG
- **Tamaño**: 120x120 píxeles (mínimo)
- **Forma**: Cuadrada (se recortará a círculo automáticamente)
- **Peso**: Máximo 100KB por imagen

## Opciones para Crear Avatares

### 1. Servicios Online Gratuitos
- **UI Avatars**: https://ui-avatars.com/ (genera avatares con iniciales)
- **DiceBear**: https://avatars.dicebear.com/ (avatares estilo pixel art)
- **RoboHash**: https://robohash.org/ (avatares de robots únicos)
- **Boring Avatars**: https://boringavatars.com/ (avatares geométricos)

### 2. Herramientas de Diseño
- **Canva**: https://canva.com (plantillas gratuitas)
- **GIMP**: Software gratuito de edición de imágenes
- **Inkscape**: Editor de gráficos vectoriales gratuito

### 3. Generadores de Avatares
- **Avatar Maker**: https://avatarmaker.com/
- **Picrew**: https://picrew.me/ (creador de personajes)
- **Charat**: https://charat.me/ (generador de personajes anime)

## Cómo Agregar Nuevos Avatares

1. **Crear o descargar** la imagen del avatar
2. **Redimensionar** a 120x120 píxeles
3. **Guardar** con el nombre correspondiente (avatar-1.png, avatar-2.png, etc.)
4. **Colocar** en la carpeta `public/img/`
5. **Actualizar** el array en `js/avatar-manager.js` si agregas más de 8

## Personalización

Si quieres agregar más avatares, edita el archivo `js/avatar-manager.js` y modifica el array `avataresPredefinidos`:

```javascript
this.avataresPredefinidos = [
    'img/avatar-1.png',
    'img/avatar-2.png', 
    'img/avatar-3.png',
    'img/avatar-4.png',
    'img/avatar-5.png',
    'img/avatar-6.png',
    'img/avatar-7.png',
    'img/avatar-8.png',
    'img/avatar-9.png',  // Nuevo avatar
    'img/avatar-10.png'  // Otro nuevo avatar
];
```

## Notas Importantes
- Los avatares se cargan dinámicamente desde el JavaScript
- Si un avatar no se puede cargar, se mostrará `avatar-default.png`
- Los usuarios pueden subir sus propias fotos además de seleccionar avatares predefinidos
- Los avatares seleccionados se guardan en el localStorage del navegador
