from backend import app
import flask
from flask import make_response, render_template, send_from_directory

# This function/route is required to load all the static files from the frontend build.
# Found on some online help forum. 
@app.route('/<path:path>', methods=['GET'])
def static_proxy(path):
    resp = make_response(send_from_directory('../students/build/web', path))
    if ('assets' not in path and 'favicon' not in path): # don't prevent our images or favicon from caching, but prevent other things (namely JS files) from caching
        resp.headers.set('Cache-Control', 'no-store')
    return resp

@app.route("/")
def homepage():
    print(flask.session.get('CAS_USERNAME'))
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store')
    return resp

@app.route("/messages")
def inbox_page():
    print(flask.session.get('CAS_USERNAME'))
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store')
    return resp
