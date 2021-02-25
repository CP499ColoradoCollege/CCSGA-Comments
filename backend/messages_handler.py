import flask
import mariadb
from flask import request, make_response, jsonify, abort
from backend import app
from backend.database_handler import get_conn_and_cursor, confirm_user_in_db

@app.route("/api/conversations/create", methods=["POST"])
def create_conversation():
    '''Initiate a new conversation.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Confirm that the request has the correct content type
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    # Confirm that all of the necessary information was provided for initiating a new conversation
    necessary_keys = ['revealIdentity', 'messageBody', 'labels']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)

    # Confirm that user is in DB
    username = flask.session.get('CAS_USERNAME')
    try:
        displayName = flask.session.get('CAS_ATTRIBUTES')['cas:displayName']
    except KeyError:
        print("Missing key 'cas:displayName' (to be used as full name) for user '%s'." % username)
        print("Using username for full name instead (if needed)")
        displayName = username
    confirm_user_in_db(username, displayName)

    # Get database connection and cursor
    conn, cur = get_conn_and_cursor()
    
    try:

        # Call the stored procedure for creating a new Conversations entry and corresponding ConversationSettings entries
        cur.callproc("create_conversation", (request_dict["revealIdentity"], flask.session.get('CAS_USERNAME'), 0))
        conversation_id = cur.fetchall()[0][0]
        cur.nextset()

        # Respond appropriately if the stored procedure determined that the requester was not authorized
        if conversation_id == -403:
            return make_response(jsonify({"message": "User is banned and therefore is not authorized to initiate new conversations."}), 403)

        # Call the stored procedure for creating a new Messages entry and corresponding MessageSettings entries
        cur.callproc("create_message", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['messageBody'], 0))
        message_id = cur.fetchall()[0][0]
        cur.nextset()

        # For each label provided, call the stored procedure for applying a label to a conversation
        for label_body in request_dict["labels"]:
            cur.callproc("apply_label", (conversation_id, label_body))
        
        # Commit database changes and close connection
        conn.commit()
    except mariadb.Error as e:
        print(f"Error when initiating conversation: {e}")
    finally:
        # Close the database connection
        conn.close()

    # Respond with the IDs of the created entries
    return make_response(jsonify({"conversationId": conversation_id, "messageId": message_id}), 201)

@app.route("/api/conversations/<conversation_id>/messages/create", methods=["POST"])
def create_message(conversation_id):
    '''Reply to an existing conversation.'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
  
    # Confirm that the request has the correct content type
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    # Confirm that a message body was provided
    necessary_keys = ['messageBody']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    # Get database connection and cursor
    conn, cur = get_conn_and_cursor()
    
    try:

        # Call the stored procedure for creating a new Messages entry and corresponding MessageSettings entries
        cur.callproc("create_message", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['messageBody'], 0))
        message_id = cur.fetchall()[0][0]
        cur.nextset()
        
        # Respond appropriately if the stored procedure determined that the requester was not authorized
        if message_id == -403:
            return make_response(jsonify({"message": "User is either banned or not authorized to post to this conversation"}), 403)
        
        # Respond appropriately if the stored procedure determined that the specified conversation does not exist
        if message_id == -404:
            return make_response(jsonify({"message": "Conversation not found"}), 404)

        # Commit database changes and close connection
        conn.commit()
    except mariadb.Error as e:
        print(f"Error when saving reply: {e}")
    finally:
        # Close the database connection
        conn.close()

    # Respond with the ID of the new Messages entry
    return make_response(jsonify({"messageId": message_id}), 201)

@app.route("/api/conversations", defaults={'conversation_id': None})
@app.route("/api/conversations/<conversation_id>")
def get_conversations(conversation_id = None):
    '''Get all the conversations to which the signed-in user currently has access (if no conversation_id is given), or get all of the data for a specified conversation (if a conversation_id is given).'''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Get database connection and cursor
    conn, cur = get_conn_and_cursor()

    try:

        # Determine whether this is a request for all of a user's conversations or for a specific conversation
        if conversation_id == None:
            
            # Need to get all conversations to which this user has access
            # Call the stored procedure for getting all such conversation IDs
            cur.callproc("get_conversation_ids", (flask.session.get('CAS_USERNAME'),))
            
            # Map list of 1-tuples to list of integers
            conv_ids_to_get = [row[0] for row in cur.fetchall()]
            
            # Move on from this query
            cur.nextset()

            # Respond appropriately if the stored procedure determined that the requester was not authorized
            if conv_ids_to_get == [-403]:
                return make_response(jsonify({"message": "User is banned"}), 403)
        else:
            
            # Need to get only the conversation specified in the URL
            conv_ids_to_get = [conversation_id]

        # Determine whether or not the user requested to override all anonymity within the requested conversation(s)
        anonymityOverrideRequested = 1 if request.args.get("overrideAnonymity") == "true" else 0

        # Create a dictionary to map conversation ID to conversation data dictionary
        conversations = dict()

        # Loop through list of conversation IDs and add the appropriate key/value (ID/data) pairs to the dictionary
        for curr_conv_id in conv_ids_to_get:
            
            # Call the stored procedure for getting data about a conversation
            cur.callproc("get_conversation", (curr_conv_id, flask.session.get('CAS_USERNAME'), anonymityOverrideRequested))
            messages_query_result = cur.fetchall()
            cur.nextset()

            # Respond appropriately if the stored procedure determined that the requester was not authorized
            if messages_query_result == [(-403,)]:
                return make_response(jsonify({"message": f"User is either banned or not authorized to view conversation #{curr_conv_id}"}), 403)

            # Respond appropriately if the stored procedure determined that a requested conversation does not exist
            if messages_query_result == [(-404,)]:
                return make_response(jsonify({"message": f"Conversation #{curr_conv_id} not found"}), 404)

            # Handle the messages query; create a dictionary comprising the messages data
            messages = dict()
            for message_id, sender_username, sender_display_name, message_body, dateandtime, isRead in messages_query_result:
                messages[message_id] = {"sender": {"username": sender_username, "displayName": sender_display_name}, "body": message_body, "dateTime": str(dateandtime), "isRead": bool(isRead)}
            
            # Handle the status query; store status as a string
            status = cur.fetchone()[0]

            # Handle the labels query; store them in a list of strings
            cur.nextset()
            labels = []
            for row in cur.fetchall():
                labels.append(row[0])
            
            # Handle the isArchived query; store result in a boolean
            cur.nextset()
            isArchived = bool(cur.fetchone()[0])

            # Handle the all identities revealed query; store result in a boolean
            cur.nextset()
            allIdentitiesRevealed = bool(cur.fetchone()[0])
            
            # Handle the all messages read query; store result in a boolean
            cur.nextset()
            allMessagesRead = bool(cur.fetchone()[0])

            # Move on from the final query
            cur.nextset()

            # Add this key/value (conversation id/conversation data) pair to the conversations dict
            conversations[curr_conv_id] = {"messages": messages, "status": status, "labels": labels, "isArchived": isArchived, "studentIdentityRevealed": allIdentitiesRevealed, "isRead": allMessagesRead}
    except mariadb.Error as e:
        print(f"Error when getting conversation data: {e}")
    finally:
        # Close the database connection
        conn.close()

    # Respond with the conversations dict if the user requested all of their conversations;
    # respond with just the data for the desired conversation if the user requested only a specific conversation
    return make_response(jsonify(conversations if conversation_id == None else conversations[conversation_id]), 200)


@app.route("/api/conversations/<conversation_id>", methods=["PATCH"])
def update_conversation(conversation_id):
    '''Make changes to the state of a conversation. This includes: 
     - Updating the conversation status (CCSGA- or admin-restricted)
     - Revealing one's own identity within the conversation
     - Archiving the conversation

    All of the JSON properties in the request body are optional; each one will cause an attempt to update the conversation state in the corresponding fashion as long as none of the previous attempts encountered errors.
    '''

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    # Confirm that the request has the correct content type
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    # Get the connection and cursor
    conn, cur = get_conn_and_cursor()
    
    try: 

        # Create a list to store all of the messages that will be included in the response if everything succeeds
        success_messages = []
        
        # Update conversation status, if so requested
        if 'setStatus' in request_dict and request_dict['setStatus'] != None:
            
            # Call the stored proecdure for setting the status of a conversation
            cur.callproc("set_status", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['setStatus']))
            status_query_result = cur.fetchone()[0]
            cur.nextset()

            # Respond appropriately if the stored procedure determined that the requester was not authorized
            if status_query_result == -403:
                return make_response(jsonify({"message": "User is either banned or not authorized to set conversation status"}), 403)

            # Respond appropriately if the stored procedure determined that the specified conversation does not exist
            if status_query_result == -404:
                return make_response(jsonify({"message": f"Conversation #{conversation_id} not found"}), 404)

            # Successful! Add the appropriate success message to the list of success messages
            success_messages.append(f"Successfully set status of conversation #{conversation_id} to '{request_dict['setStatus']}'")
        
        # Update archived/unarchived, if so requested
        if 'setArchived' in request_dict and request_dict['setArchived'] != None:
            
            # Call the stored proecdure for setting the archived or unarchived state of a conversation
            cur.callproc("set_archived", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['setArchived']))
            archived_query_result = cur.fetchone()[0]
            cur.nextset()

            # Respond appropriately if the stored procedure determined that the requester was not authorized
            if archived_query_result == -403:
                return make_response(jsonify({"message": f"User is either banned or not involved in conversation #{conversation_id}"}), 403)

            # Respond appropriately if the stored procedure determined that the specified conversation does not exist
            if archived_query_result == -404:
                return make_response(jsonify({"message": f"Conversation #{conversation_id} not found"}), 404)
            
            # Successful! Add the appropriate success message to the list of success messages
            success_messages.append(f"Successfully {'archived' if request_dict['setArchived'] else 'unarchived'} conversation #{conversation_id}")
        
        # Reveal one's own identity, if so requested
        if 'revealIdentity' in request_dict and request_dict['revealIdentity']:
            
            # Call the stored proecdure for revealing one's own identity within a conversation
            cur.callproc("reveal_identity", (conversation_id, flask.session.get('CAS_USERNAME')))
            reveal_identity_query_result = cur.fetchone()[0]
            cur.nextset()

            # Respond appropriately if the stored procedure determined that the requester was not authorized
            if reveal_identity_query_result == -403:
                return make_response(jsonify({"message": f"User is either banned or not involved in conversation #{conversation_id}"}), 403)

            # Respond appropriately if the stored procedure determined that the specified conversation does not exist
            if reveal_identity_query_result == -404:
                return make_response(jsonify({"message": f"Conversation #{conversation_id} not found"}), 404)
            
            # Successful! Add the appropriate success message to the list of success messages
            success_messages.append(f"Successfully revealed own identity (or confirmed that identity was already revealed) in conversation #{conversation_id}")

        # Commit database changes down here only so that either everything succeeds or nothing does, consistent with the response code/message
        if len(success_messages):
            conn.commit()
    except mariadb.Error as e:
        print(f"Error when modifying conversation: {e}")
    finally:
        # Close the database connection
        conn.close()

    # Send a response with all of the accrued success messages
    return make_response(jsonify({"message": ", ".join(success_messages)}), 200)
