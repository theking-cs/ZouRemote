# -*- coding: utf-8 -*-
import http.server
import socketserver
import os
import sys
import subprocess

# --- CONFIGURACIÓN ---
PORT = 1991
TTY_PORT = 1992
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(BASE_DIR, "web")

class ZouRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        """ Maneja comandos API y sirve archivos """
        if self.path.startswith("/api/"):
            try:
                key_code = self.path.split("/")[-1]
                self.enviar_comando_enigma2(key_code)
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b"OK")
            except Exception as e:
                self.send_response(500)
                self.end_headers()
        else:
            if self.path == "/" or self.path == "/index.html":
                return self.serve_with_paste_support()
            return super().do_GET()

    def serve_with_paste_support(self):
        """ Inyecta el script para permitir pegar y manejar el iframe de la consola """
        index_path = os.path.join(WEB_DIR, "index.html")
        if not os.path.exists(index_path):
            return super().do_GET()

        with open(index_path, 'r', encoding='utf-8') as f:
            content = f.read()

        paste_script = """
        <script>
            document.addEventListener('contextmenu', function(e) { e.stopPropagation(); return true; }, true);
            document.body.style.userSelect = 'text';
            document.body.style.webkitUserSelect = 'text';

            document.addEventListener('paste', function(e) {
                var data = (e.clipboardData || window.clipboardData).getData('text');
                var iframe = document.querySelector('iframe');
                if (iframe && data) {
                    iframe.contentWindow.postMessage({type: 'input', data: data}, '*');
                }
            });
        </script>
        """
        new_content = content.replace("</body>", paste_script + "</body>")
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(new_content.encode('utf-8'))

    def enviar_comando_enigma2(self, key):
        cmd = f"wget -qO - 'http://127.0.0.1:80/web/remotecontrol?command={key}'"
        os.system(cmd)

    def log_message(self, format, *args):
        return

def start_ttyd():
    """ Lanza el binario de la consola en el puerto 1992 """
    print(f"[ZouRemote] Intentando arrancar ttyd en puerto {TTY_PORT}...")
    # Matamos procesos previos para evitar conflictos
    os.system("killall -9 ttyd 2>/dev/null")
    # Lanzamos ttyd. El comando asume que el binario está en /usr/bin/ttyd
    # -W permite escribir en la consola (importante para el pegado)
    cmd_ttyd = f"ttyd -p {TTY_PORT} -W login &"
    os.system(cmd_ttyd)

def run_server():
    socketserver.TCPServer.allow_reuse_address = True
    
    # --- LANZAR CONSOLA AL INICIO ---
    start_ttyd()
    
    try:
        with socketserver.TCPServer(("0.0.0.0", PORT), ZouRequestHandler) as httpd:
            print(f"========================================")
            print(f" ZouRemote Server ACTIVO en puerto {PORT}")
            print(f" Consola SSH ACTIVA en puerto {TTY_PORT}")
            print(f"========================================")
            httpd.serve_forever()
    except Exception as e:
        print(f"[ZouRemote] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    run_server()
