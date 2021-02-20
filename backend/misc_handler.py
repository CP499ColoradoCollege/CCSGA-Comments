import flask
from flask import make_response, jsonify, request
from backend import app
from backend.database_handler import get_conn_and_cursor, confirm_user_in_db

@app.route('/api/authenticate')
def get_user_info():
    
    # Check if signed in at all
    username = flask.session.get('CAS_USERNAME')
    if username == None:
        return make_response(jsonify({'isSignedIn': False, 'username': 'not signed in', 'displayName': 'not signed in', 'isBanned': False, 'isCCSGA': False, 'isAdmin': False}), 200)
    
    # Make sure user is in database
    try:
        display_name = flask.session.get('CAS_ATTRIBUTES')['cas:displayName']
    except KeyError:
        print("Missing key 'cas:displayName' (to be used as full name) for user '%s'." % username)
        print("Using username for full name instead (if needed)")
        display_name = username
    confirm_user_in_db(username, display_name)
    
    # Get other attributes for this user from database
    conn, cur = get_conn_and_cursor()
    cur.execute("SELECT isBanned, isCCSGA, isAdmin from Users where username = ?;", (username,))
    is_banned, is_ccsga, is_admin = cur.fetchone()
    conn.close()

    # Send response with authenticated user info
    return make_response(jsonify({'isSignedIn': True, 'username': username, 'displayName': display_name, 'isBanned': bool(is_banned), 'isCCSGA': bool(is_ccsga), 'isAdmin': bool(is_admin)}), 200)

