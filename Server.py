import http.server
import socketserver
import os
import json
import mimetypes
from urllib.parse import parse_qs, urlparse
import base64

PORT = 8000
UPLOAD_DIR = "uploads"

if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

class LoraTaggerHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        if path == '/' or path == '/index.html':
            self.serve_file('Index.html', 'text/html')
        elif path.startswith('/UI/'):
            file_path = path[1:]
            if os.path.exists(file_path):
                mime_type = mimetypes.guess_type(file_path)[0] or 'text/html'
                self.serve_file(file_path, mime_type)
            else:
                self.send_error(404, "File not found")
        elif path.startswith('/Assets/'):
            file_path = path[1:]
            if os.path.exists(file_path):
                mime_type = mimetypes.guess_type(file_path)[0] or 'application/json'
                self.serve_file(file_path, mime_type)
            else:
                self.send_error(404, "File not found")
        elif path.startswith('/api/strings'):
            module_type = parse_qs(parsed_path.query).get('type', [''])[0]
            self.handle_strings_api(module_type)
        else:
            self.send_error(404, "File not found")

    def do_POST(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        if path == '/api/upload':
            self.handle_upload()
        elif path == '/api/save-tags':
            self.handle_save_tags()
        else:
            self.send_error(404, "API endpoint not found")

    def serve_file(self, file_path, content_type):
        try:
            with open(file_path, 'rb') as f:
                content = f.read()
            self.send_response(200)
            self.send_header('Content-type', content_type)
            self.send_header('Content-Length', len(content))
            self.end_headers()
            self.wfile.write(content)
        except Exception as e:
            self.send_error(500, f"Error reading file: {str(e)}")

    def handle_strings_api(self, module_type):
        if module_type == 'heightmap':
            file_path = 'Assets/Height_Map/Strings.json'
        elif module_type == 'portrait':
            file_path = 'Assets/Portrait/Strings.json'
        else:
            self.send_error(400, "Invalid module type")
            return

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            response = json.dumps(data, ensure_ascii=False).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', len(response))
            self.end_headers()
            self.wfile.write(response)
        except Exception as e:
            self.send_error(500, f"Error reading strings: {str(e)}")

    def handle_upload(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)

        try:
            data = json.loads(post_data.decode('utf-8'))
            filename = data.get('filename', 'unnamed.png')
            file_data = data.get('data', '')

            if file_data.startswith('data:'):
                file_data = file_data.split(',', 1)[1]

            file_bytes = base64.b64decode(file_data)
            safe_filename = os.path.basename(filename)
            file_path = os.path.join(UPLOAD_DIR, safe_filename)

            with open(file_path, 'wb') as f:
                f.write(file_bytes)

            response = {
                'success': True,
                'message': 'File uploaded successfully',
                'path': file_path
            }

            response_data = json.dumps(response).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Content-Length', len(response_data))
            self.end_headers()
            self.wfile.write(response_data)
        except Exception as e:
            error_response = {
                'success': False,
                'message': f'Upload failed: {str(e)}'
            }
            response_data = json.dumps(error_response).encode('utf-8')
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.send_header('Content-Length', len(response_data))
            self.end_headers()
            self.wfile.write(response_data)

    def handle_save_tags(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)

        try:
            data = json.loads(post_data.decode('utf-8'))

            response = {
                'success': True,
                'message': 'Tags saved successfully',
                'data': data
            }

            response_data = json.dumps(response, ensure_ascii=False).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', len(response_data))
            self.end_headers()
            self.wfile.write(response_data)
        except Exception as e:
            error_response = {
                'success': False,
                'message': f'Save failed: {str(e)}'
            }
            response_data = json.dumps(error_response).encode('utf-8')
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.send_header('Content-Length', len(response_data))
            self.end_headers()
            self.wfile.write(response_data)

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), LoraTaggerHandler) as httpd:
        print(f"Server running at http://localhost:{PORT}")
        print(f"Upload directory: {os.path.abspath(UPLOAD_DIR)}")
        print("Press Ctrl+C to stop server")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped")
