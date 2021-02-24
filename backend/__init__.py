from flask import Flask
from flask_cas import CAS

# Instantiate the Flask app
app = Flask(__name__, template_folder="../students/build/web")

# Configure the app to use specified values for CAS, a secret key, database credentials, etc.
app.config.from_pyfile('config.py')

# Add CAS routes and functionality to the app
CAS(app)

# Now, import all of the routes for the app
import backend.view_handler, backend.messages_handler, backend.admin_handler, backend.misc_handler
