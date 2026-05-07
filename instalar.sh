#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Universal Installer                 *
# ********************************************************

DESTINO="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"
# PRUEBA ESTA URL (Asegúrate de que el nombre del usuario y repo sean correctos)
URL_RAW="https://raw.githubusercontent.com/theking-cs/ZouRemote/main"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1                            *"
echo "********************************************************"

# 1. Limpieza total previa
killall -9 ttyd 2>/dev/null
pkill -f server.py 2>/dev/null
mkdir -p $DESTINO/web

# Función de descarga ultra-compatible
download_file() {
    local source_path=$1  # Ruta en GitHub
    local dest_path=$2    # Ruta en el deco
    
    echo "> Descargando: $source_path"
    # Intentamos descargar directamente al destino
    wget -q --no-check-certificate -O "$dest_path" "$URL_RAW/$source_path"
    
    if [ ! -s "$dest_path" ]; then
        # Si falló, intentamos buscarlo dentro de la carpeta /ZouRemote/ en GitHub
        wget -q --no-check-certificate -O "$dest_path" "$URL_RAW/ZouRemote/$source_path"
    fi

    if [ -s "$dest_path" ]; then
        echo "  [OK] Guardado en $dest_path"
    else
        echo "  [ERROR] No se pudo obtener $source_path"
        rm -f "$dest_path"
    fi
}

# 3. Descarga de archivos (Se adapta a si están en raíz o en carpeta /ZouRemote)
download_file "plugin.py" "$DESTINO/plugin.py"
download_file "server.py" "$DESTINO/server.py"
download_file "__init__.py" "$DESTINO/__init__.py"
download_file "plugin.png" "$DESTINO/plugin.png"
download_file "web/index.html" "$DESTINO/web/index.html"
download_file "web/style.css" "$DESTINO/web/style.css"
download_file "web/remote.js" "$DESTINO/web/remote.js"
download_file "web/script.js" "$DESTINO/web/script.js"
download_file "web/service-worker.js" "$DESTINO/web/service-worker.js"
download_file "web/manifest.json" "$DESTINO/web/manifest.json"

# 4. Binario ttyd (Desde la raíz del repo)
echo "> Instalando binario ttyd..."
wget -q --no-check-certificate -O "/usr/bin/ttyd" "$URL_RAW/ttyd_arm"
chmod 755 /usr/bin/ttyd

# 5. Permisos y reinicio
chmod -R 755 $DESTINO
rm -f $DESTINO/*.pyc

echo "-------------------------------------------------------"
echo " PROCESO FINALIZADO. REINICIANDO ENIGMA2..."
echo "-------------------------------------------------------"
killall -9 enigma2
