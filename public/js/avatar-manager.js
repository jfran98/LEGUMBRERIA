// Avatar Manager - Gestión de avatares para el perfil
class AvatarManager {
    constructor() {
        this.avatarSeleccionado = null;
        this.imagenPersonalizada = null;
        this.avataresPredefinidos = [
            'img/avatares/avatar-1.png',
            'img/avatares/avatar-2.png', 
            'img/avatares/avatar-3.png',
            'img/avatares/avatar-4.png',
            'img/avatares/avatar-5.png',
            'img/avatares/avatar-6.png',
            'img/avatares/avatar-7.png',
            'img/avatares/avatar-8.png',
            'img/avatares/avatar-9.png',
            'img/avatares/avatar-10.png',
            'img/avatares/avatar-11.png',
            'img/avatares/avatar-12.png',
            'img/avatares/avatar-13.png',
            'img/avatares/avatar-14.png',
            'img/avatares/avatar-15.png',
            'img/avatares/avatar-16.png',
            'img/avatares/avatar-17.png',
            'img/avatares/avatar-18.png',
            'img/avatares/avatar-19.png',
            'img/avatares/avatar-20.png',
            'img/avatares/avatar-21.png'
        ];
        
        this.init();
    }

    init() {
        // No generar avatares automáticamente, solo cuando se haga click en la foto
        this.cargarAvatarGuardado();
        this.setupEventListeners();
    }

    generarAvatares() {
        const grid = document.getElementById('avatarGrid');
        if (!grid) return;
        
        grid.innerHTML = '';
        
        this.avataresPredefinidos.forEach((avatarSrc, index) => {
            const avatarDiv = document.createElement('div');
            avatarDiv.innerHTML = `
                <img src="${avatarSrc}" 
                     alt="Avatar ${index + 1}" 
                     class="avatar-option" 
                     onclick="avatarManager.seleccionarAvatar('${avatarSrc}', this)"
                     onerror="this.style.display='none'">
            `;
            grid.appendChild(avatarDiv);
        });
        
        // Agregar indicadores de scroll si hay muchos avatares
        this.agregarIndicadoresScroll();
    }

    agregarIndicadoresScroll() {
        const grid = document.getElementById('avatarGrid');
        if (!grid) return;
        
        // Agregar botones de navegación si hay muchos avatares
        if (this.avataresPredefinidos.length > 8) {
            const navContainer = document.createElement('div');
            navContainer.className = 'avatar-navigation';
            navContainer.innerHTML = `
                <button class="nav-btn prev" onclick="avatarManager.scrollAvatares('left')">‹</button>
                <button class="nav-btn next" onclick="avatarManager.scrollAvatares('right')">›</button>
            `;
            
            // Insertar después de la cuadrícula
            grid.parentNode.insertBefore(navContainer, grid.nextSibling);
        }
    }

    scrollAvatares(direction) {
        const grid = document.getElementById('avatarGrid');
        if (!grid) return;
        
        const scrollAmount = 240; // 4 avatares a la vez
        
        if (direction === 'left') {
            grid.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
        } else {
            grid.scrollBy({ left: scrollAmount, behavior: 'smooth' });
        }
    }

    seleccionarAvatar(avatarSrc, elemento) {
        // Remover selección previa
        document.querySelectorAll('.avatar-option').forEach(opt => 
            opt.classList.remove('selected')
        );
        
        // Seleccionar nuevo avatar
        elemento.classList.add('selected');
        this.avatarSeleccionado = avatarSrc;
        
        // Actualizar avatar principal
        const avatarPrincipal = document.getElementById('avatar');
        if (avatarPrincipal) {
            avatarPrincipal.src = avatarSrc;
        }
        
        // Ocultar vista previa de imagen personalizada
        const preview = document.getElementById('avatarPreview');
        if (preview) {
            preview.style.display = 'none';
        }
        this.imagenPersonalizada = null;
        
        // Guardar en localStorage
        localStorage.setItem('avatarSeleccionado', avatarSrc);
        localStorage.removeItem('avatarPersonalizada');
        
        this.mostrarMensaje('✅ Avatar seleccionado', 'success');
    }

    setupEventListeners() {
        const fileInput = document.getElementById('fileInput');
        if (fileInput) {
            fileInput.addEventListener('change', (e) => this.manejarSubidaArchivo(e));
        }
        
        // Listener para scroll de avatares
        const grid = document.getElementById('avatarGrid');
        if (grid) {
            grid.addEventListener('scroll', () => this.actualizarIndicadoresScroll());
        }
        
        // Listener para mostrar/ocultar opciones de avatar al hacer click en la foto principal
        const avatarPrincipal = document.getElementById('avatar');
        if (avatarPrincipal) {
            avatarPrincipal.addEventListener('click', () => this.toggleAvatarOptions());
        }
    }

    manejarSubidaArchivo(e) {
        const file = e.target.files[0];
        if (file) {
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    this.imagenPersonalizada = e.target.result;
                    const previewImage = document.getElementById('previewImage');
                    const avatarPreview = document.getElementById('avatarPreview');
                    
                    if (previewImage && avatarPreview) {
                        previewImage.src = this.imagenPersonalizada;
                        avatarPreview.style.display = 'block';
                    }
                    
                    // Remover selección de avatares predefinidos
                    document.querySelectorAll('.avatar-option').forEach(opt => 
                        opt.classList.remove('selected')
                    );
                    this.avatarSeleccionado = null;
                };
                reader.readAsDataURL(file);
            } else {
                this.mostrarMensaje('❌ Por favor selecciona un archivo de imagen válido', 'error');
            }
        }
    }

    guardarAvatarPersonalizado() {
        if (this.imagenPersonalizada) {
            const avatarPrincipal = document.getElementById('avatar');
            if (avatarPrincipal) {
                avatarPrincipal.src = this.imagenPersonalizada;
            }
            
            localStorage.setItem('avatarPersonalizada', this.imagenPersonalizada);
            localStorage.removeItem('avatarSeleccionado');
            
            // Ocultar vista previa
            const preview = document.getElementById('avatarPreview');
            if (preview) {
                preview.style.display = 'none';
            }
            
            this.mostrarMensaje('✅ Avatar personalizado guardado', 'success');
            
            // Aquí podrías enviar la imagen al backend si es necesario
            this.enviarAvatarAlBackend(this.imagenPersonalizada);
        }
    }

    enviarAvatarAlBackend(imagenBase64) {
        const token = localStorage.getItem('token');
        if (!token) return;

        // Convertir base64 a blob
        const base64Data = imagenBase64.split(',')[1];
        const byteCharacters = atob(base64Data);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const blob = new Blob([byteArray], { type: 'image/png' });

        // Crear FormData
        const formData = new FormData();
        formData.append('avatar', blob, 'avatar.png');

        // Enviar al backend (ajusta la URL según tu API)
        fetch('http://localhost:4545/usuario/avatar', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + token
            },
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                console.log('Avatar guardado en el backend');
            }
        })
        .catch(error => {
            console.error('Error al guardar avatar en el backend:', error);
        });
    }

    cargarAvatarGuardado() {
        const avatarPersonalizado = localStorage.getItem('avatarPersonalizada');
        const avatarSeleccionado = localStorage.getItem('avatarSeleccionado');
        
        if (avatarPersonalizado) {
            const avatarPrincipal = document.getElementById('avatar');
            if (avatarPrincipal) {
                avatarPrincipal.src = avatarPersonalizado;
            }
            this.imagenPersonalizada = avatarPersonalizado;
        } else if (avatarSeleccionado) {
            const avatarPrincipal = document.getElementById('avatar');
            if (avatarPrincipal) {
                avatarPrincipal.src = avatarSeleccionado;
            }
            this.avatarSeleccionado = avatarSeleccionado;
            
            // Marcar como seleccionado en la cuadrícula
            setTimeout(() => {
                const avatarElement = document.querySelector(`[src="${avatarSeleccionado}"]`);
                if (avatarElement) {
                    avatarElement.classList.add('selected');
                }
            }, 100);
        }
    }

    mostrarMensaje(texto, tipo) {
        const mensaje = document.getElementById('mensaje');
        if (mensaje) {
            mensaje.textContent = texto;
            mensaje.style.color = tipo === 'success' ? 'green' : 'red';
            setTimeout(() => {
                mensaje.textContent = '';
            }, 3000);
        }
    }

    // Método para agregar nuevos avatares predefinidos
    agregarAvatarPredefinido(ruta) {
        this.avataresPredefinidos.push(ruta);
        this.generarAvatares();
    }

    // Método para obtener el avatar actual
    obtenerAvatarActual() {
        return this.imagenPersonalizada || this.avatarSeleccionado || 'img/avatar-default.png';
    }

    actualizarIndicadoresScroll() {
        const grid = document.getElementById('avatarGrid');
        if (!grid) return;
        
        const prevBtn = document.querySelector('.nav-btn.prev');
        const nextBtn = document.querySelector('.nav-btn.next');
        
        if (prevBtn && nextBtn) {
            // Habilitar/deshabilitar botón izquierdo
            prevBtn.disabled = grid.scrollLeft <= 0;
            
            // Habilitar/deshabilitar botón derecho
            const maxScroll = grid.scrollWidth - grid.clientWidth;
            nextBtn.disabled = grid.scrollLeft >= maxScroll;
        }
    }

    toggleAvatarOptions() {
        const avatarOptions = document.getElementById('avatarOptions');
        if (avatarOptions) {
            const isVisible = avatarOptions.style.display !== 'none';
            
            if (isVisible) {
                // Ocultar opciones
                avatarOptions.style.display = 'none';
                this.mostrarMensaje('', ''); // Limpiar mensajes
            } else {
                // Mostrar opciones
                avatarOptions.style.display = 'block';
                // Generar avatares si no se han generado aún
                if (document.getElementById('avatarGrid').children.length === 0) {
                    this.generarAvatares();
                }
            }
        }
    }
}

// Inicializar el manager cuando se cargue la página
let avatarManager;
document.addEventListener('DOMContentLoaded', () => {
    avatarManager = new AvatarManager();
});

// Función global para compatibilidad con onclick
function guardarAvatarPersonalizado() {
    if (avatarManager) {
        avatarManager.guardarAvatarPersonalizado();
    }
}
