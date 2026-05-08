#!/bin/sh

# --- CONFIGURACIÓN ---
URL_ZOU="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
URL_TTYD="https://github.com/tsl0922/ttyd/releases/download/1.7.3"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR ZOUREMOTE - VERSION 1.1 "
echo "================================================="

# 1. DETECTAR ARQUITECTURA
ARCH=$(uname -m)
case $ARCH in
    armv7l*) BIN_FILE="ttyd.armhf" ;;
    mips*)   BIN_FILE="ttyd.mips" ;;
    *)       BIN_FILE="ttyd.armhf" ;;
esac

# 2. DESCARGA DEL BINARIO TTYD
echo "> Instalando binario de consola..."
rm -f /usr/bin/ttyd
curl -kL "${URL_TTYD}/${BIN_FILE}" -o /usr/bin/ttyd

# 3. CREAR DIRECTORIOS
mkdir -p $PLUGIN_PATH/web

# 4. DESCARGAR ARCHIVOS RAÍZ E ICONO
echo "> Descargando scripts e icono..."
curl -kLs "${URL_ZOU}/plugin.png" -o "$PLUGIN_PATH/plugin.png"
curl -kLs "${URL_ZOU}/server.py" -o "$PLUGIN_PATH/server.py"
curl -kLs "${URL_ZOU}/plugin.py" -o "$PLUGIN_PATH/plugin.py"

# 5. DESCARGAR CARPETA WEB (PWA)
echo "> Descargando archivos web..."
curl -kLs "${URL_ZOU}/web/index.html" -o "$PLUGIN_PATH/web/index.html"
curl -kLs "${URL_ZOU}/web/manifest.json" -o "$PLUGIN_PATH/web/manifest.json"
curl -kLs "${URL_ZOU}/web/remote.js" -o "$PLUGIN_PATH/web/remote.js"
curl -kLs "${URL_ZOU}/web/script.js" -o "$PLUGIN_PATH/web/script.js"
curl -kLs "${URL_ZOU}/web/service-worker.js" -o "$PLUGIN_PATH/web/service-worker.js"
curl -kLs "${URL_ZOU}/web/style.css" -o "$PLUGIN_PATH/web/style.css"

# 6. BLINDAJE DE PERMISOS (Crucial para que funcione)
echo "> Aplicando permisos de ejecución..."

# Permisos para el binario de la consola
chmod 755 /usr/bin/ttyd

# Permisos para los scripts del plugin
chmod 755 $PLUGIN_PATH/server.py
chmod 755 $PLUGIN_PATH/plugin.py

# Permisos para la carpeta web (lectura para el servidor HTTP)
chmod -R 755 $PLUGIN_PATH/web

echo "================================================="
echo "   PERMISOS CONFIGURADOS - REINICIANDO"
echo "================================================="

sync
sleep 2
killall -9 enigma2
