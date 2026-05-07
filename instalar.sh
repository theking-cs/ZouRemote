#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Installer by theking-cs             *
# ********************************************************

DESTINO="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1 (Safe Install Fixed)       *"
echo "********************************************************"

# 1. Detener procesos
killall -9 ttyd 2>/dev/null
pkill -f server.py 2>/dev/null

# 2. Preparar carpetas
mkdir -p $DESTINO/web

# Función segura corregida
download_safe() {
    local remote_file=$1  # Ruta en GitHub (ej: web/index.html)
    local local_name=$2   # Nombre del archivo (ej: index.html)
    local final_dest=$3   # Ruta final (ej: $DESTINO/web/index.html)

    echo "> Descargando $remote_file..."
    # Descargamos siempre a un archivo plano en /tmp para evitar líos de carpetas
    wget -q --no-check-certificate -O "/tmp/zou_temp" "$URL_RAW/$remote_file"
    
    if [ -s "/tmp/zou_temp" ]; then
        mv "/tmp/zou_temp" "$final_dest"
    else
        echo "![ERROR] Falló $remote_file. URL incorrecta o archivo vacío."
        rm -f "/tmp/zou_temp"
    fi
}

# 3. Descarga de archivos base
download_safe "plugin.py" "plugin.py" "$DESTINO/plugin.py"
download_safe "server.py" "server.py" "$DESTINO/server.py"
download_safe "__init__.py" "__init__.py" "$DESTINO/__init__.py"
download_safe "plugin.png" "plugin.png" "$DESTINO/plugin.png"

# 4. Descarga de archivos web (Asegúrate que existen en GitHub/ZouRemote/web/)
download_safe "web/index.html" "index.html" "$DESTINO/web/index.html"
download_safe "web/style.css" "style.css" "$DESTINO/web/style.css"
download_safe "web/remote.js" "remote.js" "$DESTINO/web/remote.js"
download_safe "web/script.js" "script.js" "$DESTINO/web/script.js"
download_safe "web/service-worker.js" "service-worker.js" "$DESTINO/web/service-worker.js"
download_safe "web/manifest.json" "manifest.json" "$DESTINO/web/manifest.json"

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
