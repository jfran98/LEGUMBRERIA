// Avatar Manager - Gestión de avatares para el perfil
class AvatarManager {
    constructor() {
        this.avatarSeleccionado = null;
        this.imagenPersonalizada = null;
        this.generoActual = 'hombre'; // Default

        // Listas de avatares (basado en los archivos existentes)
        this.avataresHombre = [
            'img/avatares/hombre/avatar-1.png', 'img/avatares/hombre/avatar-2.png', 'img/avatares/hombre/avatar-3.png',
            'img/avatares/hombre/avatar-4.png', 'img/avatares/hombre/avatar-5.png', 'img/avatares/hombre/avatar-6.png',
            'img/avatares/hombre/avatar-7.png', 'img/avatares/hombre/avatar-8.png', 'img/avatares/hombre/avatar-9.png',
            'img/avatares/hombre/avatar-10.png', 'img/avatares/hombre/avatar-11.png', 'img/avatares/hombre/avatar-12.png',
            'img/avatares/hombre/avatar-13.png', 'img/avatares/hombre/avatar-14.png', 'img/avatares/hombre/avatar-15.png',
            'img/avatares/hombre/avatar-16.png', 'img/avatares/hombre/avatar-17.png', 'img/avatares/hombre/avatar-18.png',
            'img/avatares/hombre/avatar-19.png', 'img/avatares/hombre/avatar-20.png', 'img/avatares/hombre/avatar-21.png'
        ];

        this.avataresMujer = [
            'img/avatares/mujer/avatar-1.png', 'img/avatares/mujer/avatar-2.png', 'img/avatares/mujer/avatar-3.png',
            'img/avatares/mujer/avatar-4.png', 'img/avatares/mujer/avatar-5.png', 'img/avatares/mujer/avatar-6.png',
            'img/avatares/mujer/avatar-7.png', 'img/avatares/mujer/avatar-8.png', 'img/avatares/mujer/avatar-9.png',
            'img/avatares/mujer/avatar-10.png', 'img/avatares/mujer/avatar-11.png', 'img/avatares/mujer/avatar-12.png',
            'img/avatares/mujer/avatar-13.png', 'img/avatares/mujer/avatar-14.png', 'img/avatares/mujer/avatar-15.png',
            'img/avatares/mujer/avatar-16.png', 'img/avatares/mujer/avatar-17.png', 'img/avatares/mujer/avatar-18.png',
            'img/avatares/mujer/avatar-19.png', 'img/avatares/mujer/avatar-20.png', 'img/avatares/mujer/avatar-21.png',
            'img/avatares/mujer/avatar-22.png', 'img/avatares/mujer/avatar-23.png', 'img/avatares/mujer/avatar-24.png'
        ];

        // Inicialmente mostramos los de hombre
        this.avataresPredefinidos = this.avataresHombre;

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

        this.avataresPredefinidos.forEach((avatarSrc) => {
            const avatarDiv = document.createElement('div');
            // Check if selected
            const isSelected = avatarSrc === this.avatarSeleccionado ? 'selected' : '';

            avatarDiv.innerHTML = `
                <img src="${avatarSrc}"
                     class="avatar-option ${isSelected}"
                     onclick="avatarManager.seleccionarAvatar('${avatarSrc}', this)"
                     onerror="this.style.display='none'">
            `;
            grid.appendChild(avatarDiv);
        });
    }

    filrarAvatares(genero, btn) {
        this.generoActual = genero;

        // Actualizar botones UI
        document.querySelectorAll('.btn-gender').forEach(b => b.classList.remove('active'));
        if (btn) btn.classList.add('active');

        // Cambiar lista
        if (genero === 'hombre') {
            this.avataresPredefinidos = this.avataresHombre;
        } else {
            this.avataresPredefinidos = this.avataresMujer;
        }

        this.generarAvatares();
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

        const grid = document.getElementById('avatarGrid');
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
        fetch('/usuario/avatar', {
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
