import flask
from flask import make_response, jsonify, request
from backend import app
from backend.database_handler import get_conn_and_cursor

@app.route("/api/admins/create", methods=["POST"])
def add_admin():
    '''Add a user to the list of admins.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
    
    # Confirm that the request has the correct content type
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    # Confirm that a username was provided for the new admin
    necessary_keys = ['newAdmin']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    # Get the new admin's username
    new_admin = request_dict['newAdmin']

    # Call the stored procedure for adding an admin
    conn, cur = get_conn_and_cursor()
    cur.callproc('add_admin', (new_admin, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Commit database changes
    conn.commit()
    conn.close()
    
    # Respond appropriately if the stored procedure determined that the new admin was already an admin
    if proc_result == -200:
        return make_response(jsonify({"message": f"'{new_admin}' is already an admin."}), 200)
    
    # proc_result == -201, so respond appropriately for successful admin creation
    return make_response(jsonify({"message": f"Suuccess: '{new_admin}' is now an admin."}), 201)

@app.route("/api/ccsga_reps/create", methods=["POST"])
def add_ccsga_rep():
    '''Add a user to the list of CCSGA representatives.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
    
    # Confirm that the request has the correct content type
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    # Confirm that a username was provided for the new rep
    necessary_keys = ['newCCSGA']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    # Get the new rep's username
    new_ccsga = request_dict['newCCSGA']

    # Call the stored procedure for adding a rep
    conn, cur = get_conn_and_cursor()
    cur.callproc('add_ccsga', (new_ccsga, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Commit database changes
    conn.commit()
    conn.close()
    
    # Respond appropriately if the stored procedure determined that the new rep was already a rep
    if proc_result == -200:
        return make_response(jsonify({"message": f"'{new_ccsga}' is already a CCSGA rep."}), 200)
    
    # proc_result == -201, so respond appropriately for successful rep creation
    return make_response(jsonify({"message": f"Suuccess: '{new_ccsga}' is now a CCSGA rep."}), 201)

@app.route("/api/banned_users/create", methods=["POST"])
def create_banned_user():
    '''Ban a user.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
    
    # Confirm that the request has the correct content type
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    # Confirm that a username was provided for the newly banned user
    necessary_keys = ['userToBan']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    # Get the newly banned user's username
    user_to_ban = request_dict['userToBan']

    # Call the stored procedure for banning a user
    conn, cur = get_conn_and_cursor()
    cur.callproc('add_ban', (user_to_ban, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Commit database changes
    conn.commit()
    conn.close()
    
    # Respond appropriately if the stored procedure determined that the user was already banned
    if proc_result == -200:
        return make_response(jsonify({"message": f"'{user_to_ban}' is already banned."}), 200)
    
    # proc_result == -201, so respond appropriately for successful banning
    return make_response(jsonify({"message": f"Suuccess: '{user_to_ban}' is now banned."}), 201)

@app.route("/api/admins")
def get_admins():
    '''Get the list of admins.'''
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Call the stored procedure for getting the admins
    conn, cur = get_conn_and_cursor()
    cur.callproc('get_admins', (flask.session.get('CAS_USERNAME'),))
    proc_result = cur.fetchall()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == [(-403,)]:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Close the database connection (no changes to commit)
    conn.close()
    
    # proc_result == -200, so respond appropriately with list of admins
    # Map the query result to a list that uses booleans instead of 0/1
    admins = []
    for row in proc_result:
        admins.append({"username": row[0], "displayName": row[1], "isBanned": bool(row[2]), "isCCSGA": bool(row[3]), "isAdmin": bool(row[4])})
    
    # Send the list in a response
    return make_response(jsonify({"admins": admins}), 200)

@app.route("/api/ccsga_reps")
def get_ccsga_reps():
    '''Get the list of CCSGA representatives.'''
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Call the stored procedure for getting the reps
    conn, cur = get_conn_and_cursor()
    cur.callproc('get_ccsga_reps', (flask.session.get('CAS_USERNAME'),))
    proc_result = cur.fetchall()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == [(-403,)]:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Close the database connection (no changes to commit)
    conn.close()
    
    # proc_result == -200, so respond appropriately with list of reps
    # Map the query result to a list that uses booleans instead of 0/1
    reps = []
    for row in proc_result:
        reps.append({"username": row[0], "displayName": row[1], "isBanned": bool(row[2]), "isCCSGA": bool(row[3]), "isAdmin": bool(row[4])})
    
    # Send the list in a response
    return make_response(jsonify({"ccsgaReps": reps}), 200)

@app.route("/api/banned_users")
def get_banned_users():
    '''Get the list of banned users.'''
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Call the stored procedure for getting the banned users
    conn, cur = get_conn_and_cursor()
    cur.callproc('get_banned_users', (flask.session.get('CAS_USERNAME'),))
    proc_result = cur.fetchall()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == [(-403,)]:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Close the database connection (no changes to commit)
    conn.close()
    
    # proc_result == -200, so respond appropriately with list of banned users
    # Map the query result to a list that uses booleans instead of 0/1
    banned_users = []
    for row in proc_result:
        banned_users.append({"username": row[0], "displayName": row[1], "isBanned": bool(row[2]), "isCCSGA": bool(row[3]), "isAdmin": bool(row[4])})
    
    # Send the list in a response
    return make_response(jsonify({"bannedUsers": banned_users}), 200)

@app.route("/api/admins/<admin_to_remove>", methods=["DELETE"])
def remove_admin(admin_to_remove):
    '''Remove a user from the list of admins.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Call the stored procedure for removing an admin
    conn, cur = get_conn_and_cursor()
    cur.callproc('remove_admin', (admin_to_remove, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Respond appropriately if the stored procedure determined that the specified user was the site's only admin (don't want to allow the site to be without admins)
    if proc_result == -400:
        conn.close()
        return make_response(jsonify({"message": f"{admin_to_remove} is currently the only admin. Please add another before removing this one."}), 400)
    
    # Respond appropriately if the stored procedure determined that the specified user was already not an admin
    if proc_result == -404:
        conn.close()
        return make_response(jsonify({"message": f"'{admin_to_remove}' is already not an admin."}), 404)
    
    # Commit database changes
    conn.commit()
    conn.close()
    
    # proc_result == -200, so respond appropriately for successful admin removal
    return make_response(jsonify({"message": f"Success: '{admin_to_remove}' is no longer an admin."}), 200)

@app.route("/api/ccsga_reps/<rep_to_remove>", methods=["DELETE"])
def remove_ccsga_rep(rep_to_remove):
    '''Remove a user from the list of CCSGA representatives.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Call the stored procedure for removing a rep
    conn, cur = get_conn_and_cursor()
    cur.callproc('remove_ccsga', (rep_to_remove, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Respond appropriately if the stored procedure determined that the specified user was already not a rep
    if proc_result == -404:
        conn.close()
        return make_response(jsonify({"message": f"'{rep_to_remove}' is already not a CCSGA rep."}), 404)
    
    # Commit database changes
    conn.commit()
    conn.close()
    
    # proc_result == -200, so respond appropriately for successful rep removal
    return make_response(jsonify({"message": f"Success: '{rep_to_remove}' is no longer a CCSGA rep."}), 200)


@app.route("/api/banned_users/<user_to_unban>", methods=["DELETE"])
def unban_user(user_to_unban):
    '''Unban a user.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Call the stored procedure for unbanning a user
    conn, cur = get_conn_and_cursor()
    cur.callproc('remove_ban', (user_to_unban, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    # Respond appropriately if the stored procedure determined that the requester was not authorized
    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    # Respond appropriately if the stored procedure determined that the specified user was already unbanned
    if proc_result == -404:
        conn.close()
        return make_response(jsonify({"message": f"'{user_to_unban}' is already not banned."}), 404)

    # Commit database changes
    conn.commit()
    conn.close()

    # proc_result == -200, so respond appropriately for successful unbanning
    return make_response(jsonify({"message": f"Suuccess: '{user_to_unban}' is now unbanned."}), 200)



