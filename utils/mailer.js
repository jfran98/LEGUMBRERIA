const nodemailer = require('nodemailer');
require('dotenv').config(); // Asegúrate de tener esto para usar variables del .env

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS
  }
});

function enviarCorreoRegistro(destinatario, asunto, mensajeHTML) {
  const opciones = {
    from: '"Legumbrería JM" <legumbreriajmla84@gmail.com>',
    to: destinatario,
    subject: asunto,
    html: mensajeHTML
  };

  return transporter.sendMail(opciones);
}

module.exports = enviarCorreoRegistro;
