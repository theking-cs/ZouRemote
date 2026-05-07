# -*- coding: utf-8 -*-
import http.server
import socketserver
import os
import sys

# --- CONFIGURACIÓN ---
PORT = 1991
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
                print(f"[ZouRemote] Error: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            # Si se pide el index o la raíz, inyectamos el script de pegado
            if self.path == "/" or self.path == "/index.html":
                return self.serve_with_paste_support()
            return super().do_GET()

    def serve_with_paste_support(self):
        """ Lee el index.html e inyecta el código para permitir pegar con toque largo """
        index_path = os.path.join(WEB_DIR, "index.html")
        if not os.path.exists(index_path):
            return super().do_GET()

        with open(index_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Script mágico para habilitar el pegado y el menú contextual en móviles
        paste_script = """
        <script>
            // Habilitar menú contextual (toque largo)
            document.addEventListener('contextmenu', function(e) { 
                e.stopPropagation(); 
                return true; 
            }, true);

            // Forzar que los inputs y el body permitan selección
            document.addEventListener('DOMContentLoaded', function() {
                document.body.style.userSelect = 'text';
                document.body.style.webkitUserSelect = 'text';
            });

            // Escuchar el evento de pegar y enviarlo si hay un iframe de ttyd
            document.addEventListener('paste', function(e) {
                var data = (e.clipboardData || window.clipboardData).getData('text');
                var iframe = document.querySelector('iframe');
                if (iframe && data) {
                    iframe.contentWindow.postMessage({type: 'input', data: data}, '*');
                }
            });
        </script>
        """
        # Insertar el script antes del cierre del body
        new_content = content.replace("</body>", paste_script + "</body>")
        
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(new_content.encode('utf-8'))

    def enviar_comando_enigma2(self, key):
        """ Envía el comando al WebIF local """
        print(f"[ZouRemote] Enviando Key: {key}")
        # Usamos 127.0.0.1:80 para asegurar que llegue al WebIF interno
        cmd = f"wget -qO - 'http://127.0.0.1:80/web/remotecontrol?command={key}'"
        os.system(cmd)

    def log_message(self, format, *args):
        return

def run_server():
    socketserver.TCPServer.allow_reuse_address = True
    try:
        with socketserver.TCPServer(("0.0.0.0", PORT), ZouRequestHandler) as httpd:
            print(f"========================================")
            print(f" ZouRemote Server ACTIVO en puerto {PORT}")
            print(f" Soporte para PEGAR: Habilitado")
            print(f"========================================")
            httpd.serve_forever()
    except Exception as e:
        print(f"[ZouRemote] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    run_server()
