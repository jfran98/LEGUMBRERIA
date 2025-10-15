document.addEventListener("DOMContentLoaded", () => {
  const navbarHTML = `
    <style>
      .navbar {
        background: linear-gradient(to right, #4caf50, #ff9800);
        color: white;
        padding: 15px 30px;
        font-size: 18px;
        font-weight: bold;
        display: flex;
        justify-content: space-between;
        align-items: center;
        z-index: 1000;
        transition: all 0.3s ease;
      }
      .navbar.shrink {
        padding: 10px 20px;
        font-size: 16px;
      }
      .navbar .nav-left {
        display: flex;
        align-items: center;
      }
      .navbar .logo {
        font-size: 24px;
        margin-right: 20px;
        font-weight: bold;
        letter-spacing: 1px;
      }
      .navbar .search-bar {
        display: flex;
        align-items: center;
        margin-left: 20px;
      }
      .navbar .search-bar input {
        padding: 6px 12px;
        border-radius: 6px 0 0 6px;
        border: none;
        outline: none;
        font-size: 16px;
      }
      .navbar .search-bar button {
        padding: 6px 12px;
        border-radius: 0 6px 6px 0;
        border: none;
        background: #388e3c;
        color: white;
        cursor: pointer;
        font-size: 16px;
        transition: background 0.2s;
      }
      .navbar .search-bar button:hover {
        background: #2e7031;
      }
      .navbar .nav-right a {
        color: white;
        text-decoration: none;
        margin-left: 20px;
        transition: color 0.3s;
      }
      .navbar .nav-right a:hover {
        color: #ffe082;
      }
      
      /* Estilos para el menú de opciones adicionales */
      .options-menu {
        position: relative;
        display: inline-block;
        margin-left: 20px;
      }
      
      .options-toggle {
        background: rgba(255, 255, 255, 0.2);
        border: 2px solid rgba(255, 255, 255, 0.3);
        color: white;
        padding: 8px 15px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 16px;
        font-weight: bold;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 8px;
      }
      
      .options-toggle:hover {
        background: rgba(255, 255, 255, 0.3);
        border-color: rgba(255, 255, 255, 0.5);
        transform: translateY(-2px);
      }
      
      .options-dropdown {
        position: absolute;
        top: 100%;
        right: 0;
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        padding: 15px 0;
        min-width: 200px;
        z-index: 1000;
        opacity: 0;
        visibility: hidden;
        transform: translateY(-10px);
        transition: all 0.3s ease;
        border: 1px solid rgba(0, 0, 0, 0.1);
      }
      
      .options-dropdown.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
      }
      
      .options-dropdown::before {
        content: '';
        position: absolute;
        top: -8px;
        right: 20px;
        width: 0;
        height: 0;
        border-left: 8px solid transparent;
        border-right: 8px solid transparent;
        border-bottom: 8px solid white;
      }
      
      .options-dropdown a {
        display: block;
        padding: 12px 20px;
        color: #333;
        text-decoration: none;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
        border-left: 3px solid transparent;
      }
      
      .options-dropdown a:hover {
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        color: #4caf50;
        border-left-color: #4caf50;
        padding-left: 25px;
      }
      
      .options-dropdown .divider {
        height: 1px;
        background: #e9ecef;
        margin: 8px 0;
      }
      
      .options-dropdown .section-title {
        padding: 8px 20px 4px;
        font-size: 12px;
        font-weight: 600;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
    </style>
    <div class="navbar" id="navbar">
      <div class="nav-left">
        <div class="logo">🥦 Legumbrería JM</div>
        <form class="search-bar" id="searchForm">
          <input type="text" id="searchInput" placeholder="Buscar productos..." />
          <button type="submit">Buscar</button>
        </form>
        <div id="bienvenida" style="margin-left: 20px;">Bienvenido</div>
      </div>
      <div class="nav-right" id="menu">
        <!-- Menú dinámico -->
      </div>
      <div class="options-menu" id="optionsMenu">
        <div class="options-toggle" id="optionsToggle">
          <span>⚙️</span>
          <span>Más</span>
          <span>▼</span>
        </div>
        <div class="options-dropdown" id="optionsDropdown">
          <div class="section-title">Administración</div>
          <!-- Los enlaces administrativos se insertarán aquí dinámicamente -->
          
          <div class="divider"></div>
          
          <div class="section-title">Accesos Rápidos</div>
          <a href="funcionalidadesDeLaAplicacion.html">📋 Funcionalidades</a>
          <a href="productos.html?categoria=promociones">🔥 Promociones</a>
          <a href="productos.html?categoria=frutas">🍎 Frutas</a>
          <a href="productos.html?categoria=verduras">🥬 Verduras</a>
          
          <div class="divider"></div>
          
          <div class="section-title">Herramientas</div>
          <a href="#" onclick="toggleDarkMode()">🌙 Modo Oscuro</a>
          <a href="#" onclick="showNotifications()">🔔 Notificaciones</a>
          <a href="#" onclick="showHelp()">❓ Ayuda</a>
          
          <div class="divider"></div>
          
          <div class="section-title">Información</div>
          <a href="#" onclick="showAbout()">ℹ️ Acerca de</a>
          <a href="#" onclick="showContact()">📞 Contacto</a>
          <a href="#" onclick="showTerms()">📄 Términos</a>
        </div>
      </div>
    </div>
  `;
  document.body.insertAdjacentHTML("afterbegin", navbarHTML);

  setTimeout(() => {
    const token = localStorage.getItem('token');
    const bienvenida = document.getElementById('bienvenida');
    const menu = document.getElementById('menu');

    if (token) {
      fetch('/usuario/perfil', {
        headers: {
          Authorization: 'Bearer ' + token
        }
      })
      .then(res => {
        if (!res.ok) throw new Error('Token inválido');
        return res.json();
      })
      .then(data => {
        bienvenida.textContent = `Hola, ${data.nombres}`;
        const role = getUserRoleFromToken();
        // Solo 4 enlaces principales en el navbar
        let menuHtml = `
          <a href="index.html">Inicio</a>
          <a href="productos.html">Productos</a>
          <a href="carrito.html">Carrito</a>
          <a href="perfil.html">Perfil</a>
        `;
        
        // Los demás enlaces van al menú de opciones
        let additionalMenuHtml = '';
        
        // Enlaces comunes para todos los usuarios autenticados
        additionalMenuHtml += `
          <a href="editar-perfil.html">✏️ Editar Perfil</a>
          <a href="factura.html">🧾 Mis Facturas</a>
        `;
        
        if (role === 'gerente') {
          additionalMenuHtml += `
            <a href="formulario-productos.html">📦 Agregar Producto</a>
            <a href="pedidos.html">📋 Gestión de Pedidos</a>
            <a href="cambiar-rol.html">👥 Gestión de Roles</a>
            <a href="controlfinanciero.html">💰 Control Financiero</a>
            <a href="gestionproop.html">⚙️ Gestión de Procesos</a>
            <a href="gestionprodser.html">🏪 Gestión de Productos</a>
          `;
        }
        if (role === 'empleado') {
          additionalMenuHtml += `
            <a href="formulario-productos.html">📦 Agregar Producto</a>
            <a href="pedidos.html">📋 Gestión de Pedidos</a>
          `;
        }
        
        // Agregar los enlaces adicionales al menú de opciones
        if (additionalMenuHtml) {
          const optionsDropdown = document.getElementById('optionsDropdown');
          if (optionsDropdown) {
            const adminSection = optionsDropdown.querySelector('.section-title');
            if (adminSection) {
              adminSection.insertAdjacentHTML('afterend', additionalMenuHtml + '<div class="divider"></div>');
            }
          }
        }

        // Agregar verificación de acceso a los enlaces protegidos
        addAccessControlToLinks();
        
        menuHtml += `<a href="#" id="logoutBtn">Salir</a>`;
        menu.innerHTML = menuHtml;
        document.getElementById('logoutBtn').addEventListener('click', cerrarSesion);
      })
      .catch(() => {
        localStorage.removeItem('token');
        location.reload();
      });
    } else {
      // Menú para no autenticados
      menu.innerHTML = `
        <a href="index.html">Inicio</a>
        <a href="productos.html">Productos</a>
        <a href="registro.html">Registrarse</a>
        <a href="login.html">Iniciar sesión</a>
      `;
    }

    // Evento de búsqueda
    const searchForm = document.getElementById('searchForm');
    if (searchForm) {
      searchForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const query = document.getElementById('searchInput').value.trim();
        if (query) {
          // Redirige a la página de productos con el término de búsqueda como query param
          window.location.href = `productos.html?buscar=${encodeURIComponent(query)}`;
        }
      });
    }

    window.addEventListener('scroll', () => {
      const nav = document.getElementById('navbar');
      if (window.scrollY > 50) {
        nav.classList.add('shrink');
      } else {
        nav.classList.remove('shrink');
      }
    });

    // Funcionalidad del menú de opciones adicionales
    const optionsToggle = document.getElementById('optionsToggle');
    const optionsDropdown = document.getElementById('optionsDropdown');
    
    if (optionsToggle && optionsDropdown) {
      optionsToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        optionsDropdown.classList.toggle('show');
      });
      
      // Cerrar el menú al hacer clic fuera
      document.addEventListener('click', (e) => {
        if (!optionsToggle.contains(e.target) && !optionsDropdown.contains(e.target)) {
          optionsDropdown.classList.remove('show');
        }
      });
      
      // Cerrar el menú al presionar Escape
      document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
          optionsDropdown.classList.remove('show');
        }
      });
    }
  }, 100);
});

function cerrarSesion(e) {
  e.preventDefault();
  localStorage.removeItem('token');
  window.location.href = 'index.html';
}

function getUserRoleFromToken() {
  const token = localStorage.getItem('token');
  if (!token) return null;
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    return payload.rol;
  } catch (e) {
    return null;
  }
}

// Funciones para las opciones del menú adicional
function toggleDarkMode() {
  document.body.classList.toggle('dark-mode');
  const isDark = document.body.classList.contains('dark-mode');
  localStorage.setItem('darkMode', isDark);
  
  // Aplicar estilos de modo oscuro
  if (isDark) {
    document.body.style.backgroundColor = '#1a1a1a';
    document.body.style.color = '#ffffff';
  } else {
    document.body.style.backgroundColor = '';
    document.body.style.color = '';
  }
  
  showNotification(isDark ? 'Modo oscuro activado' : 'Modo claro activado');
}

function showNotifications() {
  showNotification('🔔 No tienes notificaciones nuevas');
}

function showHelp() {
  showNotification('❓ Ayuda: Contacta soporte en legumbreriajmla84@gmail.com');
}

function showAbout() {
  showNotification('ℹ️ Legumbrería JM v1.0 - Sistema de comercio electrónico');
}

function showContact() {
  showNotification('📞 Contacto: WhatsApp +57 300 123 4567');
}

function showTerms() {
  showNotification('📄 Términos y condiciones disponibles en el sitio web');
}

function showNotification(message) {
  // Crear notificación temporal
  const notification = document.createElement('div');
  notification.style.cssText = `
    position: fixed;
    top: 80px;
    right: 20px;
    background: linear-gradient(135deg, #4caf50, #45a049);
    color: white;
    padding: 15px 20px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    z-index: 10000;
    font-weight: 500;
    max-width: 300px;
    animation: slideIn 0.3s ease;
  `;
  
  notification.textContent = message;
  document.body.appendChild(notification);
  
  // Remover después de 3 segundos
  setTimeout(() => {
    notification.style.animation = 'slideOut 0.3s ease';
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 300);
  }, 3000);
}

// Agregar estilos CSS para las animaciones
const style = document.createElement('style');
style.textContent = `
  @keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
  }
  @keyframes slideOut {
    from { transform: translateX(0); opacity: 1; }
    to { transform: translateX(100%); opacity: 0; }
  }
`;
document.head.appendChild(style);

// Función para agregar verificación de acceso a los enlaces protegidos
function addAccessControlToLinks() {
  // Definir páginas que requieren verificación de roles
  const protectedPages = {
    'cambiar-rol.html': ['gerente'],
    'controlfinanciero.html': ['gerente'],
    'gestionproop.html': ['gerente'],
    'gestionprodser.html': ['gerente'],
    'pedidos.html': ['gerente', 'empleado'],
    'formulario-productos.html': ['gerente', 'empleado']
  };

  // Obtener todos los enlaces del navbar
  const allLinks = document.querySelectorAll('a[href]');
  
  allLinks.forEach(link => {
    const href = link.getAttribute('href');
    const pageName = href.split('/').pop().split('?')[0]; // Obtener solo el nombre del archivo
    
    // Si es una página protegida, agregar verificación
    if (protectedPages[pageName]) {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        
        // Verificar si el usuario tiene acceso
        if (hasAccessToPage(pageName, protectedPages[pageName])) {
          // Si tiene acceso, navegar normalmente
          window.location.href = href;
        } else {
          // Si no tiene acceso, mostrar mensaje y redirigir
          showAccessDeniedMessage(protectedPages[pageName]);
        }
      });
    }
  });
}

// Función para verificar si el usuario tiene acceso a una página
function hasAccessToPage(pageName, requiredRoles) {
  const token = localStorage.getItem('token');
  if (!token) return false;
  
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    const userRole = payload.rol;
    return requiredRoles.includes(userRole);
  } catch (error) {
    console.error('Error al verificar acceso:', error);
    return false;
  }
}

// Función para mostrar mensaje de acceso denegado
function showAccessDeniedMessage(requiredRoles) {
  const roleNames = {
    'gerente': 'Gerente',
    'empleado': 'Empleado',
    'usuario': 'Usuario'
  };
  
  const requiredRoleNames = requiredRoles.map(role => roleNames[role] || role).join(' o ');
  
  // Crear notificación de acceso denegado
  const notification = document.createElement('div');
  notification.style.cssText = `
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: linear-gradient(45deg, #e74c3c, #c0392b);
    color: white;
    padding: 20px 30px;
    border-radius: 10px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    z-index: 10000;
    text-align: center;
    font-weight: 600;
    max-width: 400px;
  `;
  
  notification.innerHTML = `
    <div style="font-size: 24px; margin-bottom: 10px;">
      <i class="fas fa-lock"></i>
    </div>
    <div style="margin-bottom: 15px;">
      Acceso Denegado
    </div>
    <div style="font-size: 14px; margin-bottom: 15px; opacity: 0.9;">
      Esta sección requiere permisos de: <strong>${requiredRoleNames}</strong>
    </div>
    <button onclick="this.parentElement.remove()" style="
      background: rgba(255, 255, 255, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.3);
      color: white;
      padding: 8px 16px;
      border-radius: 5px;
      cursor: pointer;
      font-size: 14px;
    ">
      Entendido
    </button>
  `;
  
  document.body.appendChild(notification);
  
  // Remover automáticamente después de 5 segundos
  setTimeout(() => {
    if (notification.parentNode) {
      notification.style.opacity = '0';
      notification.style.transition = 'opacity 0.3s ease';
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }
  }, 5000);
}
