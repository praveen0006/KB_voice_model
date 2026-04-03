"""HTTP server that sends no-cache headers to prevent browser from using stale JS."""
import http.server
import sys
import os

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8686
    directory = sys.argv[2] if len(sys.argv) > 2 else '.'
    os.chdir(directory)
    
    # Use ThreadingHTTPServer to prevent Chrome keep-alive sockets from stalling the page load
    server = http.server.ThreadingHTTPServer(('', port), NoCacheHTTPRequestHandler)
    print(f'Serving on port {port} (NO CACHE) from {os.getcwd()}')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\nShutting down.')
