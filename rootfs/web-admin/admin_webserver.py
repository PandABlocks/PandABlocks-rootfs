#!/usr/bin/env python

import os
import mimetypes
import sys
import time

from ws4py.websocket import WebSocket
from ws4py.manager import WebSocketManager
from ws4py.server.wsgiutils import WebSocketWSGIApplication
from wsgiref.simple_server import WSGIServer as _WSGIServer
from ws4py.compat import get_connection

# This disables hop-by-hop headers
from wsgiref import util
util._hoppish = {}.__contains__


# Number of bytes to send in each block
BLOCK_SIZE = 4096


class WSGIServer(_WSGIServer):

    def shutdown_request(self, request):
        """
        The base class would close our socket
        if we didn't override it.
        """
        pass

    def server_close(self):
        """
        Properly initiate closing handshakes on
        all websockets when the WSGI server terminates.
        """
        print "closing sockets"
        _WSGIServer.server_close(self)


class EchoWebSocket(WebSocket):
    commands = ["append_ssh", "replace_ssh", "list_zpkg", "install_zpkg"]

    def received_message(self, message):
        """Do one of the commands"""
        message = str(message)
        self.send("<SOF>")
        if message in self.commands:
            self.send("Process started")
            time.sleep(2)
            getattr(self, message)()
        else:
            self.send("Unrecognized command %s" % message)
        self.send("<EOF>")

    def append_ssh(self):
        self.send("SSH key file appended")

    def replace_ssh(self):
        self.send("SSH key file replaced")

    def list_zpkg(self):
        self.send("a.zpkg\nb.zpkg")

    def install_zpkg(self):
        self.send("packages installed")


class FileServer(object):
    """ Serves static files from a directory.
    """

    def __init__(self, path):
        """ path is directory where static files are stored
        """
        self.path = path
        self.wsapp = WebSocketWSGIApplication(handler_cls=EchoWebSocket)
        self.manager = WebSocketManager()
        self.manager.start()

    def __call__(self, environ, start_response):
        """ WSGI entry point
        """
        # Upgrade header means websockets...
        upgrade_header = environ.get('HTTP_UPGRADE', '').lower()
        if upgrade_header:
            environ['ws4py.socket'] = get_connection(environ['wsgi.input'])
            # This will make a websocket, hopefully!
            ret = self.wsapp(environ, start_response)
            if 'ws4py.websocket' in environ:
                self.manager.add(environ.pop('ws4py.websocket'))
            return ret

        # Find path to file to server
        path_info = environ["PATH_INFO"]

        if not path_info or path_info == "/":
            path_info = "/index.html"

        file_path = os.path.join(self.path, path_info[1:])

        # If file does not exist, return 404
        if not os.path.exists(file_path):
            return self._not_found(start_response)

        # Guess mimetype of file based on file extension
        mimetype = mimetypes.guess_type(file_path)[0]

        # If we can't guess mimetype, return a 403 Forbidden
        if mimetype is None:
            return self._forbidden(start_response)

        # Get size of file
        size = os.path.getsize(file_path)

        # Create headers and start response
        headers = [
            ("Content-type", mimetype),
            ("Content-length", str(size)),
        ]

        start_response("200 OK", headers)

        # Send file
        return self._send_file(file_path, size)

    def _send_file(self, file_path, size):
        """ A generator function which returns the blocks in a file, one at
        a time.

        """
        with open(file_path) as f:
            block = f.read(BLOCK_SIZE)
            while block:
                yield block
                block = f.read(BLOCK_SIZE)

    def _not_found(self, start_response):
        start_response("404 NOT FOUND", [("Content-type", "text/plain")])
        return ["Not found", ]

    def _forbidden(self, start_response):
        start_response("403 FORBIDDEN", [("Content-type", "text/plain")])
        return ["Forbidden", ]


if __name__ == '__main__':
    from wsgiref.simple_server import make_server
    application = FileServer(
        os.path.join(os.path.dirname(__file__), "htstatic"))
    server = make_server('0.0.0.0', 8081, application, server_class=WSGIServer)
    server.serve_forever()
