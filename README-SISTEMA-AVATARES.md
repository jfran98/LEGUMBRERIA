# 🎭 Sistema de Avatares para LEGUMBRERIA

## 📋 Descripción General

Se ha implementado un sistema completo de gestión de avatares para el perfil de usuario en la aplicación LEGUMBRERIA. El sistema permite a los usuarios:

1. **Seleccionar avatares predefinidos** de una colección de diseños establecidos
2. **Subir fotos personalizadas** como avatares
3. **Guardar preferencias** en el navegador
4. **Integración con el backend** para persistencia de datos

## 🗂️ Estructura de Archivos

```
public/
├── perfil.html              # Página principal del perfil (actualizada)
├── js/
│   └── avatar-manager.js    # Gestor de avatares (nuevo)
└── img/
    ├── README-avatares.md   # Guía para agregar avatares
    ├── generar-avatar-default.html    # Generador de avatar por defecto
    └── ejemplo-avatares.html         # Ejemplos y generador de avatares
```

## 🚀 Características Implementadas

### ✨ Selección de Avatares Predefinidos
- **Cuadrícula de 8 avatares** con diferentes colores y estilos
- **Selección visual** con indicador de elemento seleccionado
- **Carga dinámica** desde archivos de imagen
- **Fallback automático** a avatar por defecto si no se encuentra la imagen

### 📸 Subida de Fotos Personalizadas
- **Selector de archivos** con validación de tipo de imagen
- **Vista previa** antes de guardar
- **Botón de guardado** con confirmación visual
- **Soporte para formatos** PNG, JPG, JPEG, GIF

### 💾 Persistencia de Datos
- **localStorage** para guardar preferencias del usuario
- **Integración con backend** para avatares del servidor
- **Sincronización** entre avatares predefinidos y personalizados

### 🎨 Interfaz de Usuario
- **Diseño responsivo** que se adapta a diferentes pantallas
- **Animaciones suaves** para mejor experiencia de usuario
- **Colores consistentes** con el tema de la aplicación
- **Iconos intuitivos** para mejor usabilidad

## 🔧 Cómo Usar

### Para Usuarios Finales

1. **Acceder al perfil**: Navegar a `perfil.html`
2. **Seleccionar avatar predefinido**: Hacer clic en cualquier avatar de la cuadrícula
3. **Subir foto personalizada**: 
   - Hacer clic en "📷 Seleccionar Imagen"
   - Elegir archivo de imagen
   - Ver vista previa
   - Hacer clic en "💾 Guardar Avatar"
4. **Cambiar avatar**: Seleccionar otro avatar predefinido o subir nueva foto

### Para Desarrolladores

1. **Agregar nuevos avatares predefinidos**:
   - Colocar imagen en `public/img/` con nombre `avatar-X.png`
   - Actualizar array en `js/avatar-manager.js`

2. **Personalizar estilos**:
   - Editar CSS en `perfil.html`
   - Modificar colores y dimensiones según necesidades

3. **Integrar con backend**:
   - El sistema ya incluye endpoint para enviar avatares al servidor
   - Ajustar URL en `enviarAvatarAlBackend()` según tu API

## 🎨 Personalización de Avatares

### Generar Avatares por Defecto

1. Abrir `public/img/generar-avatar-default.html` en el navegador
2. Hacer clic en "💾 Descargar Avatar"
3. Renombrar archivo a `avatar-default.png`
4. Colocar en `public/img/`

### Generar Avatares Predefinidos

1. Abrir `public/img/ejemplo-avatares.html` en el navegador
2. Usar "📥 Descargar Todos los Avatares" para los 8 básicos
3. Usar "🎨 Generar Avatares Personalizados" para variaciones
4. Renombrar archivos según el patrón `avatar-1.png`, `avatar-2.png`, etc.

## 🔌 Integración Técnica

### JavaScript (avatar-manager.js)

```javascript
// Inicializar el sistema
const avatarManager = new AvatarManager();

// Agregar nuevo avatar predefinido
avatarManager.agregarAvatarPredefinido('img/nuevo-avatar.png');

// Obtener avatar actual
const avatarActual = avatarManager.obtenerAvatarActual();
```

### HTML (perfil.html)

```html
<!-- Estructura básica -->
<div class="avatar-section">
    <img src="img/avatar-default.png" class="avatar" id="avatar">
    <div class="avatar-options">
        <div class="avatar-grid" id="avatarGrid"></div>
        <div class="upload-section">
            <input type="file" id="fileInput" accept="image/*">
        </div>
    </div>
</div>
```

### CSS Personalización

```css
/* Cambiar colores de tema */
.avatar-options {
    background-color: rgba(56, 142, 60, 0.1); /* Verde */
}

.upload-section {
    background-color: rgba(255, 152, 0, 0.1); /* Naranja */
}

/* Cambiar tamaño de avatares */
.avatar {
    width: 150px;  /* Cambiar de 120px */
    height: 150px; /* Cambiar de 120px */
}
```

## 🐛 Solución de Problemas

### Avatar no se muestra
- Verificar que el archivo existe en `public/img/`
- Revisar consola del navegador para errores
- Confirmar que el nombre del archivo coincide con el array

### Error al subir imagen
- Verificar que el archivo es una imagen válida
- Confirmar que el tamaño no excede límites del navegador
- Revisar permisos de archivo

### Avatares no se guardan
- Verificar que localStorage está habilitado
- Revisar que el usuario está autenticado
- Confirmar que el token es válido

## 🚀 Próximas Mejoras

### Funcionalidades Sugeridas
1. **Recorte de imagen** para avatares personalizados
2. **Filtros y efectos** para fotos subidas
3. **Sincronización en tiempo real** entre dispositivos
4. **Historial de avatares** utilizados
5. **Categorías de avatares** (animales, personajes, etc.)

### Optimizaciones Técnicas
1. **Compresión automática** de imágenes grandes
2. **Lazy loading** para avatares predefinidos
3. **Cache inteligente** para mejor rendimiento
4. **WebP support** para formatos modernos

## 📞 Soporte

Para dudas o problemas con el sistema de avatares:

1. Revisar este README
2. Verificar archivos de ejemplo
3. Consultar consola del navegador
4. Revisar logs del servidor

---

**Desarrollado para LEGUMBRERIA** 🥬🥕🍎
**Sistema de Avatares v1.0** ✨
