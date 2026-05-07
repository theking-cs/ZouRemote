#!/bin/sh

# --- CONFIGURACIÓN ---
URL_BASE="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "================================================="
echo "   INSTALADOR MAESTRO ZOUREMOTE v1.1"
echo "================================================="

# 1. DETECTAR ARQUITECTURA
ARCH=$(uname -m)
echo "> Detectada arquitectura: $ARCH"

case $ARCH in
    armv7l*) BIN_FILE="ttyd.armhf" ;;
    mips*) BIN_FILE="ttyd.mips" ;;
    *) BIN_FILE="ttyd.armhf" ;;
esac

# 2. INSTALACIÓN DE ARCHIVOS
echo "> Instalando componentes..."
rm -f /usr/bin/ttyd
wget --no-check-certificate "$URL_BASE/bin/$BIN_FILE" -O /usr/bin/ttyd
chmod 755 /usr/bin/ttyd

mkdir -p $PLUGIN_PATH/web
wget -q --no-check-certificate "$URL_BASE/server.py" -O "$PLUGIN_PATH/server.py"
wget -q --no-check-certificate "$URL_BASE/plugin.py" -O "$PLUGIN_PATH/plugin.py"
wget -q --no-check-certificate "$URL_BASE/web/index.html" -O "$PLUGIN_PATH/web/index.html"

echo "================================================="
echo "      INSTALACIÓN FINALIZADA CON ÉXITO"
echo "================================================="

# 3. REINICIO DEL GUI
echo ""
echo "Para que los cambios surtan efecto, es necesario reiniciar Enigma2."
echo "Pulse (S) para reiniciar ahora o cualquier otra tecla para salir."
read -p "¿Reiniciar Interfaz ahora? (s/n): " confirm

if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
    echo "> Reiniciando Enigma2... Por favor espere."
    # El comando estándar para reiniciar el GUI de forma segura
    killall -9 enigma2
else
    echo "> Instalación terminada. No olvide reiniciar manualmente."
fi
