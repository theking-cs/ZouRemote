#!/bin/sh

# --- CONFIGURACIÓN ---
REPO_VERSION="1.1"
# Usamos la URL de redirección directa de GitHub
URL_OFFICIAL="https://github.com/tsl0922/ttyd/releases/download/$REPO_VERSION"
URL_PLUGIN_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR UNIVERSAL ZOUREMOTE v1.1"
echo "================================================="

# 1. DETECTAR ARQUITECTURA
ARCH=$(uname -m)
echo "> Detectada arquitectura: $ARCH"

case $ARCH in
    armv7l*)
        echo "> Compatible con ARMv7 (Vu+ 4K, Novaler 4K...)"
        BIN_FILE="ttyd.armhf"
        ;;
    mips*)
        echo "> Compatible con MIPS (Decos HD antiguos...)"
        BIN_FILE="ttyd.mips"
        ;;
    aarch64*)
        echo "> Compatible con ARM 64-bit."
        BIN_FILE="ttyd.aarch64"
        ;;
    *)
        echo "> Intentando versión ARMhf por defecto..."
        BIN_FILE="ttyd.armhf"
        ;;
esac

# 2. INTENTAR INSTALAR LIBRERÍAS (Si falla no pasa nada)
echo "> Verificando librerías opcionales..."
opkg update > /dev/null 2>&1
opkg install libwebsockets > /dev/null 2>&1

# 3. DESCARGAR BINARIO (Añadimos --no-check-certificate y -L si estuviera disponible)
echo "> Descargando $BIN_FILE desde GitHub..."
rm -f /usr/bin/ttyd

# Intentamos la descarga forzando el seguimiento de redirecciones
wget --no-check-certificate "$URL_OFFICIAL/$BIN_FILE" -O /usr/bin/ttyd

# Si el archivo pesa 0 o no existe, intentamos link alternativo
if [ ! -s /usr/bin/ttyd ]; then
    echo "> Reintentando descarga con método alternativo..."
    # A veces GitHub requiere este formato para los assets
    wget --no-check-certificate "https://github.com/tsl0922/ttyd/releases/latest/download/$BIN_FILE" -O /usr/bin/ttyd
fi

if [ ! -s /usr/bin/ttyd ]; then
    echo "¡ERROR! No se pudo descargar el binario de la consola."
    exit 1
fi

chmod 755 /usr/bin/ttyd
echo "> Consola instalada correctamente."

# 4. INSTALAR ARCHIVOS DEL PLUGIN
echo "> Descargando archivos del plugin desde tu repositorio..."
mkdir -p $PLUGIN_PATH/web
wget -q --no-check-certificate "$URL_PLUGIN_RAW/server.py" -O "$PLUGIN_PATH/server.py"
wget -q --no-check-certificate "$URL_PLUGIN_RAW/plugin.py" -O "$PLUGIN_PATH/plugin.py"
wget -q --no-check-certificate "$URL_PLUGIN_RAW/web/index.html" -O "$PLUGIN_PATH/web/index.html"

echo "================================================="
echo " INSTALACIÓN FINALIZADA"
echo "================================================="
