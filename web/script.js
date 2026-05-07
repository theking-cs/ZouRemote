const OPENWEBIF_IP = window.location.hostname;
const OPENWEBIF_PORT = 80;

function sendCommand(key) {
    fetch(`http://${OPENWEBIF_IP}:${OPENWEBIF_PORT}/api/v1/remotecontrol?command=${key}`)
        .then(response => console.log("Comando enviado:", key))
        .catch(err => console.error("Error:", err));
}