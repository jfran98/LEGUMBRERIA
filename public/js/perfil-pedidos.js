document.addEventListener('DOMContentLoaded', () => {

  const token = localStorage.getItem('token');
  console.log('📦 Perfil-Pedidos: Iniciando. Token presente:', !!token);

  if (!token) {
    showErrorInSections('No hay token de sesión. Por favor, inicia sesión de nuevo.');
    return;
  }

  function showErrorInSections(msg) {
    console.error('❌ Error en Perfil-Pedidos:', msg);
    const containers = ['listaDirecciones', 'listaPedidos', 'listaFacturas'];
    containers.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.innerHTML = `<p style="color:red; font-size:12px;">❌ Error: ${msg}</p>`;
    });
  }

  /* =====================================================
     🔹 DIRECCIONES
  ====================================================== */
  const formDireccion = document.getElementById('formDireccion');
  const listaDirecciones = document.getElementById('listaDirecciones');

  if (formDireccion) {
    cargarDirecciones();

    const btnToggle = document.getElementById('btnToggleFormDir');
    const btnCancelar = document.getElementById('btnCancelarDir');
    if (btnToggle) btnToggle.addEventListener('click', () => { formDireccion.style.display = 'block'; btnToggle.style.display = 'none'; });
    if (btnCancelar) btnCancelar.addEventListener('click', () => { formDireccion.style.display = 'none'; btnToggle.style.display = 'block'; formDireccion.reset(); });

    formDireccion.addEventListener('submit', async (e) => {
      e.preventDefault();
      const datos = {
        titulo: document.getElementById('titulo').value,
        direccion: document.getElementById('direccion').value,
        ciudad: document.getElementById('ciudad').value,
        referencia: document.getElementById('referencia').value
      };

      try {
        const res = await fetch('/perfil/direcciones', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
          body: JSON.stringify(datos)
        });
        if (!res.ok) throw new Error('Error al guardar: ' + res.status);
        formDireccion.reset();
        formDireccion.style.display = 'none';
        if (btnToggle) btnToggle.style.display = 'block';
        cargarDirecciones();
      } catch (err) {
        alert('Error: ' + err.message);
      }
    });
  }

  async function cargarDirecciones() {
    console.log('🏠 Cargando direcciones...');
    try {
      if (!listaDirecciones) {
        console.warn('⚠️ No se encontró el contenedor listaDirecciones');
        return;
      }
      listaDirecciones.innerHTML = '<p>Cargando direcciones...</p>';
      const res = await fetch('/perfil/direcciones', { headers: { 'Authorization': 'Bearer ' + token } });
      if (!res.ok) throw new Error('Status: ' + res.status);
      const data = await res.json();
      console.log('🏠 Direcciones recibidas:', data.length);
      listaDirecciones.innerHTML = '';
      if (!data.length) {
        listaDirecciones.innerHTML = '<p class="msg-vacio">No hay direcciones guardadas.</p>';
        return;
      }
      data.forEach(dir => {
        const div = document.createElement('div');
        div.className = 'card-direccion';
        div.innerHTML = `
          <h4>${dir.titulo || 'Dirección'}</h4>
          <p>${dir.direccion || dir.calle}</p>
          <p>${dir.ciudad}</p>
          <button data-id="${dir.iddireccion}" class="btnEliminarDir">Eliminar</button>
        `;
        listaDirecciones.appendChild(div);
      });
    } catch (err) {
      listaDirecciones.innerHTML = `<p style="color:red;">Error: ${err.message}</p>`;
    }
  }

  /* =====================================================
     🔹 PEDIDOS
  ====================================================== */
  const listaPedidos = document.getElementById('listaPedidos');

  async function cargarPedidos() {
    try {
      if (!listaPedidos) return;
      listaPedidos.innerHTML = '<p>Cargando pedidos...</p>';
      const res = await fetch('/venta/mis-pedidos', { headers: { 'Authorization': 'Bearer ' + token } });
      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.mensaje || 'Status: ' + res.status);
      }
      const data = await res.json();
      console.log('🛒 Pedidos recibidos:', Array.isArray(data) ? data.length : 'No es array');
      listaPedidos.innerHTML = '';

      if (!Array.isArray(data) || data.length === 0) {
        listaPedidos.innerHTML = '<p class="msg-vacio">No tienes pedidos registrados.</p>';
        return;
      }

      data.forEach(p => {
        const card = document.createElement('div');
        card.className = 'card-pedido';
        card.innerHTML = `
          <h4>Pedido #${p.idpedido}</h4>
          <p>Fecha: ${p.fecha ? new Date(p.fecha).toLocaleDateString() : 'Sin fecha'}</p>
          <p>Total: $${p.total}</p>
          <p>Estado: ${p.estado}</p>
        `;
        listaPedidos.appendChild(card);
      });
    } catch (err) {
      listaPedidos.innerHTML = `<p style="color:red;">Error: ${err.message}</p>`;
    }
  }

  /* =====================================================
     🔹 FACTURAS
  ====================================================== */
  const listaFacturas = document.getElementById('listaFacturas');

  async function cargarFacturas() {
    try {
      if (!listaFacturas) return;
      listaFacturas.innerHTML = '<p>Cargando facturas...</p>';
      const res = await fetch('/venta/mis-facturas', { headers: { 'Authorization': 'Bearer ' + token } });
      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.mensaje || 'Status: ' + res.status);
      }
      const data = await res.json();
      console.log('📄 Facturas recibidas:', Array.isArray(data) ? data.length : 'No es array');
      listaFacturas.innerHTML = '';

      if (!Array.isArray(data) || data.length === 0) {
        listaFacturas.innerHTML = '<p class="msg-vacio">No tienes facturas aún.</p>';
        return;
      }

      data.forEach(f => {
        const card = document.createElement('div');
        card.className = 'card-factura clickable';
        card.style.cursor = 'pointer';
        // Abrir modal en lugar de URL
        card.onclick = () => abrirModalFactura(f.idfactura);

        const estadoStr = (f.estado || 'pendiente').toLowerCase();

        card.innerHTML = `
          <h4>Factura #${f.idfactura}</h4>
          <p><strong>Total:</strong> $${Number(f.total).toLocaleString()}</p>
          <p><strong>Fecha:</strong> ${f.fecha ? new Date(f.fecha).toLocaleDateString() : 'Sin fecha'}</p>
          <p><strong>Estado:</strong> ${estadoStr.charAt(0).toUpperCase() + estadoStr.slice(1)}</p>
          <small style="color: blue; text-decoration: underline;">👁️ Ver detalle</small>
        `;
        listaFacturas.appendChild(card);
      });
    } catch (err) {
      listaFacturas.innerHTML = `<p style="color:red;">Error: ${err.message}</p>`;
    }
  }

  /* =====================================================
     🔹 LÓGICA MODAL FACTURA
  ====================================================== */
  const modal = document.getElementById('modalFactura');
  const detailsContainer = document.getElementById('detallesFacturaModal');

  window.abrirModalFactura = async function (id) {
    if (!modal || !detailsContainer) return;

    modal.style.display = 'flex';
    detailsContainer.innerHTML = '<div style="text-align:center; padding:20px;"><p>Cargando detalles de la factura...</p></div>';

    try {
      const res = await fetch(`/venta/factura/${id}`, {
        headers: { 'Authorization': 'Bearer ' + token }
      });
      if (!res.ok) throw new Error('No se pudo cargar la factura');

      const data = await res.json();
      const f = data.factura;
      const items = data.detalles || [];
      const user = data.usuario;

      let html = `
        <div class="invoice-info-grid">
          <div class="invoice-info-item">
            <p><strong>Factura #:</strong> ${f.idfactura}</p>
            <p><strong>Fecha:</strong> ${new Date(f.fecha).toLocaleDateString()}</p>
            <p><strong>Estado:</strong> ${f.estado}</p>
          </div>
          <div class="invoice-info-item">
            <p><strong>Cliente:</strong> ${user.nombres}</p>
            <p><strong>Correo:</strong> ${user.correo}</p>
            <p><strong>Pago:</strong> ${f.metodopago}</p>
          </div>
        </div>

        <table class="invoice-table">
          <thead>
            <tr>
              <th>Producto</th>
              <th>Cant.</th>
              <th>Precio</th>
              <th>Subtotal</th>
            </tr>
          </thead>
          <tbody>
            ${items.map(item => `
              <tr>
                <td>${item.nombre}</td>
                <td>${item.cantidad}</td>
                <td>$${Number(item.preciounitario).toLocaleString()}</td>
                <td>$${Number(item.subtotal).toLocaleString()}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>

        <div class="invoice-total-row">
          <h4>Total de la Factura</h4>
          <h4>$${Number(f.total).toLocaleString()}</h4>
        </div>

        <div class="modal-footer-actions">
          <button class="btn-modal btn-print" onclick="imprimirDesdeModal(${f.idfactura})">🖨️ Imprimir Factura</button>
          <button class="btn-modal btn-email" id="btnEnviarEmail" onclick="enviarFacturaEmail(${f.idfactura})">📧 Enviar al Correo</button>
        </div>
      `;

      detailsContainer.innerHTML = html;

    } catch (err) {
      detailsContainer.innerHTML = `<p style="color:red; text-align:center;">❌ Error: ${err.message}</p>`;
    }
  };

  window.imprimirDesdeModal = function (id) {
    // Abrir la factura premium en una pestaña nueva y llamar a imprimir
    const win = window.open(`factura.html?id=${id}`, '_blank');
  };

  window.enviarFacturaEmail = async function (id) {
    const btn = document.getElementById('btnEnviarEmail');
    if (btn) {
      btn.disabled = true;
      btn.textContent = '⏱️ Enviando...';
    }

    try {
      const res = await fetch(`/venta/factura/${id}/enviar-correo`, {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer ' + token
        }
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.mensaje || 'Error al enviar');

      alert('✅ Factura enviada exitosamente a tu correo.');
    } catch (err) {
      alert('❌ Error: ' + err.message);
    } finally {
      if (btn) {
        btn.disabled = false;
        btn.textContent = '📧 Enviar al Correo';
      }
    }
  };

  window.cerrarModalFactura = function () {
    if (modal) modal.style.display = 'none';
  };

  // Cerrar al hacer clic fuera
  window.onclick = function (event) {
    if (event.target == modal) {
      cerrarModalFactura();
    }
  };

  // Ejecutar cargas
  if (listaDirecciones) cargarDirecciones();
  if (listaPedidos) cargarPedidos();
  if (listaFacturas) cargarFacturas();

  // Delegación para eliminar
  document.addEventListener('click', async (e) => {
    if (e.target.classList.contains('btnEliminarDir')) {
      const id = e.target.dataset.id;
      if (confirm('¿Eliminar esta dirección?')) {
        try {
          const res = await fetch('/perfil/direcciones/' + id, {
            method: 'DELETE',
            headers: { 'Authorization': 'Bearer ' + token }
          });

          if (!res.ok) {
            const errData = await res.json().catch(() => ({}));
            throw new Error(errData.mensaje || errData.error || errData.detalle || 'Error al eliminar');
          }

          cargarDirecciones();
        } catch (err) {
          console.error(err);
          alert('No se pudo eliminar: ' + err.message);
        }
      }
    }
  });

});
