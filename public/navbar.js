const navbarHTML = `
    <style>
      .navbar {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        width: 100%;
        box-sizing: border-box;
       background: linear-gradient(to right, #27ae60, #d34b21);
        color: white;
        padding: 12px 30px;
        font-size: 18px;
        font-weight: bold;
        display: flex;
        justify-content: space-between;
        align-items: center;
        z-index: 1000;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.25);
        transition: all 0.3s ease;
      }
      .navbar.shrink {
        padding: 8px 24px;
        font-size: 16px;
        box-shadow: 0 3px 6px rgba(0, 0, 0, 0.2);
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
        display: flex;
        align-items: center;
        gap: 10px;
      }
      .navbar .logo img {
        height: 40px;
        width: auto;
        border-radius: 6px;
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
        background: var(--color-accent);
        color: white;
        cursor: pointer;
        font-size: 16px;
        transition: background 0.2s;
      }
      .navbar .search-bar button:hover {
        background: #E6B000;
      }
      .navbar .nav-right a {
        color: white;
        text-decoration: none;
        margin-left: 20px;
        transition: color 0.3s;
      }
      .navbar .nav-right a:hover {
        color: var(--color-accent);
      }
      
      /* Badge de notificaciones */
      .notif-badge {
        position: absolute;
        top: -8px;
        right: -10px;
        background: #e74c3c;
        color: white;
        font-size: 11px;
        padding: 2px 6px;
        border-radius: 50%;
        font-weight: bold;
        display: none;
      }
      #notif-link {
        position: relative;
      }

      /* Panel de notificaciones */
      .notif-panel {
        position: fixed;
        top: 80px;
        right: 20px;
        width: 350px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        z-index: 10001;
        overflow: hidden;
        display: none;
        flex-direction: column;
        animation: fadeInDown 0.3s ease;
      }
      .notif-header {
        padding: 15px;
        background: #f8faf9;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: #1a4d2e;
      }
      .notif-header h4 { margin: 0; }
      .notif-list {
        max-height: 400px;
        overflow-y: auto;
      }
      .notif-item {
        padding: 15px;
        border-bottom: 1px solid #f0f0f0;
        cursor: pointer;
        transition: background 0.2s;
        display: flex;
        flex-direction: column;
        gap: 5px;
      }
      .notif-item:hover { background: #f9f9f9; }
      .notif-item.unread { border-left: 4px solid #27ae60; background: #f0fdf4; }
      .notif-item .title { font-weight: bold; font-size: 14px; color: #333; }
      .notif-item .msg { font-size: 13px; color: #666; }
      .notif-item .time { font-size: 11px; color: #999; text-align: right; }
      .notif-empty { padding: 40px 20px; text-align: center; color: #999; }
      
      @keyframes fadeInDown {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
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
        min-width: 220px;
        max-height: 70vh;
        overflow-y: auto;
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
        color: var(--color-primary);
        border-left-color: var(--color-primary);
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
      
      /* Estilos para el avatar del navbar */
      .nav-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid rgba(255, 255, 255, 0.8);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        transition: all 0.3s ease;
        background-color: #fff;
      }
      
      .options-toggle:hover .nav-avatar {
        border-color: #fff;
        transform: scale(1.1);
      }
      
      /* Campana de Notificaciones en Navbar */
      .notif-bell-container {
        position: relative;
        cursor: pointer;
        padding: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-left: 10px;
        transition: transform 0.2s;
      }
      .notif-bell-container:hover {
        transform: scale(1.1);
      }
      .notif-bell-icon {
        font-size: 22px;
      }
      .notif-bell-badge {
        position: absolute;
        top: 2px;
        right: 2px;
        background: #e74c3c;
        color: white;
        font-size: 10px;
        font-weight: bold;
        padding: 2px 5px;
        border-radius: 50%;
        display: none;
        border: 2px solid #27ae60;
      }

      /* Mobile Responsive Styles */
      .hamburger {
        display: none;
        cursor: pointer;
        font-size: 24px;
        color: white;
        background: none;
        border: none;
        padding: 10px;
        z-index: 1001;
      }

      @media (max-width: 768px) {
        .navbar {
          padding: 8px 15px !important;
          height: auto !important;
        }
        .navbar .search-bar, 
        .navbar #bienvenida {
          display: none !important;
        }
        .hamburger {
          display: block !important;
        }
        .nav-right {
          position: fixed;
          top: 0;
          right: -100%;
          width: 75% !important;
          max-width: 300px;
          height: 100vh;
          background: #1a4d2e;
          flex-direction: column;
          padding: 80px 20px 20px;
          transition: 0.3s ease;
          display: flex !important;
          box-shadow: -5px 0 15px rgba(0,0,0,0.3);
        }
        .nav-right.active {
          right: 0 !important;
        }
        .nav-right a {
          margin: 12px 0 !important;
          font-size: 18px !important;
          border-bottom: 1px solid rgba(255,255,255,0.1);
          padding-bottom: 8px;
          display: block !important;
          width: 100%;
        }
        .navbar .logo {
          font-size: 16px !important;
          margin-right: 10px !important;
        }
        .navbar .logo img {
          height: 28px !important;
        }
        .notif-bell-container {
          margin-left: auto;
          margin-right: 15px;
        }
      }

      /* Extra small devices */
      @media (max-width: 360px) {
        .navbar .logo span {
          display: none; /* Solo logo en pantallas minúsculas */
        }
      }
    </style>
    <div class="navbar" id="navbar">
      <div class="nav-left">
        <div class="logo">
          <img src="img/logo.jpg" alt="Logo">
          legumbreria
        </div>
        <form class="search-bar" id="searchForm">
          <input type="text" id="searchInput" placeholder="Buscar productos..." />
          <button type="submit">Buscar</button>
        </form>
        <div id="bienvenida" style="margin-left: 20px;">Bienvenido</div>
      </div>
      <div class="nav-right" id="menu">
        <!-- Menú dinámico -->
      </div>
      
      <!-- Campana de Notificaciones -->
      <div class="notif-bell-container" id="navbarNotifBell" onclick="showNotifications(event)">
        <span class="notif-bell-icon">🔔</span>
        <span class="notif-bell-badge" id="navbarNotifBadge">0</span>
      </div>

      <!-- Hamburger Menu (Solo móvil) -->
      <button class="hamburger" id="hamburgerBtn">☰</button>
      <div class="options-menu" id="optionsMenu">
        <div class="options-toggle" id="optionsToggle">
          <div id="navIconContainer">
             <img src="img/avatares/avatar-default.png" alt="Perfil" class="nav-avatar" id="navAvatar" style="display: none;">
             <span id="navDefaultIcon">⚙️</span>
          </div>
          <span>Más</span>
          <span>▼</span>
        </div>
        <div class="options-dropdown" id="optionsDropdown">
          <div class="section-title">Administración</div>
          <!-- Los enlaces administrativos se insertarán aquí dinámicamente -->
          
          <div class="divider"></div>
          
          <div class="section-title">Información</div>
          <a href="preguntas-frecuentes.html">❓ Preguntas frecuentes</a>
          <a href="acercade.html">ℹ️ Acerca de</a>
          <a href="contacto.html">📞 Contacto</a>

        </div>
      </div>
    </div>
  `;
document.body.insertAdjacentHTML("afterbegin", navbarHTML);

// Función para actualizar el avatar del navbar desde localStorage
function updateNavAvatar() {
  const navAvatar = document.getElementById('navAvatar');
  const navDefaultIcon = document.getElementById('navDefaultIcon');
  const token = localStorage.getItem('token');

  if (!navAvatar || !navDefaultIcon) return;

  if (token) {
    const avatarPersonalizado = localStorage.getItem('avatarPersonalizada');
    const avatarSeleccionado = localStorage.getItem('avatarSeleccionado');

    if (avatarPersonalizado) {
      navAvatar.src = avatarPersonalizado;
    } else if (avatarSeleccionado) {
      navAvatar.src = avatarSeleccionado;
    } else {
      navAvatar.src = 'img/avatares/avatar-default.png';
    }

    navAvatar.style.display = 'block';
    navDefaultIcon.style.display = 'none';
  } else {
    navAvatar.style.display = 'none';
    navDefaultIcon.style.display = 'inline';
  }
}

// Inicializar avatar
setTimeout(updateNavAvatar, 50);

// Lógica del menú hamburguesa
setTimeout(() => {
  const hamburgerBtn = document.getElementById('hamburgerBtn');
  const menu = document.getElementById('menu');
  
  if (hamburgerBtn && menu) {
    hamburgerBtn.addEventListener('click', () => {
      menu.classList.toggle('active');
      hamburgerBtn.textContent = menu.classList.contains('active') ? '✕' : '☰';
    });

    // Cerrar menú al hacer clic en un enlace (móvil)
    menu.addEventListener('click', (e) => {
      if (e.target.tagName === 'A') {
        menu.classList.remove('active');
        hamburgerBtn.textContent = '☰';
      }
    });
  }
}, 100);

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



        if (role === 'gerente') {
          additionalMenuHtml += `
            <a href="formulario-productos.html">📦 Agregar Producto</a>
            <a href="editar-producto.html">✏️🥑 Editar Producto</a>
            <a href="pedidos.html">📋 Gestión de Pedidos</a>
            <a href="cambiar-rol.html">👥 Gestión de Roles</a>
            <a href="gestionproop.html">📈 Panel de Control Gerencial</a>
            <a href="empleados.html">💰 Gestión de Nómina</a>
          `;
        }
        if (role === 'empleado') {
          additionalMenuHtml += `
            <a href="formulario-productos.html">📦 Agregar Producto</a>
            <a href="editar-producto.html">✏️🥑 Editar Producto</a>
            <a href="pedidos.html">📋 Gestión de Pedidos</a>
            <a href="empleados.html">💰 Mi Nómina</a>
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

        // Actualizar avatar al cargar perfil
        updateNavAvatar();
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
        <a href="login.html">Iniciar sesión</a>
      `;
  }

  // Evento de búsqueda
  const searchForm = document.getElementById('searchForm');
  if (searchForm) {
    searchForm.addEventListener('submit', function (e) {
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

function showNotifications(e) {
  if (e) {
    e.preventDefault();
    e.stopPropagation();
  }

  const panel = document.getElementById('notificationPanel');
  if (!panel) {
    createNotificationPanel();
    loadNotifications();
  } else {
    panel.style.display = panel.style.display === 'flex' ? 'none' : 'flex';
    if (panel.style.display === 'flex') loadNotifications();
  }
}

function createNotificationPanel() {
  const panel = document.createElement('div');
  panel.id = 'notificationPanel';
  panel.className = 'notif-panel';
  panel.innerHTML = `
    <div class="notif-header">
      <h4>🔔 Notificaciones</h4>
      <div style="display: flex; gap: 15px; align-items: center;">
        <span style="font-size: 13px; font-weight: bold; cursor: pointer; color: #e74c3c; transition: opacity 0.2s;" onmouseover="this.style.opacity='0.7'" onmouseout="this.style.opacity='1'" onclick="limpiarNotificaciones()">Limpiar</span>
        <span style="font-size: 13px; cursor: pointer; color: #666;" onclick="document.getElementById('notificationPanel').style.display='none'">Cerrar</span>
      </div>
    </div>
    <div class="notif-list" id="notif-list">
      <div class="notif-empty">Cargando...</div>
    </div>
  `;
  document.body.appendChild(panel);

  // Cerrar al hacer clic fuera
  document.addEventListener('click', (e) => {
    if (panel.style.display === 'flex' && !panel.contains(e.target) && e.target.id !== 'notif-link') {
      panel.style.display = 'none';
    }
  });
}

async function loadNotifications() {
  const token = localStorage.getItem('token');
  if (!token) return;

  try {
    const res = await fetch('/notificaciones', {
      headers: { 'Authorization': 'Bearer ' + token }
    });
    const notifs = await res.json();

    const list = document.getElementById('notif-list');
    const badgeDropdown = document.getElementById('notif-count');
    const badgeNavbar = document.getElementById('navbarNotifBadge');

    if (!notifs || notifs.length === 0) {
      list.innerHTML = '<div class="notif-empty">No hay notificaciones</div>';
      if (badgeDropdown) badgeDropdown.style.display = 'none';
      if (badgeNavbar) badgeNavbar.style.display = 'none';
      return;
    }

    const unreadCount = notifs.filter(n => !n.leido).length;

    // Función auxiliar para actualizar badges
    const updateBadge = (el) => {
      if (el) {
        if (unreadCount > 0) {
          el.textContent = unreadCount;
          el.style.display = 'block';
        } else {
          el.style.display = 'none';
        }
      }
    };

    updateBadge(badgeDropdown);
    updateBadge(badgeNavbar);

    list.innerHTML = notifs.map(n => `
      <div class="notif-item ${n.leido ? '' : 'unread'}" onclick="marcarNotificacionLeida(${n.idnotificacion})">
        <span class="title">${n.titulo}</span>
        <span class="msg">${n.mensaje}</span>
        <span class="time">${new Date(n.fecha).toLocaleString()}</span>
      </div>
    `).join('');

  } catch (err) {
    console.error('Error al cargar notificaciones:', err);
  }
}

async function marcarNotificacionLeida(id) {
  const token = localStorage.getItem('token');
  try {
    await fetch(`/notificaciones/leer/${id}`, {
      method: 'PUT',
      headers: { 'Authorization': 'Bearer ' + token }
    });
    loadNotifications(); // Recargar
  } catch (err) {
    console.error('Error al marcar como leída:', err);
  }
}

async function limpiarNotificaciones() {
  const token = localStorage.getItem('token');
  if (!token) return;

  if (!confirm('¿Estás seguro de que quieres eliminar todas las notificaciones?')) return;

  try {
    await fetch('/notificaciones/limpiar', {
      method: 'DELETE',
      headers: { 'Authorization': 'Bearer ' + token }
    });
    loadNotifications(); // Recargar lista
  } catch (err) {
    console.error('Error al limpiar notificaciones:', err);
  }
}

// Cargar conteo inicial
setTimeout(loadNotifications, 500);

function showAbout() {
  window.location.href = 'acercade.html';
}

function showContact() {
  const whatsappUrl = "https://wa.me/573243538359?text=Hola%20Legumbrería%20JM,%20me%20gustaría%20más%20información.";
  showNotification(`📞 <a href="${whatsappUrl}" target="_blank" style="color:white; text-decoration:underline;">Chat WhatsApp: 324 353 8359</a> <br> ✉️ legumbreriajmla84@gmail.com`);
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
    background: var(--color-primary);
    color: white;
    padding: 15px 20px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    z-index: 10000;
    font-weight: 500;
    max-width: 300px;
    animation: slideIn 0.3s ease;
  `;

  notification.innerHTML = message;
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
    'gestionproop.html': ['gerente'],
    'pedidos.html': ['gerente', 'empleado'],
    'formulario-productos.html': ['gerente', 'empleado'],
    'editar-producto.html': ['gerente', 'empleado'],
    'empleados.html': ['gerente', 'empleado']
  };

  // Obtener todos los enlaces del navbar
  const allLinks = document.querySelectorAll('a[href]');

  allLinks.forEach(link => {
    const href = link.getAttribute('href');
    const pageName = href.split('/').pop().split('?')[0]; // Obtener solo el nombre del archivo

    // Si es una página protegida, agregar verificación
    if (protectedPages[pageName]) {
      link.addEventListener('click', function (e) {
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

// Helper global para formatear moneda (Pesos Colombianos)
window.formatCurrency = (num) => {
  if (num === undefined || num === null) return '$ 0';
  return new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0
  }).format(num);
};
