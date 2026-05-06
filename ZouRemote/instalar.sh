#!/bin/sh
# =========================================================
# ZouRemote Installer - Version 1.1
# =========================================================

PLUGIN_NAME="ZouRemote"
PLUGIN_PATH="/usr/lib/enigma2/python/Plugins/Extensions/$PLUGIN_NAME"

echo "---------------------------------------------------------"
echo "Instalando $PLUGIN_NAME v1.1 en su receptor..."
echo "---------------------------------------------------------"

# 1. Limpieza preventiva
if [ -d $PLUGIN_PATH ]; then
    echo "> Detectada instalación previa. Limpiando..."
    rm -rf $PLUGIN_PATH/*.pyc $PLUGIN_PATH/*.pyo
fi

# 2. Crear directorios
mkdir -p $PLUGIN_PATH
mkdir -p $PLUGIN_PATH/web

# 3. Copiar archivos del repositorio
echo "> Copiando nuevos archivos..."
cp -rp ./* $PLUGIN_PATH/

# 4. Ajuste de permisos (Crucial para el servidor y la consola)
echo "> Configurando permisos de ejecución..."
chmod -R 755 $PLUGIN_PATH
chmod 755 $PLUGIN_PATH/plugin.py
chmod 755 $PLUGIN_PATH/server.py
chmod 755 $PLUGIN_PATH/instalar.sh

# 5. Gestión de Dependencias
echo "> Verificando paquetes necesarios..."
opkg update
PACKAGES="ttyd psmisc wget python3-core"
for pkg in $PACKAGES; do
    if opkg list-installed | grep -q $pkg; then
        echo "  [OK] $pkg ya está instalado."
    else
        echo "  [+] Instalando $pkg..."
        opkg install $pkg
    fi
done

# 6. Finalización
echo "---------------------------------------------------------"
echo " INSTALACIÓN EXITOSA"
echo "---------------------------------------------------------"
echo "1. Reinicie Enigma2 (GUI)."
echo "2. Abra el plugin y pulse BOTÓN VERDE para activar."
echo "3. En su móvil, mantenga pulsado para PEGAR comandos."
echo "---------------------------------------------------------"

# Intentar borrar archivos temporales de la carpeta actual si es /tmp
if [ "$PWD" = "/tmp/$PLUGIN_NAME" ]; then
    rm -rf /tmp/$PLUGIN_NAME
fi

exit 0
