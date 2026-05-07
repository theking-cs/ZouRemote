# -*- coding: utf-8 -*-
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Components.Label import Label
from Components.ActionMap import ActionMap
import socket
import os

# Rutas y Puertos
SERVER_SCRIPT = "/usr/lib/enigma2/python/Plugins/Extensions/ZouRemote/server.py"
WEB_PORT = 1991
TTY_PORT = 1992

class ZouRemoteScreen(Screen):
    skin = """
        <screen name="ZouRemoteScreen" position="center,center" size="720,380" title="ZouRemote v1.1">
            <widget name="title" position="20,20" size="680,45" font="Regular;30" halign="center" />
            <widget name="ip" position="20,100" size="680,35" font="Regular;24"/>
            <widget name="url" position="20,140" size="680,35" font="Regular;24" />
            <widget name="ssh" position="20,180" size="680,35" font="Regular;24" />
            <widget name="status" position="20,260" size="680,60" font="Regular;26" halign="center"/>
            <eLabel text="VERDE: Iniciar | ROJO: Detener | EXIT: Salir" position="20,330" size="680,30" font="Regular;20" halign="center" />
        </screen>
    """

    def __init__(self, session):
        Screen.__init__(self, session)
        self.ip_addr = self.get_ip()
        self["title"] = Label("ZouRemote Control Center")
        self["ip"] = Label("IP Deco: " + self.ip_addr)
        self["url"] = Label("Mando: http://" + self.ip_addr + ":" + str(WEB_PORT))
        self["ssh"] = Label("SSH: http://" + self.ip_addr + ":" + str(TTY_PORT))
        self["status"] = Label("Comprobando estado...")
        self["actions"] = ActionMap(["ColorActions", "OkCancelActions"], {
            "green": self.startAll,
            "red": self.stopAll,
            "cancel": self.close
        }, -1)
        self.onLayoutFinish.append(self.updateStatus)

    def get_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            return s.getsockname()[0]
        except:
            return "127.0.0.1"

    def updateStatus(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1)
        if s.connect_ex(("127.0.0.1", WEB_PORT)) == 0:
            self["status"].setText("ESTADO: ONLINE")
        else:
            self["status"].setText("ESTADO: OFFLINE")
        s.close()

    def startAll(self):
        os.system("python " + SERVER_SCRIPT + " &")
        os.system("ttyd -p %d -W login &" % TTY_PORT)
        self["status"].setText("INICIANDO SERVICIOS...")
        self.updateStatus()

    def stopAll(self):
        os.system("killall -9 ttyd 2>/dev/null")
        os.system("pkill -f " + SERVER_SCRIPT + " 2>/dev/null")
        self["status"].setText("DETENIENDO SERVICIOS...")
        self.updateStatus()

def main(session, **kwargs):
    session.open(ZouRemoteScreen)

def Plugins(**kwargs):
    return [PluginDescriptor(name="ZouRemote", description="Web Remote + SSH", where=[PluginDescriptor.WHERE_PLUGINMENU], fnc=main, icon="plugin.png")]
