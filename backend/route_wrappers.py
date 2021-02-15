from functools import wraps
import flask
from flask import abort
from flask_cas import login_required
from backend.database_handler import confirm_user_in_db, is_student, is_ccsga, is_admin

# Same as flask_cas.login_required, but also makes sure there's a Users entry for this user in the DB. This should generally be used instead off flask_cas.login_required.
def login_required_with_db_confirm(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        username = flask.session.get('CAS_USERNAME')
        try:
            displayName = flask.session.get('CAS_ATTRIBUTES')['cas:displayName']
        except KeyError:
            print("Missing key 'cas:displayName' (to be used as full name) for user '%s'." % username)
            print("Using username for full name instead (if needed)")
            displayName = username
        confirm_user_in_db(username, displayName)
        return function(*args, **kwargs)
    return login_required(wrap)

# Can be used as a function decorator to require that a user be signed in *as a student* in order to access a route
def student_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_student(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required_with_db_confirm(wrap)

# Can be used as a function decorator to require that a user be signed in *as a CCSGA rep* in order to access a route
def ccsga_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_ccsga(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required_with_db_confirm(wrap)

# Can be used as a function decorator to require that a user be signed in *as an admin* in order to access a route
def admin_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required_with_db_confirm(wrap)

# Can be used as a function decorator to require that a user be signed in *as either a student or an admin* in order to access a route
def student_or_admin_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_student(flask.session.get('CAS_USERNAME')) or is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required_with_db_confirm(wrap)

# Can be used as a function decorator to require that a user be signed in *as either a CCSGA rep or an admin* in order to access a route
def ccsga_or_admin_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_ccsga(flask.session.get('CAS_USERNAME')) or is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required_with_db_confirm(wrap)
