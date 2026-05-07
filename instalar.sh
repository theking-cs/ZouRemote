#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Installer by theking-cs             *
# ********************************************************

DESTINO="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1 (Safe Install)             *"
echo "********************************************************"

# 1. Detener procesos
killall -9 ttyd 2>/dev/null
pkill -f server.py 2>/dev/null

# 2. Preparar carpetas
mkdir -p $DESTINO/web

# Función segura para descargar: Solo guarda si el archivo no está vacío
download_safe() {
    local file=$1
    local output=$2
    echo "> Descargando $file..."
    wget -q --no-check-certificate -O "/tmp/$file" "$URL_RAW/$file"
    
    # Comprobar si el archivo descargado en /tmp tiene tamaño mayor a 0
    if [ -s "/tmp/$file" ]; then
        mv "/tmp/$file" "$output"
    else
        echo "![ERROR] Falló descarga de $file o está vacío. Manteniendo anterior."
        rm -f "/tmp/$file"
    fi
}

# 3. Descarga de archivos base
download_safe "plugin.py" "$DESTINO/plugin.py"
download_safe "server.py" "$DESTINO/server.py"
download_safe "__init__.py" "$DESTINO/__init__.py"
download_safe "plugin.png" "$DESTINO/plugin.png"

# 4. Descarga de archivos web (Corregido nombres)
download_safe "web/index.html" "$DESTINO/web/index.html"
download_safe "web/style.css" "$DESTINO/web/style.css"
download_safe "web/remote.js" "$DESTINO/web/remote.js"
download_safe "web/script.js" "$DESTINO/web/script.js"
download_safe "web/service-worker.js" "$DESTINO/web/service-worker.js"
download_safe "web/manifest.json" "$DESTINO/web/manifest.json"

# 5. Binario ttyd
echo "> Actualizando binario de consola..."
wget -q --no-check-certificate -O "/usr/bin/ttyd" "https://github.com/theking-cs/ZouRemote/raw/main/ttyd_arm"
chmod 755 /usr/bin/ttyd

# 6. Permisos y Limpieza
chmod -R 755 $DESTINO
rm -f $DESTINO/*.pyc

echo "-------------------------------------------------------"
echo " INSTALACIÓN COMPLETADA. REINICIANDO..."
echo "-------------------------------------------------------"

killall -9 enigma2
