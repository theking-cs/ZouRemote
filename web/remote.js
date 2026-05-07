/* remote.js - Optimizado para ZouRemote PWA */

/**
 * Envía el código de la tecla al servidor Python local (Puerto 1991)
 * @param {number} key - Código de la tecla Enigma2
 */
function sendCommand(key) {
    // Usamos la ruta relativa /api/ que gestiona server.py
    fetch(`/api/${key}`)
        .then(response => {
            if (!response.ok) throw new Error('Error en el servidor');
            console.log("Comando ejecutado con éxito:", key);
        })
        .catch(err => {
            console.error("Fallo al conectar con el servidor ZouRemote:", err);
        });
}

/* Mapeo de IDs del HTML a códigos de mando Enigma2 */
const keyMap = {
    'POWER': 116,
    'RED': 398,
    'GREEN': 399,
    'YELLOW': 400,
    'BLUE': 401,
    'UP': 103,
    'DOWN': 108,
    'LEFT': 105,
    'RIGHT': 106,
    'OK': 352,
    'VOL+': 115,
    'VOL-': 114,
    'CH+': 402,
    'CH-': 403,
    'MENU': 139,
    'EXIT': 174,
    'INFO': 358,
    'EPG': 365
};

document.addEventListener("DOMContentLoaded", () => {
    // Seleccionamos solo los botones que están dentro de la zona del mando
    // Esto evita interferir con el botón de SSH que tiene su propia lógica
    const buttons = document.querySelectorAll('.remote button');

    buttons.forEach(btn => {
        // Detectamos si el dispositivo es táctil para usar 'touchstart' (más rápido)
        const eventType = 'ontouchstart' in window ? 'touchstart' : 'click';

        btn.addEventListener(eventType, (e) => {
            // Si es táctil, prevenimos el comportamiento por defecto para evitar zoom/scroll
            if (e.type === 'touchstart') e.preventDefault(); 
            
            const id = btn.id;
            if (keyMap[id]) {
                sendCommand(keyMap[id]);
                
                // Feedback visual: pequeño parpadeo al pulsar
                btn.style.opacity = "0.5";
                setTimeout(() => btn.style.opacity = "1", 100);
            }
        });
    });

    console.log("Lógica de ZouRemote cargada correctamente.");
});
