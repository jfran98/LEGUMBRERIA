# Usa una imagen oficial de Node.js basada en Alpine para que sea liviana
FROM node:20-alpine

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos package.json y package-lock.json primero
# Esto ayuda a aprovechar el caché de Docker para la instalación de dependencias
COPY package*.json ./

# Instala las dependencias de producción
RUN npm install --omit=dev

# Copia el resto del código del proyecto al contenedor
COPY . .

# Expone el puerto (si Railway usa uno predeterminado, normalmente es asignado por env PORT)
EXPOSE 4545

# Comando para iniciar la aplicación (ejecuta "node app.js" según tu package.json)
CMD ["npm", "start"]
