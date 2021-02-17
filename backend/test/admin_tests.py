import sys
sys.path.append('..')
import unittest
import requests
from database_handler import get_conn_and_cursor, confirm_user_in_db

# Configure these constants as needed
PORT = 8001
COOKIE = "" # Paste this from network dev tools after signing into CAS in browser
SIGNED_IN_USERNAME = "e_merenstein" # So that the tests know whose roles to update for testing various permission levels

# Don't modify these constants
BASE_API_URL = f"https://localhost:{PORT}/api"
GET_HEADERS = {"Cookie": COOKIE}
POST_HEADERS = {"Cookie": COOKIE, "Content-Type": "application/json"}

class TestAdminRoutes(unittest.TestCase):
    
    def setUp(self):
        self.conv_ids_for_cleanup = []
        self.message_ids_for_cleanup = []


    def test_override_anonymity(self):
        
        # Create new conversation
        data={"revealIdentity":False,"messageBody":"Initial message in test conversation","labels":[]}
        new_conv_req = requests.post(f"{BASE_API_URL}/conversations/create", verify=False, json=data, headers=POST_HEADERS)
        self.assertEqual(201, new_conv_req.status_code)
        new_conv_id, new_message_id = new_conv_req.json()["conversationId"], new_conv_req.json()["messageId"]
        self.conv_ids_for_cleanup.append(new_conv_id)
        self.message_ids_for_cleanup.append(new_message_id)

        # Change message sender so that the signed-in user can't just automatically view their own info
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        conn, cur = get_conn_and_cursor()
        cur.execute("INSERT IGNORE INTO Users (username, isBanned, isCCSGA, isAdmin, displayName) VALUES (?, ?, ?, ?, ?);", (test_username, 0, 0, 0, test_disp_name))
        cur.execute("UPDATE ConversationSettings SET username = ? WHERE conversationId = ? AND username = ?;", (test_username, new_conv_id, SIGNED_IN_USERNAME))
        cur.execute("UPDATE Messages SET sender = ? WHERE id = ?;", (test_username, new_message_id))
        cur.execute("UPDATE MessageSettings SET username = ? WHERE messageId = ? AND username = ?;", (test_username, new_message_id, SIGNED_IN_USERNAME))
        conn.commit()
        
        # Give admin privilege 
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        cur.execute("UPDATE Users SET isCCSGA = 0, isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        cur.execute("INSERT INTO ConversationSettings (conversationId, username, isArchived, identityRevealed) VALUES (?, ?, ?, ?);", (new_conv_id, SIGNED_IN_USERNAME, 0, 1))
        cur.execute("INSERT INTO MessageSettings (messageId, username, isRead) VALUES (?, ?, ?);", (new_message_id, SIGNED_IN_USERNAME, 0))
        conn.commit()

        # Test with admin privilege
        deanonymize_req = requests.get(f"{BASE_API_URL}/conversations/{new_conv_id}", verify=False, params={"overrideAnonymity": "true"}, headers=GET_HEADERS)
        self.assertEqual(200, deanonymize_req.status_code)
        conv = deanonymize_req.json()
        self.assertEqual(test_username, conv["messages"][str(new_message_id)]["sender"]["username"])
        self.assertEqual(test_disp_name, conv["messages"][str(new_message_id)]["sender"]["displayName"])

        # Revoke admin privilege, grant CCSGA privilege
        cur.execute("UPDATE Users SET isCCSGA = 1, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        conn.commit()

        # Test without admin privilege but with CCSGA privilege (so can view the conversation but not de-anonymize it)
        nonadmin_deanonymize_req = requests.get(f"{BASE_API_URL}/conversations/{new_conv_id}", verify=False, params={"overrideAnonymity": "true"}, headers=GET_HEADERS)
        self.assertEqual(200, nonadmin_deanonymize_req.status_code)
        conv = nonadmin_deanonymize_req.json()
        self.assertEqual('anonymous', conv["messages"][str(new_message_id)]["sender"]["username"])
        self.assertEqual('Anonymous', conv["messages"][str(new_message_id)]["sender"]["displayName"])

        conn.close()
        
    def tearDown(self):
        conn, cur = get_conn_and_cursor()

        for message_id in self.message_ids_for_cleanup:
            cur.execute("DELETE FROM MessageSettings WHERE messageId = ?;", (message_id,))
            cur.execute("DELETE FROM Messages WHERE id = ?;", (message_id,))
        for conv_id in self.conv_ids_for_cleanup:
            cur.execute("DELETE FROM ConversationSettings WHERE conversationId = ?;", (conv_id,))
            cur.execute("DELETE FROM Conversations WHERE id = ?;", (conv_id,))
        cur.execute("UPDATE Users SET isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        conn.commit()
        self.message_ids_for_cleanup.clear()
        self.conv_ids_for_cleanup.clear()

        conn.close()


if __name__ == "__main__":
    unittest.main()
