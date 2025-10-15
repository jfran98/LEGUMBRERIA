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

module.exports = {
  plantillaRegistro,
  plantillaEdicion
};