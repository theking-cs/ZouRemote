#!/bin/sh
# --- ZouRemote Installer v1.1 (Soporte Online) ---

PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1                           *"
echo "********************************************************"

# Crear carpetas necesarias
mkdir -p $PLUGIN_PATH
mkdir -p $PLUGIN_PATH/web

# Función para descargar archivos directamente al destino
download_plugin_file() {
    echo "> Descargando $1..."
    wget -q --no-check-certificate -O "$PLUGIN_PATH/$1" "$URL_RAW/$1"
}

# 1. Descargar archivos base (Asegúrate de que en GitHub estén dentro de la carpeta ZouRemote)
download_plugin_file "plugin.py"
download_plugin_file "server.py"
download_plugin_file "__init__.py"
download_plugin_file "plugin.png"

# 2. Descargar archivos web
echo "> Descargando archivos web..."
wget -q --no-check-certificate -O "$PLUGIN_PATH/web/index.html" "$URL_RAW/web/index.html"

# 3. Permisos
echo "> Aplicando permisos 755..."
chmod -R 755 $PLUGIN_PATH

# 4. Limpieza de Python (MUY IMPORTANTE para que coja los cambios)
rm -f $PLUGIN_PATH/*.pyc

# 5. Intentar instalar dependencias
echo "> Actualizando repositorios e instalando dependencias..."
opkg update
opkg install ttyd psmisc

echo "-------------------------------------------------------"
echo " INSTALACIÓN FINALIZADA. REINICIANDO ENIGMA2..."
echo "-------------------------------------------------------"

killall -9 enigma2
