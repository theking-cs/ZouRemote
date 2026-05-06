#!/bin/sh
# ********************************************************
# * ZouRemote v1.1 - Installer by theking-cs             *
# ********************************************************

DESTINO="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.1                            *"
echo "********************************************************"

# 1. Limpieza
rm -rf $DESTINO /tmp/ZouRemote.zip /tmp/ZouRemote-main

# 2. Descarga
echo "> Descargando desde GitHub..."
wget --no-check-certificate https://github.com/theking-cs/ZouRemote/archive/refs/heads/main.zip -O /tmp/ZouRemote.zip

# 3. Extracción
echo "> Extrayendo archivos..."
unzip -q /tmp/ZouRemote.zip -d /tmp/
TMP_DIR=$(ls -d /tmp/ZouRemote-* 2>/dev/null)

# 4. Instalación (Detección flexible)
mkdir -p $DESTINO

if [ -d "$TMP_DIR/ZouRemote" ]; then
    echo "> Carpeta encontrada. Instalando..."
    cp -r $TMP_DIR/ZouRemote/* $DESTINO/
else
    echo "> Instalando archivos desde raíz del repo..."
    cp -r $TMP_DIR/* $DESTINO/
    # Borramos el instalador que se copió por error
    rm -f $DESTINO/instalar.sh
fi

# 5. Permisos
chmod -R 755 $DESTINO

# Limpieza final
rm -rf /tmp/ZouRemote.zip /tmp/ZouRemote-*

echo "********************************************************"
echo "* INSTALACIÓN COMPLETADA - REINICIANDO ENIGMA2       *"
echo "********************************************************"
killall -9 enigma2
