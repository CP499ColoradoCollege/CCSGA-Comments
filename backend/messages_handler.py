from flask import request, make_response, jsonify, abort
from backend import app
from backend.database_handler import get_conn_and_cursor
from datetime import datetime

TEMP_USERNAME = 'temp_username3'
TEMP_DISPLAY_NAME = 'Temp Display Name3'

@app.route("/api/conversations/create", methods=["POST"])
def create_conversation():
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
    # TODO: Labels, AppliedLabels, CCSGA ConversationSettings, CCSGA MessageSettings
    conn.commit()
    return make_response(jsonify({"conversationId": conversation_id, "messageId": message_id}), 201)