#!/bin/sh

# --- CONFIGURACIÓN ---
REPO_VERSION="1.1"
URL_OFFICIAL="https://github.com/tsl0922/ttyd/releases/download/$REPO_VERSION"
URL_PLUGIN_RAW="https://raw.githubusercontent.com/TU_USUARIO/ZouRemote/main"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR UNIVERSAL ZOUREMOTE v1.1"
echo "================================================="

# 1. DETECTAR ARQUITECTURA
ARCH=$(uname -m)
echo "> Detectada arquitectura: $ARCH"

case $ARCH in
    armv7l*)
        echo "> Compatible con ARMv7 (Vu+ 4K, Novaler 4K, Zgemma 4K...)"
        BIN_FILE="ttyd.armhf"
        ;;
    mips*)
        echo "> Compatible con MIPS (Vu+ HD, decos antiguos...)"
        BIN_FILE="ttyd.mips"
        ;;
    aarch64*)
        echo "> Compatible con ARM 64-bit."
        BIN_FILE="ttyd.aarch64"
        ;;
    i686*|x86_64*)
        echo "> Compatible con PC (x86)."
        BIN_FILE="ttyd.i686"
        ;;
    *)
        echo "> Arquitectura no identificada. Intentando versión ARM por defecto..."
        BIN_FILE="ttyd.armhf"
        ;;
esac

# 2. INSTALAR DEPENDENCIAS
echo "> Actualizando paquetes e instalando librerías..."
opkg update
opkg install libwebsockets libjson-c5

# 3. DESCARGAR DIRECTO DEL DESARROLLADOR
echo "> Descargando $BIN_FILE desde GitHub oficial..."
rm -f /usr/bin/ttyd
wget -q --no-check-certificate "$URL_OFFICIAL/$BIN_FILE" -O /usr/bin/ttyd

if [ $? -ne 0 ]; then
    echo "¡ERROR! No se pudo descargar el binario oficial."
    exit 1
fi

chmod 755 /usr/bin/ttyd

# 4. INSTALAR ARCHIVOS DE TU REPOSITORIO (Python y Web)
echo "> Instalando archivos del plugin..."
mkdir -p $PLUGIN_PATH/web
wget -q --no-check-certificate "$URL_PLUGIN_RAW/server.py" -O "$PLUGIN_PATH/server.py"
wget -q --no-check-certificate "$URL_PLUGIN_RAW/plugin.py" -O "$PLUGIN_PATH/plugin.py"
wget -q --no-check-certificate "$URL_PLUGIN_RAW/web/index.html" -O "$PLUGIN_PATH/web/index.html"

# 5. LIMPIEZA Y CIERRE
echo "================================================="
echo " INSTALACIÓN FINALIZADA"
echo " Reinicia Enigma2 y abre el puerto 1991."
echo "================================================="
