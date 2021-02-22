from flask import Flask
from flask_cas import CAS

app = Flask(__name__, template_folder="../students/build/web")
app.config.from_pyfile('config.py')
CAS(app)

import backend.view_handler, backend.messages_handler, backend.admin_handler, backend.misc_handler
