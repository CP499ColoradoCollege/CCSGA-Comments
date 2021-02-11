from flask import request, make_response, jsonify, abort
from backend import app
from backend.database_handler import get_conn_and_cursor
from datetime import datetime

TEMP_USERNAME = 'temp_username1'
TEMP_DISPLAY_NAME = 'Temp Display Name1'

@app.route("/api/conversations/create", methods=["POST"])
def create_conversation():
    # TODO: prevent non-signed in users from accessing
    
    request_dict = request.get_json()
    
    necessary_keys = ['revealIdentity', 'messageBody', 'labels']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    conn, cur = get_conn_and_cursor()
    cur.execute("INSERT IGNORE INTO Users (username, isBanned, isCCSGA, isAdmin, displayName) VALUES (?, 0, 0, 0, ?);", (TEMP_USERNAME, TEMP_DISPLAY_NAME))
    cur.callproc("create_conversation", (request_dict["revealIdentity"], TEMP_USERNAME, 0))
    conversation_id = cur.fetchall()[0][0]
    if conversation_id == -1:
        abort(403, "CCSGA reps may not create new conversations")
    cur.callproc("create_message", (conversation_id, TEMP_USERNAME, request_dict['messageBody'], 0))
    message_id = cur.fetchall()[0][0]
    cur.nextset()

    for label_body in request_dict["labels"]:
        cur.callproc("apply_label", (conversation_id, label_body))
    # TODO: CCSGA ConversationSettings, CCSGA MessageSettings
    # TODO: HTTP errors
    conn.commit()
    return make_response(jsonify({"conversationId": conversation_id, "messageId": message_id}), 201)

@app.route("/api/conversations/<conversation_id>/messages/create", methods=["POST"])
def create_message(conversation_id):
    request_dict = request.get_json()
    
    necessary_keys = ['messageBody']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    # TODO: handle user not being in the database?
    # TODO: 404/3/1 errors

    conn, cur = get_conn_and_cursor()
    cur.callproc("create_message", (conversation_id, TEMP_USERNAME, request_dict['messageBody'], 0))
    message_id = cur.fetchall()[0][0]
    if message_id == -1:
        abort(403, "User is not authorized to post to this conversation")
    
    cur.nextset()
    conn.commit()
    return make_response(jsonify({"messageId": message_id}), 201)


@app.route("/api/conversations/<conversation_id>", methods=["GET"])
def get_conversation(conversation_id):
    conn, cur = get_conn_and_cursor()
    cur.callproc("get_conversation", (conversation_id, TEMP_USERNAME))
    results = cur.fetchall()

    # TODO: 404, etc.
    # TODO: handle user not being in database?
    # TODO: return the complete json object planned in the API

    if results == [(None,)]:
        abort(403, "User is not authorized to view this conversation")

    messages = dict()
    for message_id, sender_username, sender_display_name, message_body, dateandtime, isRead in results:
        messages[message_id] = {"sender": {"username": sender_username, "displayName": sender_display_name}, "body": message_body, "dateTime": dateandtime, "isRead": (True if isRead else False)}
    return make_response(jsonify(messages), 200)

