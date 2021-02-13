from flask import Flask
from flask_cas import CAS

app = Flask(__name__, template_folder="../students/build/web")
app.config.from_pyfile('config.py')
CAS(app)

import backend.messages_handler, backend.view_handler
