import flask
from flask import request, make_response, jsonify, abort
from backend import app
from backend.database_handler import get_conn_and_cursor, confirm_user_in_db

@app.route("/api/conversations/create", methods=["POST"])
def create_conversation():
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['revealIdentity', 'messageBody', 'labels']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    conn, cur = get_conn_and_cursor()

    # Confirm that user is in DB
    username = flask.session.get('CAS_USERNAME')
    try:
        displayName = flask.session.get('CAS_ATTRIBUTES')['cas:displayName']
    except KeyError:
        print("Missing key 'cas:displayName' (to be used as full name) for user '%s'." % username)
        print("Using username for full name instead (if needed)")
        displayName = username
    confirm_user_in_db(username, displayName)
    
    
    cur.callproc("create_conversation", (request_dict["revealIdentity"], flask.session.get('CAS_USERNAME'), 0))
    conversation_id = cur.fetchall()[0][0]
    cur.nextset()

    if conversation_id == -403:
        conn.close()
        return make_response(jsonify({"message": "User is banned and therefore is not authorized to initiate new conversations."}), 403)

    cur.callproc("create_message", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['messageBody'], 0))
    message_id = cur.fetchall()[0][0]
    cur.nextset()

    for label_body in request_dict["labels"]:
        cur.callproc("apply_label", (conversation_id, label_body))
    
    conn.commit()
    conn.close()
    return make_response(jsonify({"conversationId": conversation_id, "messageId": message_id}), 201)

@app.route("/api/conversations/<conversation_id>/messages/create", methods=["POST"])
def create_message(conversation_id):

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
  
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['messageBody']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    conn, cur = get_conn_and_cursor()
    cur.callproc("create_message", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['messageBody'], 0))
    message_id = cur.fetchall()[0][0]
    cur.nextset()
    
    if message_id == -403:
        conn.close()
        return make_response(jsonify({"message": "User is either banned or not authorized to post to this conversation"}), 403)
    
    if message_id == -404:
        conn.close()
        return make_response(jsonify({"message": "Conversation not found"}), 404)

    conn.commit()
    conn.close()
    return make_response(jsonify({"messageId": message_id}), 201)

@app.route("/api/conversations", defaults={'conversation_id': None})
@app.route("/api/conversations/<conversation_id>")
def get_conversations(conversation_id = None):
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()

    if conversation_id == None:
        # Get all conversations to whiich this user has access
        cur.callproc("get_conversation_ids", (flask.session.get('CAS_USERNAME'),))
        conv_ids_to_get = [row[0] for row in cur.fetchall()]
        cur.nextset()
        if conv_ids_to_get == [-403]:
            conn.close()
            return make_response(jsonify({"message": "User is banned"}), 403)
    else:
        # Get only the conversation specified in the URL
        conv_ids_to_get = [conversation_id]

    anonymityOverrideRequested = 1 if request.args.get("overrideAnonymity") == "true" else 0

    conversations = dict()
    for curr_conv_id in conv_ids_to_get:
        cur.callproc("get_conversation", (curr_conv_id, flask.session.get('CAS_USERNAME'), anonymityOverrideRequested))
        messages_query_result = cur.fetchall()
        cur.nextset()

        if messages_query_result == [(-403,)]:
            conn.close()
            return make_response(jsonify({"message": f"User is either banned or not authorized to view conversation #{curr_conv_id}"}), 403)

        if messages_query_result == [(-404,)]:
            conn.close()
            return make_response(jsonify({"message": f"Conversation #{curr_conv_id} not found"}), 404)

        # Handle the messages query
        messages = dict()
        for message_id, sender_username, sender_display_name, message_body, dateandtime, isRead in messages_query_result:
            messages[message_id] = {"sender": {"username": sender_username, "displayName": sender_display_name}, "body": message_body, "dateTime": str(dateandtime), "isRead": bool(isRead)}
        
        # Handle the status query
        status = cur.fetchone()[0]

        # Handle the labels query
        cur.nextset()
        labels = []
        for row in cur.fetchall():
            labels.append(row[0])
        
        # Handle the isArchived query
        cur.nextset()
        isArchived = bool(cur.fetchone()[0])

        # Handle the isArchived query
        cur.nextset()
        allIdentitiesRevealed = bool(cur.fetchone()[0])
        
        # Handle the isArchived query
        cur.nextset()
        allMessagesRead = bool(cur.fetchone()[0])

        cur.nextset()

        conversations[curr_conv_id] = {"messages": messages, "status": status, "labels": labels, "isArchived": isArchived, "studentIdentityRevealed": allIdentitiesRevealed, "isRead": allMessagesRead}

    conn.close()
    return make_response(jsonify(conversations if conversation_id == None else conversations[conversation_id]), 200)


@app.route("/api/conversations/<conversation_id>", methods=["PATCH"])
def update_conversation(conversation_id):

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    conn, cur = get_conn_and_cursor()
    success_messages = []
    
    # Update conversation status, if so requested
    if 'setStatus' in request_dict and request_dict['setStatus'] != None:
        cur.callproc("set_status", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['setStatus']))
        status_query_result = cur.fetchone()[0]
        cur.nextset()

        if status_query_result == -403:
            conn.close()
            return make_response(jsonify({"message": "User is either banned or not authorized to set conversation status"}), 403)

        if status_query_result == -404:
            conn.close()
            return make_response(jsonify({"message": f"Conversation #{conversation_id} not found"}), 404)

        # Successful!
        success_messages.append(f"Successfully set status of conversation #{conversation_id} to '{request_dict['setStatus']}'")
    
    # Update archived/unarchived, if so requested
    if 'setArchived' in request_dict and request_dict['setArchived'] != None:
        cur.callproc("set_archived", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['setArchived']))
        archived_query_result = cur.fetchone()[0]
        cur.nextset()

        if archived_query_result == -403:
            conn.close()
            return make_response(jsonify({"message": f"User is either banned or not involved in conversation #{conversation_id}"}), 403)

        if archived_query_result == -404:
            conn.close()
            return make_response(jsonify({"message": f"Conversation #{conversation_id} not found"}), 404)
        
        # Successful!
        success_messages.append(f"Successfully {'archived' if request_dict['setArchived'] else 'unarchived'} conversation #{conversation_id}")
    
    # Reveal one's own identity, if so requested
    if 'revealIdentity' in request_dict and request_dict['revealIdentity']:
        cur.callproc("reveal_identity", (conversation_id, flask.session.get('CAS_USERNAME')))
        reveal_identity_query_result = cur.fetchone()[0]
        cur.nextset()

        if reveal_identity_query_result == -403:
            conn.close()
            return make_response(jsonify({"message": f"User is either banned or not involved in conversation #{conversation_id}"}), 403)

        if reveal_identity_query_result == -404:
            conn.close()
            return make_response(jsonify({"message": f"Conversation #{conversation_id} not found"}), 404)
        
        # Successful!
        success_messages.append(f"Successfully revealed own identity in conversation #{conversation_id}")

    conn.commit() # Commit down here so that either everything succeeds or nothing does, consistent with the response code/message
    conn.close()
    return make_response(jsonify({"message": ", ".join(success_messages)}), 200)
