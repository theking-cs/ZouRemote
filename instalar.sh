#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Installer by theking-cs             *
# ********************************************************

DESTINO="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1 (Fix ttyd & psmisc)        *"
echo "********************************************************"

# 1. Crear estructura
mkdir -p $DESTINO
mkdir -p $DESTINO/web

# 2. Descarga de archivos del Plugin
echo "> Descargando archivos Python y Web..."
wget -q --no-check-certificate -O "$DESTINO/plugin.py" "$URL_RAW/plugin.py"
wget -q --no-check-certificate -O "$DESTINO/server.py" "$URL_RAW/server.py"
wget -q --no-check-certificate -O "$DESTINO/__init__.py" "$URL_RAW/__init__.py"
wget -q --no-check-certificate -O "$DESTINO/plugin.png" "$URL_RAW/plugin.png"
wget -q --no-check-certificate -O "$DESTINO/web/index.html" "$URL_RAW/web/index.html"

# 3. FIX: Binario ttyd para ARM (Vu+ Solo 4K y similares)
# Intentamos bajar un binario estático compatible si opkg falla
if ! opkg list-installed | grep -q ttyd; then
    echo "> ttyd no encontrado en feeds. Instalando binario estático..."
    # URL de un binario ttyd compatible con ARM (puedes subir el tuyo a GitHub y cambiar esta URL)
    wget -q --no-check-certificate -O "/usr/bin/ttyd" "https://github.com/theking-cs/ZouRemote/raw/main/ttyd_arm"
    chmod 755 /usr/bin/ttyd
fi

# 4. Dependencias críticas de Python
echo "> Verificando librerías necesarias..."
opkg update
opkg install python-twisted-web python-json psmisc 2>/dev/null || echo "! Algunos paquetes menores fallaron, continuando..."

# 5. Permisos Finales
chmod -R 755 $DESTINO
rm -f $DESTINO/*.pyc

echo "-------------------------------------------------------"
echo " INSTALACIÓN COMPLETADA CON ÉXITO"
echo " REINICIANDO ENIGMA2 PARA APLICAR CAMBIOS"
echo "-------------------------------------------------------"

killall -9 enigma2
