# -*- coding: utf-8 -*-
import http.server
import socketserver
import os
import sys
import time

# --- CONFIGURACIÓN ---
PORT = 1991
TTY_PORT = 1992
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(BASE_DIR, "web")

class ZouRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        """ Maneja comandos API y sirve archivos con soporte para PEGAR """
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
                print(f"[ZouRemote] Error API: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            # Servir index.html con inyección de scripts para la consola
            if self.path == "/" or self.path == "/index.html":
                return self.serve_with_paste_support()
            return super().do_GET()

    def serve_with_paste_support(self):
        """ Inyecta scripts necesarios para el manejo de la consola y pegado """
        index_path = os.path.join(WEB_DIR, "index.html")
        if not os.path.exists(index_path):
            return super().do_GET()

        with open(index_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Script para habilitar menú contextual y comunicación con el iframe de ttyd
        paste_script = """
        <script>
            document.addEventListener('contextmenu', function(e) { e.stopPropagation(); return true; }, true);
            document.body.style.userSelect = 'text';
            document.body.style.webkitUserSelect = 'text';

            window.addEventListener('message', function(e) {
                var iframe = document.querySelector('iframe');
                if (e.data.type === 'paste' && iframe) {
                    iframe.contentWindow.postMessage({type: 'input', data: e.data.data}, '*');
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
        """ Envía la pulsación al WebIF local """
        cmd = f"wget -qO - 'http://127.0.0.1:80/web/remotecontrol?command={key}'"
        os.system(cmd)

    def log_message(self, format, *args):
        return # Silenciar logs de consola para no ensuciar

def start_services():
    """ Limpia procesos antiguos y arranca la consola ttyd """
    print(f"[ZouRemote] Limpiando procesos antiguos...")
    os.system("killall -9 ttyd 2>/dev/null")
    
    print(f"[ZouRemote] Iniciando ttyd en puerto {TTY_PORT}...")
    # Usamos la ruta absoluta al binario que acabamos de validar
    # -W permite escribir (importante para pegar texto)
    os.system(f"/usr/bin/ttyd -p {TTY_PORT} -W login &")
    time.sleep(1) # Esperar un segundo para asegurar el arranque

def run_server():
    # Permitir reutilizar el puerto inmediatamente después de cerrar
    socketserver.TCPServer.allow_reuse_address = True
    
    start_services()
    
    try:
        with socketserver.TCPServer(("0.0.0.0", PORT), ZouRequestHandler) as httpd:
            print(f"========================================")
            print(f" ZouRemote Server: http://PUERTO:{PORT}")
            print(f" Terminal SSH:     http://PUERTO:{TTY_PORT}")
            print(f"========================================")
            httpd.serve_forever()
    except Exception as e:
        print(f"[ZouRemote] Error crítico: {e}")
        sys.exit(1)

if __name__ == "__main__":
    run_server()
