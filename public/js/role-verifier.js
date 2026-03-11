/**
 * Verificador de Roles - BluePrint
 * Utilidad para verificar permisos de acceso basados en roles de usuario
 */

class RoleVerifier {
    constructor() {
        this.requiredRoles = {
            'cambiar-rol.html': ['gerente'],
            'gestionproop.html': ['gerente'],
            'pedidos.html': ['gerente', 'empleado'],
            'formulario-productos.html': ['gerente', 'empleado'],
            'empleados.html': ['gerente', 'empleado']
        };
    }

    /**
     * Verifica si el usuario actual tiene permisos para acceder a la página
     * @param {string} pageName - Nombre del archivo HTML
     * @returns {boolean} - true si tiene acceso, false si no
     */
    hasAccess(pageName = null) {
        // Si no se especifica página, usar la página actual
        if (!pageName) {
            pageName = window.location.pathname.split('/').pop();
        }

        // Obtener token del localStorage
        const token = localStorage.getItem('token');
        if (!token) {
            this.redirectToLogin();
            return false;
        }

        try {
            // Decodificar el token
            const payload = this.decodeToken(token);
            const userRole = payload.rol;

            // Verificar si la página requiere roles específicos
            const requiredRoles = this.requiredRoles[pageName];
            if (!requiredRoles) {
                // Si no hay restricciones específicas, permitir acceso
                return true;
            }

            // Verificar si el rol del usuario está en los roles requeridos
            if (requiredRoles.includes(userRole)) {
                return true;
            }

            // Si no tiene acceso, redirigir a pantalla de acceso denegado
            this.redirectToAccessDenied(pageName, userRole, requiredRoles);
            return false;

        } catch (error) {
            console.error('Error al verificar token:', error);
            this.redirectToLogin();
            return false;
        }
    }

    /**
     * Decodifica un token JWT
     * @param {string} token - Token JWT
     * @returns {object} - Payload decodificado
     */
    decodeToken(token) {
        try {
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(
                atob(base64)
                    .split('')
                    .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
                    .join('')
            );
            return JSON.parse(jsonPayload);
        } catch (error) {
            throw new Error('Token inválido');
        }
    }

    /**
     * Obtiene la información del usuario actual
     * @returns {object|null} - Información del usuario o null si no está autenticado
     */
    getCurrentUser() {
        const token = localStorage.getItem('token');
        if (!token) {
            return null;
        }

        try {
            return this.decodeToken(token);
        } catch (error) {
            console.error('Error al obtener usuario actual:', error);
            return null;
        }
    }

    /**
     * Verifica si el usuario tiene un rol específico
     * @param {string} role - Rol a verificar
     * @returns {boolean} - true si tiene el rol, false si no
     */
    hasRole(role) {
        const user = this.getCurrentUser();
        return user && user.rol === role;
    }

    /**
     * Verifica si el usuario es gerente
     * @returns {boolean} - true si es gerente
     */
    isManager() {
        return this.hasRole('gerente');
    }

    /**
     * Verifica si el usuario es empleado o gerente
     * @returns {boolean} - true si es empleado o gerente
     */
    isEmployeeOrManager() {
        return this.hasRole('empleado') || this.hasRole('gerente');
    }

    /**
     * Redirige a la página de acceso denegado
     * @param {string} pageName - Nombre de la página a la que intentaba acceder
     * @param {string} userRole - Rol actual del usuario
     * @param {Array} requiredRoles - Roles requeridos
     */
    redirectToAccessDenied(pageName, userRole, requiredRoles) {
        // Guardar información para mostrar en la pantalla de acceso denegado
        localStorage.setItem('lastRequiredRole', requiredRoles[0]); // Usar el rol principal requerido
        localStorage.setItem('lastAttemptedPage', pageName);

        // Redirigir a la pantalla de acceso denegado
        window.location.href = 'access-denied.html';
    }

    /**
     * Redirige al login
     */
    redirectToLogin() {
        // Guardar la página actual para redirigir después del login
        localStorage.setItem('redirectAfterLogin', window.location.pathname);
        window.location.href = 'login.html';
    }

    /**
     * Inicializa la verificación de roles para la página actual
     * @param {string} customPageName - Nombre personalizado de la página (opcional)
     */
    init(customPageName = null) {
        // Verificar acceso cuando se carga la página
        if (!this.hasAccess(customPageName)) {
            return false;
        }

        // Si tiene acceso, configurar elementos específicos del rol
        this.setupRoleSpecificElements();
        return true;
    }

    /**
     * Configura elementos específicos según el rol del usuario
     */
    setupRoleSpecificElements() {
        const user = this.getCurrentUser();
        if (!user) return;

        // Mostrar/ocultar elementos según el rol
        const roleElements = document.querySelectorAll('[data-role]');
        roleElements.forEach(element => {
            const requiredRoles = element.getAttribute('data-role').split(',');
            if (!requiredRoles.includes(user.rol)) {
                element.style.display = 'none';
            }
        });

        // Configurar elementos específicos para gerentes
        if (user.rol === 'gerente') {
            this.setupManagerElements();
        }

        // Configurar elementos específicos para empleados
        if (user.rol === 'empleado' || user.rol === 'gerente') {
            this.setupEmployeeElements();
        }
    }

    /**
     * Configura elementos específicos para gerentes
     */
    setupManagerElements() {
        // Agregar indicador visual de que es gerente
        const managerIndicator = document.querySelector('.manager-indicator');
        if (managerIndicator) {
            managerIndicator.style.display = 'block';
        }

        // Configurar botones de gestión
        const managementButtons = document.querySelectorAll('.management-button');
        managementButtons.forEach(button => {
            button.disabled = false;
            button.style.opacity = '1';
        });
    }

    /**
     * Configura elementos específicos para empleados
     */
    setupEmployeeElements() {
        // Configurar elementos de empleado
        const employeeElements = document.querySelectorAll('.employee-element');
        employeeElements.forEach(element => {
            element.style.display = 'block';
        });
    }

    /**
     * Verifica y muestra mensaje de bienvenida según el rol
     */
    showRoleWelcomeMessage() {
        const user = this.getCurrentUser();
        if (!user) return;

        const welcomeMessages = {
            'gerente': '¡Bienvenido, Gerente! Tienes acceso completo al sistema.',
            'empleado': '¡Bienvenido! Tienes acceso a funciones de empleado.',
            'usuario': '¡Bienvenido! Explora nuestros productos y servicios.'
        };

        const message = welcomeMessages[user.rol];
        if (message) {
            this.showNotification(message, 'success');
        }
    }

    /**
     * Muestra una notificación
     * @param {string} message - Mensaje a mostrar
     * @param {string} type - Tipo de notificación (success, error, info)
     */
    showNotification(message, type = 'info') {
        // Crear elemento de notificación
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
                <span>${message}</span>
            </div>
        `;

        // Agregar estilos si no existen
        if (!document.querySelector('#notification-styles')) {
            const styles = document.createElement('style');
            styles.id = 'notification-styles';
            styles.textContent = `
                .notification {
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    padding: 15px 20px;
                    border-radius: 8px;
                    color: white;
                    font-weight: 600;
                    z-index: 10000;
                    animation: slideIn 0.3s ease;
                    max-width: 400px;
                }
                .notification-success { background: linear-gradient(45deg, #27ae60, #229954); }
                .notification-error { background: linear-gradient(45deg, #e74c3c, #c0392b); }
                .notification-info { background: linear-gradient(45deg, #3498db, #2980b9); }
                .notification-content {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }
                @keyframes slideIn {
                    from { transform: translateX(100%); opacity: 0; }
                    to { transform: translateX(0); opacity: 1; }
                }
            `;
            document.head.appendChild(styles);
        }

        // Agregar al DOM
        document.body.appendChild(notification);

        // Remover después de 5 segundos
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 5000);
    }
}

// Crear instancia global
const roleVerifier = new RoleVerifier();

// Auto-inicializar si se está en una página que requiere verificación
document.addEventListener('DOMContentLoaded', () => {
    const currentPage = window.location.pathname.split('/').pop();
    const pagesRequiringVerification = Object.keys(roleVerifier.requiredRoles);

    if (pagesRequiringVerification.includes(currentPage)) {
        roleVerifier.init();
    }
});

// Exportar para uso en otros scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = RoleVerifier;
}
