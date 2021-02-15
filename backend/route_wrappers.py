from functools import wraps
import flask
from flask import abort
from flask_cas import login_required
from backend.database_handler import is_student, is_ccsga, is_admin

# can be used as a function decorator to require that a user be signed in *as a student* in order to access a route
def student_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_student(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required(wrap)

# can be used as a function decorator to require that a user be signed in *as a CCSGA rep* in order to access a route
def ccsga_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_ccsga(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required(wrap)

# can be used as a function decorator to require that a user be signed in *as an admin* in order to access a route
def admin_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required(wrap)

# can be used as a function decorator to require that a user be signed in *as either a student or an admin* in order to access a route
def student_or_admin_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_student(flask.session.get('CAS_USERNAME')) or is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required(wrap)

# can be used as a function decorator to require that a user be signed in *as either a CCSGA rep or an admin* in order to access a route
def ccsga_or_admin_required(function):
    @wraps(function)
    def wrap(*args, **kwargs):
        if is_ccsga(flask.session.get('CAS_USERNAME')) or is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    return login_required(wrap)
