function plantillaRegistro(nombre) {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
      <h2 style="color: #4CAF50;">¡Bienvenido a Legumbrería JM, ${nombre}!</h2>
      <p>Gracias por registrarte. Esperamos que disfrutes explorando nuestros productos frescos.</p>
      <p style="margin-top:20px;">🍎🥬🥕</p>
      <p style="font-size: 14px; color: #777;">Este mensaje es automático, no respondas a este correo.</p>
    </div>
  `;
}

function plantillaEdicion(nombre) {
  return `
    <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
      <h2 style="color: #FF9800;">Hola ${nombre},</h2>
      <p>Tu perfil ha sido actualizado correctamente. Si no fuiste tú, contáctanos inmediatamente.</p>
      <p style="margin-top:20px;">Gracias por confiar en Legumbrería JM 🥦</p>
      <p style="font-size: 14px; color: #777;">Este mensaje es automático, no respondas a este correo.</p>
    </div>
  `;
}

function plantillaFactura(factura, usuario, detalles) {
  const itemsHTML = detalles.map(d => `
    <tr>
      <td style="padding: 10px; border-bottom: 1px solid #eee;">${d.nombre}</td>
      <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: center;">${d.cantidad}</td>
      <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: right;">$${Number(d.preciounitario).toLocaleString()}</td>
      <td style="padding: 10px; border-bottom: 11px solid #eee; text-align: right;">$${Number(d.subtotal).toLocaleString()}</td>
    </tr>
  `).join('');

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; border: 1px solid #eee; padding: 20px; color: #333;">
      <div style="text-align: center; margin-bottom: 20px;">
        <h1 style="color: #4CAF50; margin: 0;">Legumbrería JM</h1>
        <p style="color: #777; margin: 5px 0;">Tu pedido ha sido procesado</p>
      </div>

      <div style="margin-bottom: 20px; padding: 15px; background: #f9f9f9; border-radius: 8px;">
        <h3 style="margin-top: 0; color: #4CAF50;">Resumen del Pedido #${factura.idfactura}</h3>
        <p><strong>Cliente:</strong> ${usuario.nombres}</p>
        <p><strong>Fecha:</strong> ${new Date(factura.fecha).toLocaleDateString()}</p>
        <p><strong>Método de Pago:</strong> ${factura.metodopago}</p>
      </div>

      <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
        <thead>
          <tr style="background: #4CAF50; color: white;">
            <th style="padding: 10px; text-align: left;">Producto</th>
            <th style="padding: 10px; text-align: center;">Cant.</th>
            <th style="padding: 10px; text-align: right;">Precio</th>
            <th style="padding: 10px; text-align: right;">Subtotal</th>
          </tr>
        </thead>
        <tbody>
          ${itemsHTML}
        </tbody>
      </table>

      <div style="text-align: right; font-size: 18px; font-weight: bold; padding: 10px; border-top: 2px solid #4CAF50;">
        Total: $${Number(factura.total).toLocaleString()}
      </div>

      <div style="margin-top: 30px; text-align: center; font-size: 12px; color: #777;">
        <p>Gracias por tu compra en Legumbrería JM.</p>
        <p>Este es un recibo automático, no es necesario responder.</p>
      </div>
    </div>
  `;
}

module.exports = {
  plantillaRegistro,
  plantillaEdicion,
  plantillaFactura
};
