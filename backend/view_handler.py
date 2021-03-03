from backend import app
import flask
from flask import make_response, render_template, send_from_directory
from backend.route_wrappers import login_required_with_db_confirm, student_or_admin_required, admin_required

@app.route('/<path:path>', methods=['GET'])
def static_proxy(path):
    '''This function/route is required to load all the static files (besides index.html) from the frontend build. Found on an online help forum.'''

    resp = make_response(send_from_directory('../frontend/build/web', path))
    if ('assets' not in path and 'favicon' not in path): # Don't prevent our images or favicon from caching, but prevent other files (namely JS files) from caching
        resp.headers.set('Cache-Control', 'no-store')
    return resp

@app.route("/")
@login_required_with_db_confirm
def homepage():
    '''Return the index.html page from the Flutter build, since there was a request for the website homepage.'''

    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store') # Avoid caching to make sure our build changes are reflected immediately
    return resp

@app.route("/conversation_list")
@login_required_with_db_confirm
def all_conversations_page():
    '''Return the index.html page from the Flutter build, since there was a request for the page with the list of all the conversations to which this user has access.'''
    
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store') # Avoid caching to make sure our build changes are reflected immediately
    return resp

@app.route("/conversation/<conversation_id>")
@login_required_with_db_confirm
def indiv_conversation_page(conversation_id):
    '''Return the index.html page from the Flutter build, since there was a request for the page for a given, existing conversation to which this user has access.'''
    
    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store') # Avoid caching to make sure our build changes are reflected immediately
    return resp

@app.route("/new_message")
@login_required_with_db_confirm
def new_message_page():
    '''Return the index.html page from the Flutter build, since there was a request for the page for initiating a new conversation.'''

    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store') # Avoid caching to make sure our build changes are reflected immediately
    return resp

@app.route("/admin_controls")
@admin_required
def admin_page():
    '''Return the index.html page from the Flutter build, since there was a request for the admin controls page.'''

    resp = make_response(render_template('index.html'))
    resp.headers.set('Cache-Control', 'no-store') # Avoid caching to make sure our build changes are reflected immediately
    return resp
