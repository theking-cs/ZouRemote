#!/bin/sh
# ********************************************************
# * ZouRemote v1.0 - Installer by theking-cs             *
# ********************************************************

PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote"

echo "********************************************************"
echo "* Instalando ZouRemote v1.0                            *"
echo "********************************************************"

# 1. Instalación de dependencias
echo "> Verificando dependencias (ttyd y psmisc)..."
opkg update
opkg install ttyd psmisc

# 2. Limpieza de instalaciones antiguas
echo "> Limpiando versiones previas..."
rm -rf $PLUGIN_PATH
rm -rf /tmp/ZouRemote.zip /tmp/ZouRemote-main

# 3. Descarga desde GitHub
echo "> Descargando ZouRemote v1.0..."
wget --no-check-certificate https://github.com/theking-cs/ZouRemote/archive/refs/heads/main.zip -O /tmp/ZouRemote.zip

# 4. Extracción
echo "> Extrayendo archivos..."
unzip -q /tmp/ZouRemote.zip -d /tmp/

# 5. Instalación en el sistema
echo "> Moviendo archivos a Extensions..."
cp -r /tmp/ZouRemote-main/ZouRemote /usr/lib/enigma2/python/Plugins/Extensions/

# 6. Configuración de permisos
echo "> Configurando permisos 755..."
chmod -R 755 $PLUGIN_PATH

# 7. Limpieza final
rm -rf /tmp/ZouRemote.zip /tmp/ZouRemote-main

echo "********************************************************"
echo "* INSTALACIÓN COMPLETADA - REINICIANDO ENIGMA2       *"
echo "********************************************************"

# Reinicio forzado de la GUI
killall -9 enigma2
