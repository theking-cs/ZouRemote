#!/bin/sh

# --- CONFIGURACIÓN ---
URL_BASE="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR ZOUREMOTE - VERSION 1.1"
echo "================================================="

# 1. DETECTAR ARQUITECTURA
# Esto leerá si tu VuSolo4K o cualquier otro deco es ARM o MIPS
ARCH=$(uname -m)
echo "> Arquitectura del sistema: $ARCH"

case $ARCH in
    armv7l*) 
        BIN_FILE="ttyd.armhf"
        echo "> Seleccionado binario para ARM (4K)"
        ;;
    mips*)   
        BIN_FILE="ttyd.mips"
        echo "> Seleccionado binario para MIPS (HD)"
        ;;
    *)       
        BIN_FILE="ttyd.armhf"
        echo "> Arquitectura no reconocida, intentando ARM por defecto"
        ;;
esac

# 2. DESCARGA DEL BINARIO (Desde tu carpeta /bin/)
echo "> Descargando binario desde: $URL_BASE/bin/$BIN_FILE"
rm -f /usr/bin/ttyd

# Usamos curl con -k (ignorar SSL) y -L (seguir redirecciones de GitHub)
curl -kL "$URL_BASE/bin/$BIN_FILE" -o /usr/bin/ttyd

# 3. VERIFICACIÓN DE TAMAÑO (Para evitar los 0 bytes)
if [ ! -s /usr/bin/ttyd ]; then
    echo "-------------------------------------------------"
    echo " ERROR: El archivo ttyd se descargó vacío."
    echo " REVISA: Que en tu GitHub el archivo esté en /bin/$BIN_FILE"
    echo "-------------------------------------------------"
    exit 1
fi

chmod 755 /usr/bin/ttyd
echo "> Consola instalada con éxito."

# 4. INSTALACIÓN DE ARCHIVOS DEL PLUGIN
echo "> Descargando scripts del servidor y archivos web..."
mkdir -p $PLUGIN_PATH/web

# Descarga de archivos raíz del plugin
curl -kL "$URL_BASE/server.py" -o "$PLUGIN_PATH/server.py"
curl -kL "$URL_BASE/plugin.py" -o "$PLUGIN_PATH/plugin.py"

# Descarga de archivos dentro de /web/
curl -kL "$URL_BASE/web/index.html" -o "$PLUGIN_PATH/web/index.html"
curl -kL "$URL_BASE/web/remote.js" -o "$PLUGIN_PATH/web/remote.js"

# Permisos para el servidor Python
chmod 755 "$PLUGIN_PATH/server.py"

echo "================================================="
echo "   INSTALACIÓN COMPLETADA - REINICIANDO GUI"
echo "================================================="

# Sincronizar cambios y reiniciar la interfaz Enigma2
sync
sleep 2
killall -9 enigma2
