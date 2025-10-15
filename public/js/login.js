document.addEventListener('DOMContentLoaded', () => {
  const formLogin = document.getElementById('formLogin');

  if (formLogin) {
    formLogin.addEventListener('submit', async (e) => {
      e.preventDefault();

      const email = document.getElementById('correo').value.trim();
      const password = document.getElementById('contrasena').value.trim();

      try {
        const res = await fetch('/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ email, password })
        });

        const resultado = await res.json();

        if (res.ok) {
          localStorage.setItem('token', resultado.token);
          alert('✅ Inicio de sesión exitoso');
          window.location.href = '/perfil.html';
        } else {
          alert(`⚠️ ${resultado.mensaje || 'Credenciales incorrectas'}`);
        }
      } catch (error) {
        console.error('Error al iniciar sesión:', error);
        alert('❌ Error de conexión con el servidor.');
      }
    });
  }
});
