#!/bin/sh

# 1. Descargar el script original directamente en /etc/init.d/
curl -sL https://raw.githubusercontent.com/theking-cs/ZouRemote/main/zouremote -o /etc/init.d/zouremote

# 2. Darle permisos de ejecución
chmod +x /etc/init.d/zouremote

# 3. Registrar el servicio en el arranque del sistema
update-rc.d zouremote defaults

# 4. Iniciar el servicio
/etc/init.d/zouremote start

echo "¡Script ZouRemote instalado correctamente en /etc/init.d/!"
exit 0
