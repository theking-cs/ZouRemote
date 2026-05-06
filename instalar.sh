#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Installer by theking-cs             *
# ********************************************************

PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1                            *"
echo "********************************************************"

# 1. Intentar instalar dependencias
echo "> Verificando dependencias..."
opkg update
opkg install psmisc
# Nota: Si ttyd no está en el feed, el usuario deberá subir el binario manualmente a /usr/bin/
opkg install ttyd || echo "![AVISO] ttyd no encontrado en feeds. Instalar manualmente."

# 2. Limpieza
rm -rf $PLUGIN_PATH
rm -rf /tmp/ZouRemote.zip /tmp/Zou-main

# 3. Descarga
echo "> Descargando desde GitHub..."
wget --no-check-certificate https://github.com/theking-cs/ZouRemote/archive/refs/heads/main.zip -O /tmp/ZouRemote.zip

# 4. Extracción inteligente
echo "> Extrayendo archivos..."
unzip -q /tmp/ZouRemote.zip -d /tmp/
# Buscamos la carpeta extraída (GitHub le añade '-main')
FOLDER_TMP=$(ls -d /tmp/ZouRemote-*)

# 5. Instalación
if [ -d "$FOLDER_TMP/ZouRemote" ]; then
    echo "> Moviendo carpeta del plugin..."
    cp -r $FOLDER_TMP/ZouRemote /usr/lib/enigma2/python/Plugins/Extensions/
    chmod -R 755 $PLUGIN_PATH
    echo "********************************************************"
    echo "* INSTALACIÓN COMPLETADA - REINICIANDO ENIGMA2       *"
    echo "********************************************************"
    killall -9 enigma2
else
    echo "![ERROR] No se encontró la carpeta 'ZouRemote' dentro del ZIP."
    echo "Asegúrate de que en GitHub los archivos estén dentro de una carpeta llamada ZouRemote."
fi

rm -rf /tmp/ZouRemote.zip /tmp/ZouRemote-*
