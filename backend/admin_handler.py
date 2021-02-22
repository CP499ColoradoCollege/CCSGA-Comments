import flask
from flask import make_response, jsonify, request
from backend import app
from backend.database_handler import get_conn_and_cursor

@app.route("/api/admins/create", methods=["POST"])
def add_admin():

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
    
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['newAdmin']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    new_admin = request_dict['newAdmin']

    conn, cur = get_conn_and_cursor()
    cur.callproc('add_admin', (new_admin, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    conn.commit()
    conn.close()
    
    if proc_result == -200:
        return make_response(jsonify({"message": f"'{new_admin}' is already an admin."}), 200)
    
    # proc_result == -201:
    return make_response(jsonify({"message": f"Suuccess: '{new_admin}' is now an admin."}), 201)

@app.route("/api/ccsga_reps/create", methods=["POST"])
def add_ccsga_rep():

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
    
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['newCCSGA']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    new_ccsga = request_dict['newCCSGA']

    conn, cur = get_conn_and_cursor()
    cur.callproc('add_ccsga', (new_ccsga, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    conn.commit()
    conn.close()
    
    if proc_result == -200:
        return make_response(jsonify({"message": f"'{new_ccsga}' is already a CCSGA rep."}), 200)
    
    # proc_result == -201:
    return make_response(jsonify({"message": f"Suuccess: '{new_ccsga}' is now a CCSGA rep."}), 201)

@app.route("/api/banned_users/create", methods=["POST"])
def create_banned_user():

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
    
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['userToBan']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    user_to_ban = request_dict['userToBan']

    conn, cur = get_conn_and_cursor()
    cur.callproc('add_ban', (user_to_ban, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    conn.commit()
    conn.close()
    
    if proc_result == -200:
        return make_response(jsonify({"message": f"'{user_to_ban}' is already banned."}), 200)
    
    # proc_result == -201:
    return make_response(jsonify({"message": f"Suuccess: '{user_to_ban}' is now banned."}), 201)

@app.route("/api/admins")
def get_admins():
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc('get_admins', (flask.session.get('CAS_USERNAME'),))
    proc_result = cur.fetchall()

    if proc_result == [(-403,)]:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    conn.close()
    
    # proc_result == -200:
    admins = []
    for row in proc_result:
        admins.append({"username": row[0], "displayName": row[1], "isBanned": bool(row[2]), "isCCSGA": bool(row[3]), "isAdmin": bool(row[4])})
    return make_response(jsonify({"admins": admins}), 200)

@app.route("/api/ccsga_reps")
def get_ccsga_reps():
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc('get_ccsga_reps', (flask.session.get('CAS_USERNAME'),))
    proc_result = cur.fetchall()

    if proc_result == [(-403,)]:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    conn.close()
    
    # proc_result == -200:
    reps = []
    for row in proc_result:
        reps.append({"username": row[0], "displayName": row[1], "isBanned": bool(row[2]), "isCCSGA": bool(row[3]), "isAdmin": bool(row[4])})
    return make_response(jsonify({"ccsgaReps": reps}), 200)

@app.route("/api/banned_users")
def get_banned_users():
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc('get_banned_users', (flask.session.get('CAS_USERNAME'),))
    proc_result = cur.fetchall()

    if proc_result == [(-403,)]:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    conn.close()
    
    # proc_result == -200:
    banned_users = []
    for row in proc_result:
        banned_users.append({"username": row[0], "displayName": row[1], "isBanned": bool(row[2]), "isCCSGA": bool(row[3]), "isAdmin": bool(row[4])})
    return make_response(jsonify({"bannedUsers": banned_users}), 200)

@app.route("/api/admins/<admin_to_remove>", methods=["DELETE"])
def remove_admin(admin_to_remove):

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc('remove_admin', (admin_to_remove, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    if proc_result == -400:
        conn.close()
        return make_response(jsonify({"message": f"{admin_to_remove} is currently the only admin. Please add another before removing this one."}), 400)
    
    if proc_result == -404:
        conn.close()
        return make_response(jsonify({"message": f"'{admin_to_remove}' is already not an admin."}), 404)
    
    conn.commit()
    conn.close()
    
    # proc_result == -200:
    return make_response(jsonify({"message": f"Success: '{admin_to_remove}' is no longer an admin."}), 200)

@app.route("/api/ccsga_reps/<rep_to_remove>", methods=["DELETE"])
def remove_ccsga_rep(rep_to_remove):

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc('remove_ccsga', (rep_to_remove, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    if proc_result == -404:
        conn.close()
        return make_response(jsonify({"message": f"'{rep_to_remove}' is already not a CCSGA rep."}), 404)
    
    conn.commit()
    conn.close()
    
    # proc_result == -200:
    return make_response(jsonify({"message": f"Success: '{rep_to_remove}' is no longer a CCSGA rep."}), 200)


@app.route("/api/banned_users/<user_to_unban>", methods=["DELETE"])
def unban_user(user_to_unban):

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc('remove_ban', (user_to_unban, flask.session.get('CAS_USERNAME')))
    proc_result = cur.fetchone()[0]
    cur.nextset()

    if proc_result == -403:
        conn.close()
        return make_response(jsonify({"message": "User is not an admin, so this request is not allowed."}), 403)
    
    if proc_result == -404:
        conn.close()
        return make_response(jsonify({"message": f"'{user_to_unban}' is already not banned."}), 404)

    conn.commit()
    conn.close()

    # proc_result == -200:
    return make_response(jsonify({"message": f"Suuccess: '{user_to_unban}' is now unbanned."}), 200)



