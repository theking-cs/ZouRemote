#!/bin/sh

# Crear el script de arranque original directamente en /etc/init.d/zouremote
cat << 'EOF' > /etc/init.d/zouremote
#!/bin/sh
### BEGIN INIT INFO
# Provides:          zouremote
# Required-Start:    $networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Arranca los servidores de ZouRemote directamente
### END INIT INFO

# RUTAS Y PUERTOS
SERVER_SCRIPT="/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote/server.py"
WEB_PORT=1991
TTY_PORT=1992

case "$1" in
    start)
        echo "Iniciando servicios de ZouRemote..."
        
        # 1. Arrancar Servidor del Mando Web (Python)
        if ! fuser "$WEB_PORT/tcp" >/dev/null 2>&1; then
            python "$SERVER_SCRIPT" &
            echo "Mando Web iniciado en puerto $WEB_PORT"
        else
            echo "Mando Web ya estaba corriendo."
        fi
        
        # 2. Arrancar Terminal SSH Web (ttyd)
        if ! fuser "$TTY_PORT/tcp" >/dev/null 2>&1; then
            ttyd -p $TTY_PORT -W login &
            echo "Consola Web iniciada en puerto $TTY_PORT"
        else
            echo "Consola Web ya estaba corriendo."
        fi
        ;;
        
    stop)
        echo "Deteniendo servicios de ZouRemote..."
        fuser -k "$WEB_PORT/tcp" >/dev/null 2>&1
        fuser -k "$TTY_PORT/tcp" >/dev/null 2>&1
        killall -9 ttyd >/dev/null 2>&1
        echo "Servicios detenidos."
        ;;
        
    status)
        # Comprobar si los puertos estÃ¡n abiertos
        if fuser "$WEB_PORT/tcp" >/dev/null 2>&1; then W_STAT="ACTIVO"; else W_STAT="OFF"; fi
        if fuser "$TTY_PORT/tcp" >/dev/null 2>&1; then T_STAT="ACTIVO"; else T_STAT="OFF"; fi
        echo "Mando Web: $W_STAT | Consola SSH: $T_STAT"
        ;;
        
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
        
    *)
        echo "Uso: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

exit 0
EOF

# Asignar permisos y registrar en el arranque del sistema
chmod +x /etc/init.d/zouremote
update-rc.d zouremote defaults

# Iniciar el servicio inmediatamente
/etc/init.d/zouremote start

echo "¡Script original instalado y activado en /etc/init.d/zouremote!"
exit 0
