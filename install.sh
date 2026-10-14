#!/bin/sh

# --- CONFIGURACIÓN ---
URL_ZOU="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
URL_TTYD="https://github.com/tsl0922/ttyd/releases/download/1.7.3"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR ZOUREMOTE - V1.1"
echo "================================================="

# 0. LIMPIEZA DE PROCESOS (Para evitar esperas)
echo "> Limpiando procesos antiguos..."
killall -9 ttyd 2>/dev/null
killall -9 python 2>/dev/null

# 1. DETECTAR ARQUITECTURA
ARCH=$(uname -m)
case $ARCH in
    armv7l*) BIN_FILE="ttyd.armhf" ;;
    mips*)   BIN_FILE="ttyd.mips" ;;
    *)       BIN_FILE="ttyd.armhf" ;;
esac

# 2. DESCARGA RÁPIDA
echo "> Instalando binario..."
rm -f /usr/bin/ttyd
curl -kL "${URL_TTYD}/${BIN_FILE}" -o /usr/bin/ttyd

# 3. ARCHIVOS WEB Y SCRIPTS
mkdir -p $PLUGIN_PATH/web
echo "> Descargando recursos..."
curl -kLs "${URL_ZOU}/plugin.png" -o "$PLUGIN_PATH/plugin.png"
curl -kLs "${URL_ZOU}/server.py" -o "$PLUGIN_PATH/server.py"
curl -kLs "${URL_ZOU}/plugin.py" -o "$PLUGIN_PATH/plugin.py"

# Descarga de la carpeta web completa
for file in index.html manifest.json remote.js script.js service-worker.js style.css; do
    curl -kLs "${URL_ZOU}/web/$file" -o "$PLUGIN_PATH/web/$file"
done

# 4. PERMISOS Y OPTIMIZACIÓN
echo "> Aplicando permisos y optimizando..."
chmod 755 /usr/bin/ttyd
chmod 755 $PLUGIN_PATH/server.py
chmod -R 755 $PLUGIN_PATH/web

# 5. ELIMINAR ARCHIVOS COMPILADOS (.pyc) que ralentizan el inicio
find $PLUGIN_PATH -name "*.pyc" -delete

echo "================================================="
echo "   INSTALACIÓN FINALIZADA - REINICIO RÁPIDO"
echo "================================================="

sync
sleep 1
killall -9 enigma2
