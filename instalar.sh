#!/bin/sh

# --- CONFIGURACIÓN ---
URL_BASE="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR MAESTRO ZOUREMOTE v1.1 (GUI)"
echo "================================================="

# 1. DETECTAR ARQUITECTURA PARA TTYD (CONSOLA)
ARCH=$(uname -m)
echo "> Detectada arquitectura: $ARCH"

case $ARCH in
    armv7l*) BIN_FILE="ttyd.armhf" ;;
    mips*)   BIN_FILE="ttyd.mips" ;;
    *)       BIN_FILE="ttyd.armhf" ;;
esac

# 2. LIMPIEZA E INSTALACIÓN DE BINARIOS
echo "> Configurando binarios de consola..."
rm -f /usr/bin/ttyd
wget --no-check-certificate "$URL_BASE/bin/$BIN_FILE" -O /usr/bin/ttyd
chmod 755 /usr/bin/ttyd

# 3. DESCARGA DE ESTRUCTURA DE COMPONENTES
echo "> Instalando archivos del servidor y web..."
mkdir -p $PLUGIN_PATH/web

wget -q --no-check-certificate "$URL_BASE/server.py" -O "$PLUGIN_PATH/server.py"
wget -q --no-check-certificate "$URL_BASE/plugin.py" -O "$PLUGIN_PATH/plugin.py"
wget -q --no-check-certificate "$URL_BASE/web/index.html" -O "$PLUGIN_PATH/web/index.html"
wget -q --no-check-certificate "$URL_BASE/web/remote.js" -O "$PLUGIN_PATH/web/remote.js"

chmod 755 "$PLUGIN_PATH/server.py"

echo "================================================="
echo "      INSTALACIÓN FINALIZADA CON ÉXITO"
echo "================================================="

# 4. REINICIO SÓLO DE LA INTERFAZ (GUI)
echo ""
echo "Instalación completada. Es necesario reiniciar la interfaz Enigma2."
read -p "¿Reiniciar Interfaz ahora? (s/n): " confirm

if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
    echo "> Reiniciando Enigma2... Por favor espere."
    # Mata el proceso de enigma2 para que el sistema lo reinicie automáticamente (Reinicio de GUI)
    killall -9 enigma2
else
    echo "> Instalación terminada. No olvides reiniciar la interfaz manualmente."
fi
