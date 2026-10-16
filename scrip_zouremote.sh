#!/bin/sh

# 1. Descargar el script directamente a /etc/init.d/
curl -sL https://raw.githubusercontent.com/theking-cs/ZouRemote/main/zouremote -o /etc/init.d/zouremote || wget -qO /etc/init.d/zouremote https://raw.githubusercontent.com/theking-cs/ZouRemote/main/zouremote

# 2. Asignar permisos de ejecución
chmod +x /etc/init.d/zouremote

# 3. Registrar en el arranque del sistema
update-rc.d zouremote defaults

# 4. Iniciar el servicio
/etc/init.d/zouremote start

echo "¡Script instalado con éxito!"
exit 0
