from flask import Flask

app = Flask(__name__, template_folder="../students/build/web")

import backend.messages_handler, backend.view_handler