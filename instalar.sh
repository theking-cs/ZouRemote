#!/bin/sh

# --- CONFIGURACIÓN ---
URL_ZOU="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
# Usamos el repositorio oficial para los binarios que sí descargan bien
URL_TTYD="https://github.com/tsl0922/ttyd/releases/download/1.7.3"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR ZOUREMOTE - VERSION 1.1 (FIXED)"
echo "================================================="

# 1. DETECTAR ARQUITECTURA
ARCH=$(uname -m)
case $ARCH in
    armv7l*) 
        BIN_FILE="ttyd.armhf"
        echo "> Arquitectura ARM (4K) detectada."
        ;;
    mips*)   
        BIN_FILE="ttyd.mips"
        echo "> Arquitectura MIPS (HD) detectada."
        ;;
    *)       
        BIN_FILE="ttyd.armhf"
        echo "> Arquitectura desconocida, usando ARM por defecto."
        ;;
esac

# 2. DESCARGA DEL BINARIO (Desde fuente verificada)
echo "> Descargando consola ttyd..."
rm -f /usr/bin/ttyd
curl -kL "${URL_TTYD}/${BIN_FILE}" -o /usr/bin/ttyd
chmod 755 /usr/bin/ttyd

# Verificar si se bajó bien
SIZE=$(ls -s /usr/bin/ttyd | awk '{print $1}')
if [ "$SIZE" -lt 100 ]; then
    echo "!!! ERROR: Fallo al descargar el binario de la consola."
    exit 1
fi
echo "> Consola instalada correctamente ($SIZE KB)."

# 3. INSTALACIÓN DE ARCHIVOS DEL PLUGIN (Desde tu GitHub)
echo "> Instalando componentes de ZouRemote..."
mkdir -p $PLUGIN_PATH/web

curl -kLs "${URL_ZOU}/server.py" -o "$PLUGIN_PATH/server.py"
curl -kLs "${URL_ZOU}/plugin.py" -o "$PLUGIN_PATH/plugin.py"
curl -kLs "${URL_ZOU}/web/index.html" -o "$PLUGIN_PATH/web/index.html"
curl -kLs "${URL_ZOU}/web/remote.js" -o "$PLUGIN_PATH/web/remote.js"

chmod 755 "$PLUGIN_PATH/server.py"

echo "================================================="
echo "   INSTALACIÓN COMPLETA - REINICIANDO GUI"
echo "================================================="

sync
sleep 2
killall -9 enigma2
