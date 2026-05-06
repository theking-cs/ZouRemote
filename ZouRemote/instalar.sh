#!/bin/sh
# --- ZouRemote Installer v1.1 (Soporte Online) ---

PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"

echo "> Preparando instalación de ZouRemote..."
mkdir -p $PLUGIN_PATH
mkdir -p $PLUGIN_PATH/web

# Función para descargar si el archivo no existe localmente
download_file() {
    if [ ! -f "./$1" ]; then
        echo "> Descargando $1 desde GitHub..."
        wget -qO "$PLUGIN_PATH/$1" "$URL_RAW/$1"
    else
        echo "> Copiando $1 localmente..."
        cp -rp "./$1" "$PLUGIN_PATH/$1"
    fi
}

# Lista de archivos a instalar
download_file "plugin.py"
download_file "server.py"
download_file "__init__.py"
download_file "plugin.png"

# Para la carpeta web, si no existe local, bajamos el index (puedes añadir más)
if [ ! -d "./web" ]; then
    echo "> Descargando archivos web..."
    wget -qO "$PLUGIN_PATH/web/index.html" "$URL_RAW/web/index.html"
else
    cp -rp ./web/* $PLUGIN_PATH/web/
fi

# Permisos y dependencias
chmod -R 755 $PLUGIN_PATH
opkg update
opkg install ttyd psmisc wget

echo "-------------------------------------------------------"
echo " INSTALACIÓN FINALIZADA. REINICIA TU DECO."
echo "-------------------------------------------------------"
