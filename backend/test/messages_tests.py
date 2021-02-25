# NOTE: In order to run these tests, make sure you've provided the necessary values in backend/.env

import sys
import os
sys.path.append('..')
import unittest
import requests
from dotenv import load_dotenv
try:
    from database_handler import get_conn_and_cursor, confirm_user_in_db
except ModuleNotFoundError:
    print("Make sure you're actually in the test directory when you run this program.")
    exit(1)

load_dotenv()

PORT = os.getenv("TESTING_PORT")
COOKIE = os.getenv("TESTING_COOKIE")
SIGNED_IN_USERNAME = os.getenv("TESTING_USERNAME")
BASE_API_URL = f"https://localhost:{PORT}/api"
GET_HEADERS = {"Cookie": COOKIE}
POST_HEADERS = {"Cookie": COOKIE, "Content-Type": "application/json"}
DELETE_HEADERS = {"Cookie": COOKIE}
FAKE_ADMIN_USERNAME = 'fake_admin'
FAKE_ADMIN_DISPLAY_NAME = 'Fake Admin'

class TestMessagesRoutes(unittest.TestCase):

    def setUp(self):
        self.conn, self.cur = get_conn_and_cursor()
        self.conv_ids_for_cleanup = []
        self.message_ids_for_cleanup = []
        
        # Create fake admin for changing roles (for safety because of the way it's removed at the end, don't let the fake admin send any messages)
        self.cur.execute("INSERT IGNORE INTO Users (username, displayName, isBanned, isCCSGA, isAdmin) VALUES (?, ?, 0, 0, 1);", (FAKE_ADMIN_USERNAME, FAKE_ADMIN_DISPLAY_NAME))
        self.conn.commit()
    
    def test_create_conversation(self):
        
        # Make signed-in user nominally banned, to check the unauthorized check
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.callproc("add_ban", (SIGNED_IN_USERNAME, FAKE_ADMIN_USERNAME))
        self.cur.nextset()
        self.conn.commit()

        # Get info about current data in database
        self.cur.execute("SELECT COUNT(*) FROM Conversations;")
        orig_num_convs = self.cur.fetchone()[0]
        self.cur.nextset()
        self.cur.execute("SELECT COUNT(*) FROM Messages;")
        orig_num_messages = self.cur.fetchone()[0]
        self.cur.nextset()
        self.cur.execute("SELECT COUNT(*) FROM ConversationSettings;")
        orig_num_conv_settings = self.cur.fetchone()[0]
        self.cur.nextset()
        self.cur.execute("SELECT COUNT(*) FROM MessageSettings;")
        orig_num_message_settings = self.cur.fetchone()[0]
        self.cur.nextset()
        self.cur.execute("SELECT COUNT(*) FROM AppliedLabels;")
        orig_num_applied_labels = self.cur.fetchone()[0]
        self.cur.nextset()
        self.cur.execute("SELECT COUNT(*) FROM Users WHERE isCCSGA OR isAdmin;")
        orig_num_ccsga_or_admin = self.cur.fetchone()[0]
        self.cur.nextset()

        # Make request to create conversation but with NO authentication
        labels = ["Outreach", "Internal Affairs"]
        req = requests.post(f"{BASE_API_URL}/conversations/create", verify=False, json={"revealIdentity": False, "messageBody": "Unauthenticated message", "labels": labels})
        self.assertEqual(401, req.status_code)
        self.cur.execute("SELECT COUNT(*) FROM Conversations;")
        num_convs = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_convs, num_convs)

        # Make unauthorized request to create conversation (i.e., signed in but as a banned user)
        req = requests.post(f"{BASE_API_URL}/conversations/create", verify=False, headers=POST_HEADERS, json={"revealIdentity": False, "messageBody": "Unauthorized message", "labels": labels})
        self.assertEqual(403, req.status_code)
        self.cur.execute("SELECT COUNT(*) FROM Conversations;")
        num_convs = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_convs, num_convs)

        # Nominally unban user
        self.cur.callproc("remove_ban", (SIGNED_IN_USERNAME, FAKE_ADMIN_USERNAME))
        self.cur.nextset()
        self.conn.commit()

        # Make authorized request to create anonymous conversation
        messageBody = "Test message"
        req = requests.post(f"{BASE_API_URL}/conversations/create", verify=False, headers=POST_HEADERS, json={"revealIdentity": False, "messageBody": messageBody, "labels": labels})

        # Get new ids and note them for tearDown
        new_conv_id = req.json()["conversationId"]
        new_message_id = req.json()["messageId"]
        self.conv_ids_for_cleanup.append(new_conv_id)
        self.message_ids_for_cleanup.append(new_message_id)
        
        self.assertEqual(201, req.status_code)
        
        # Check that conversation was added
        self.cur.execute("SELECT COUNT(*) FROM Conversations;")
        num_convs = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_convs + 1, num_convs)

        # Check that message was added correctly
        self.cur.execute("SELECT COUNT(*) FROM Messages;")
        num_messages = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_messages + 1, num_messages)
        self.cur.execute("SELECT sender, body FROM Messages ORDER BY id DESC LIMIT 1;")
        query_result = self.cur.fetchall()
        self.cur.nextset()
        self.assertEqual([(SIGNED_IN_USERNAME, messageBody)], query_result)

        # Check that conversation settings were added correctly
        self.cur.execute("SELECT COUNT(*) FROM ConversationSettings;")
        num_conv_settings = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_conv_settings + orig_num_ccsga_or_admin + 1, num_conv_settings)
        self.cur.execute("SELECT isArchived, identityRevealed, isInitiator, isAccessible FROM ConversationSettings WHERE username = ? AND conversationId = ?;", (SIGNED_IN_USERNAME, new_conv_id))
        query_result = self.cur.fetchall()
        self.cur.nextset()
        self.assertEqual([(0, 0, 1, 1)], query_result)
        self.cur.execute("SELECT isArchived, identityRevealed, isInitiator, isAccessible FROM ConversationSettings WHERE username <> ? AND conversationId = ?;", (SIGNED_IN_USERNAME, new_conv_id))
        query_result = self.cur.fetchall()
        self.cur.nextset()
        for row in query_result:
            self.assertEqual((0, 1, 0, 1), row)

        # Check that message settings were added correctly
        self.cur.execute("SELECT COUNT(*) FROM MessageSettings;")
        num_message_settings = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_message_settings + orig_num_ccsga_or_admin + 1, num_message_settings)
        self.cur.execute("SELECT isRead FROM MessageSettings WHERE username = ? AND messageId = ?;", (SIGNED_IN_USERNAME, new_message_id))
        query_result = self.cur.fetchall()
        self.cur.nextset()
        self.assertEqual([(1,)], query_result)
        self.cur.execute("SELECT isRead FROM MessageSettings WHERE username <> ? AND messageId = ?;", (SIGNED_IN_USERNAME, new_message_id))
        query_result = self.cur.fetchall()
        self.cur.nextset()
        for row in query_result:
            self.assertEqual((0,), row)

        # Check that labels were applied correctly
        self.cur.execute("SELECT COUNT(*) FROM AppliedLabels;")
        num_applied_labels = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertEqual(orig_num_applied_labels + len(labels), num_applied_labels)
        self.cur.execute("SELECT body FROM Labels JOIN AppliedLabels ON Labels.id = labelId WHERE conversationId = ?;", (new_conv_id,))
        query_result = self.cur.fetchall()
        self.cur.nextset()
        for row in query_result:
            self.assertIn(row[0], labels)
        self.assertEqual(len(query_result), len(labels))

        # Make authorized request to create non-anonymous conversation
        messageBody = "Test message 2"
        non_anon_req = requests.post(f"{BASE_API_URL}/conversations/create", verify=False, headers=POST_HEADERS, json={"revealIdentity": True, "messageBody": messageBody, "labels": labels})

        # Get new ids and note them for tearDown
        second_new_conv_id = non_anon_req.json()["conversationId"]
        second_new_message_id = non_anon_req.json()["messageId"]
        self.conv_ids_for_cleanup.append(second_new_conv_id)
        self.message_ids_for_cleanup.append(second_new_message_id)
        
        self.assertEqual(201, non_anon_req.status_code)
        # Check that non-anonymous initiator conversation setting was added correctly
        self.conn.close() # For some reason the test fails if the cursor isn't closed here
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isArchived, identityRevealed, isInitiator, isAccessible FROM ConversationSettings WHERE username = ? AND conversationId = ?;", (SIGNED_IN_USERNAME, second_new_conv_id))
        non_anon_query_result = self.cur.fetchall()
        self.cur.nextset()
        self.assertEqual([(0, 1, 1, 1)], non_anon_query_result)



    def tearDown(self):

        # Delete any messages, conversations, etc. created
        for message_id in self.message_ids_for_cleanup:
            self.cur.execute("DELETE FROM MessageSettings WHERE messageId = ?;", (message_id,))
            self.cur.execute("DELETE FROM Messages WHERE id = ?;", (message_id,))
        for conv_id in self.conv_ids_for_cleanup:
            self.cur.execute("DELETE FROM AppliedLabels WHERE conversationId = ?;", (conv_id,))
            self.cur.execute("DELETE FROM ConversationSettings WHERE conversationId = ?;", (conv_id,))
            self.cur.execute("DELETE FROM Conversations WHERE id = ?;", (conv_id,))
        
        # Reset the permissions and updated metadata (for the sake of fake admin removal) of the signed-in user to normal student
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = NULL WHERE username = ?;", (SIGNED_IN_USERNAME,))
        
        # Delete the fake admin who was used for role assignment (these commands are only safe under the assumption that THE fake admin didn't send any messages)
        self.cur.execute("DELETE FROM ConversationSettings WHERE username = ?;", (FAKE_ADMIN_USERNAME,))
        self.cur.execute("DELETE FROM MessageSettings WHERE username = ?;", (FAKE_ADMIN_USERNAME,))
        self.cur.execute("DELETE FROM Users WHERE username = ?;", (FAKE_ADMIN_USERNAME,))
        
        # Commit, clear lists of IDs to delete, and close connection
        self.conn.commit()
        self.message_ids_for_cleanup.clear()
        self.conv_ids_for_cleanup.clear()
        self.conn.close()


if __name__ == "__main__":
    unittest.main()

