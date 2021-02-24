from functools import wraps
import flask
from flask import abort
from flask_cas import login_required
from backend.database_handler import confirm_user_in_db, is_student, is_ccsga, is_admin

def login_required_with_db_confirm(function):
    '''Same as flask_cas.login_required, but also make sure there's a Users entry for this user in the DB. As a rule, this should be used instead off flask_cas.login_required.'''

    @wraps(function)
    def wrap(*args, **kwargs):
        
        # Get username
        username = flask.session.get('CAS_USERNAME')
        
        # Get display name, if one is provided
        try:
            displayName = flask.session.get('CAS_ATTRIBUTES')['cas:displayName']
        except KeyError:
            print("Missing key 'cas:displayName' (to be used as full name) for user '%s'." % username)
            print("Using username for full name instead (if needed)")
            displayName = username
        
        # Confirm user is in database
        confirm_user_in_db(username, displayName)
        
        # Proceed to the wrapped function
        return function(*args, **kwargs)

    # Wrap this function with flask_cas.login_required, to require first that the User logs in
    return login_required(wrap)

def student_required(function):
    '''Can be used as a function decorator to require that a user be signed in *as a student* in order to access a route.'''

    @wraps(function)
    def wrap(*args, **kwargs):

        # Proceed to wrapped function if user is a student; respond with a 403 error otherwise
        if is_student(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    
    # Wrap this function with login_required_with_db_confirm, to require first that the User logs in and is in the database
    return login_required_with_db_confirm(wrap)

def ccsga_required(function):
    '''Can be used as a function decorator to require that a user be signed in *as a CCSGA representative* in order to access a route.'''

    @wraps(function)
    def wrap(*args, **kwargs):

        # Proceed to wrapped function if user is a rep; respond with a 403 error otherwise
        if is_ccsga(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    
    # Wrap this function with login_required_with_db_confirm, to require first that the User logs in and is in the database
    return login_required_with_db_confirm(wrap)

def admin_required(function):
    '''Can be used as a function decorator to require that a user be signed in *as an admin* in order to access a route.'''

    @wraps(function)
    def wrap(*args, **kwargs):

        # Proceed to wrapped function if user is an admin; respond with a 403 error otherwise
        if is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    
    # Wrap this function with login_required_with_db_confirm, to require first that the User logs in and is in the database
    return login_required_with_db_confirm(wrap)

def student_or_admin_required(function):
    '''Can be used as a function decorator to require that a user be signed in *as either a student or an admin* in order to access a route.'''

    @wraps(function)
    def wrap(*args, **kwargs):

        # Proceed to wrapped function if user is a student or an admin; respond with a 403 error otherwise
        if is_student(flask.session.get('CAS_USERNAME')) or is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    
    # Wrap this function with login_required_with_db_confirm, to require first that the User logs in and is in the database
    return login_required_with_db_confirm(wrap)

def ccsga_or_admin_required(function):
    '''Can be used as a function decorator to require that a user be signed in *as either a CCSGA representative or an admin* in order to access a route.'''

    @wraps(function)
    def wrap(*args, **kwargs):

        # Proceed to wrapped function if user is a rep or an admin; respond with a 403 error otherwise
        if is_ccsga(flask.session.get('CAS_USERNAME')) or is_admin(flask.session.get('CAS_USERNAME')):
            return function(*args, **kwargs)
        else:
            abort(403)
    
    # Wrap this function with login_required_with_db_confirm, to require first that the User logs in and is in the database
    return login_required_with_db_confirm(wrap)
