from backend import app
import flask
from flask import make_response, render_template, send_from_directory
from backend.route_wrappers import login_required_with_db_confirm, student_or_admin_required

# This function/route is required to load all the static files from the frontend build.
# Found on some online help forum. 
@app.route('/<path:path>', methods=['GET'])
def static_proxy(path):
    resp = make_response(send_from_directory('../students/build/web', path))
    if ('assets' not in path and 'favicon' not in path): # don't prevent our images or favicon from caching, but prevent other things (namely JS files) from caching
        resp.headers.set('Cache-Control', 'no-store')
    return resp

# Route for the homepage of the website
@app.route("/")
def homepage():
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store')
    return resp

# Route for the list of all the conversations to which this user has access, if no conversation_id is provided
# Route for a given, existing conversation to which this user has access, if its conversation_id is provided
@app.route("/conversations", defaults={'conversation_id': None})
@app.route("/conversations/<conversation_id>")
@login_required_with_db_confirm
def conversation_pages(conversation_id = None):
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store')
    return resp

# Route for initiating a new conversation
@app.route("/new_message")
@student_or_admin_required
def new_message_page():
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store')
    return resp
