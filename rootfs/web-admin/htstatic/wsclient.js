window.onload = function() {
    // websocket things
    var wsUrl = "ws://" + window.location.host + "/ws";
    var socket = new WebSocket(wsUrl);

    // elements on page
    var output = document.getElementById('output');
    var append_ssh = document.getElementById('append_ssh');
    var replace_ssh = document.getElementById('replace_ssh');
    var list_zpkg = document.getElementById('list_zpkg');
    var install_zpkg = document.getElementById('install_zpkg');
    var spinner = document.getElementById('spinner');
    var spin = new Spinner({color: '#FFF'});

    socket.onmessage = function (evt) {
        if (evt.data == "<SOF>") {
            output.textContent = "";
        } else if (evt.data == "<EOF>") {
            spin.stop();
        } else {
            output.textContent += evt.data + "\n";
        }
    }

    function runCommand(cmd) {
        spin.spin(spinner);
        socket.send(cmd);
    }

    append_ssh.onclick = function(e) {
        runCommand('append_ssh');
    }
    replace_ssh.onclick = function(e) {
        runCommand('replace_ssh');
    }
    list_zpkg.onclick = function(e) {
        runCommand('list_zpkg');
    }
    install_zpkg.onclick = function(e) {
        runCommand('install_zpkg');
    }
}
