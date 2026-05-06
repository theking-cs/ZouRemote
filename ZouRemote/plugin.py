# -*- coding: utf-8 -*-
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Components.Label import Label
from Components.ActionMap import ActionMap
import socket
import os
import sys

# --- CONFIGURACIÓN ---
SERVER_SCRIPT = "/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote/server.py"
WEB_PORT = 1991
TTY_PORT = 1992

class ZouRemoteScreen(Screen):
    skin = """
        <screen name="ZouRemoteScreen" position="center,center" size="720,380" title="ZouRemote Control Center">
            <widget name="title" position="20,20" size="680,45" font="Regular;32" halign="center" foregroundColor="#00ffaa00"/>
            <widget name="ip" position="20,100" size="680,35" font="Regular;24"/>
            <widget name="url" position="20,140" size="680,35" font="Regular;24" foregroundColor="#0000bbff"/>
            <widget name="ssh" position="20,180" size="680,35" font="Regular;24" foregroundColor="#0000ff00"/>
            <widget name="status" position="20,260" size="680,60" font="Regular;26" halign="center"/>
            <eLabel text="VERDE: Iniciar | ROJO: Detener | EXIT: Salir" position="20,330" size="680,30" font="Regular;20" halign="center" />
        </screen>
    """

    def __init__(self, session):
        Screen.__init__(self, session)
        self.ip = get_ip()
        
        self["title"] = Label("ZouRemote + Web SSH")
        self["ip"] = Label("IP Deco: " + self.ip)
        self["url"] = Label("Mando Web: http://" + self.ip + ":" + str(WEB_PORT))
        self["ssh"] = Label("Consola SSH: http://" + self.ip + ":" + str(TTY_PORT))
        self["status"] = Label("Cargando...")

        self["actions"] = ActionMap(
            ["ColorActions", "OkCancelActions"],
            {
                "green": self.startAll,
                "red": self.stopAll,
                "cancel": self.close
            }, -1
        )
        self.updateStatus()

    def updateStatus(self):
        if is_server_running(WEB_PORT):
            self["status"].setText("ESTADO: \c0000FF00ACTIVO\c00FFFFFF\n(Servidores en ejecución)")
        else:
            self["status"].setText("ESTADO: \c00FF0000DETENIDO\c00FFFFFF\n(Pulsa Verde para iniciar)")

    def startAll(self):
        start_services()
        self.updateStatus()

    def stopAll(self):
        stop_services()
        self.updateStatus()

# --- FUNCIONES DE LÓGICA GLOBAL ---

def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def is_server_running(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    result = sock.connect_ex(("127.0.0.1", port))
    sock.close()
    return result == 0

def start_services():
    # 1. Iniciar Servidor Web del Mando
    if not is_server_running(WEB_PORT):
        print("[ZouRemote] Iniciando Web Server...")
        os.system("python " + SERVER_SCRIPT + " &")
    
    # 2. Iniciar ttyd para la Consola SSH
    if not is_server_running(TTY_PORT):
        print("[ZouRemote] Iniciando Consola Web (ttyd)...")
        # EXPLICACIÓN DE CAMBIOS PARA PEGAR:
        # -t enableBracketedPaste=true : Permite que la terminal gestione bloques de texto pegados.
        # -t cursorStyle=block : Mejora la visibilidad del foco.
        os.system("ttyd -p %d -t enableBracketedPaste=true -t cursorStyle=block -W login &" % TTY_PORT)

def stop_services():
    print("[ZouRemote] Deteniendo servicios...")
    # Intentar fuser (requiere psmisc instalado), si no, usamos killall
    os.system("fuser -k %d/tcp 2>/dev/null" % WEB_PORT)
    os.system("fuser -k %d/tcp 2>/dev/null" % TTY_PORT)
    os.system("killall -9 ttyd 2>/dev/null")
    os.system("pkill -f " + SERVER_SCRIPT + " 2>/dev/null")

# --- MODO CONSOLA (CLI) ---

def run_console():
    if len(sys.argv) > 1:
        cmd = sys.argv[1].lower()
        if cmd == "start":
            start_services()
            print("Servicios iniciados.")
        elif cmd == "stop":
            stop_services()
            print("Servicios detenidos.")
        elif cmd == "status":
            w = "ACTIVO" if is_server_running(WEB_PORT) else "OFF"
            t = "ACTIVO" if is_server_running(TTY_PORT) else "OFF"
            print("Mando Web: %s | Consola SSH: %s" % (w, t))
    else:
        print("Uso: python plugin.py [start|stop|status]")

# --- ENIGMA2 PLUGIN ENTRY ---

def main(session, **kwargs):
    session.open(ZouRemoteScreen)

def Plugins(**kwargs):
    return [
        PluginDescriptor(
            name="ZouRemote",
            description="Mando Web + Terminal SSH",
            where=[PluginDescriptor.WHERE_PLUGINMENU, PluginDescriptor.WHERE_EXTENSIONSMENU],
            fnc=main,
            icon="plugin.png"
        )
    ]

if __name__ == "__main__":
    run_console()
