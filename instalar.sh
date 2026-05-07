#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Installer by theking-cs             *
# ********************************************************

DESTINO="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1 (Override Fix)             *"
echo "********************************************************"

# 1. Detener procesos activos para evitar "Text file busy"
echo "> Deteniendo servicios antiguos..."
killall -9 ttyd 2>/dev/null
pkill -f server.py 2>/dev/null

# 2. Crear estructura
mkdir -p $DESTINO
mkdir -p $DESTINO/web

# 3. Descarga de archivos del Plugin
echo "> Actualizando archivos del plugin..."
wget -q --no-check-certificate -O "$DESTINO/plugin.py" "$URL_RAW/plugin.py"
wget -q --no-check-certificate -O "$DESTINO/server.py" "$URL_RAW/server.py"
wget -q --no-check-certificate -O "$DESTINO/__init__.py" "$URL_RAW/__init__.py"
wget -q --no-check-certificate -O "$DESTINO/plugin.png" "$URL_RAW/plugin.png"
wget -q --no-check-certificate -O "$DESTINO/web/index.html" "$URL_RAW/web/index.html"

# 4. Actualizar Binario ttyd (ahora sí dejará)
echo "> Actualizando binario de consola..."
wget -q --no-check-certificate -O "/usr/bin/ttyd" "https://github.com/theking-cs/ZouRemote/raw/main/ttyd_arm"
chmod 755 /usr/bin/ttyd

# 5. Limpieza y Permisos
chmod -R 755 $DESTINO
rm -f $DESTINO/*.pyc

echo "-------------------------------------------------------"
echo " INSTALACIÓN COMPLETADA CON ÉXITO"
echo " REINICIANDO ENIGMA2..."
echo "-------------------------------------------------------"

killall -9 enigma2
