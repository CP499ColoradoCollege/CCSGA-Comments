import unittest
import requests
from backend.database_handler import get_conn_and_cursor

# Configure these constants as needed
PORT = 8001
COOKIE = "" # Paste this from network dev tools after signing into CAS in browser
SIGNED_IN_USERNAME = "e_merenstein" # So that the tests know whose roles to update for testing various permission levels

# Don't modify these constants
BASE_API_URL = f"https://localhost:{PORT}/api"
HEADERS = {f"Cookie: {COOKIE}"}

class TestAdminRoutes(unittest.TestCase):
    def test_override_anonymity(self):
        
        # Create new conversation
        new_conv_req = requests.post(f"{BASE_API_URL}/conversations/create", {"revealIdentity":False,"messageBody":"Initial message in test conversation","labels":[]}, headers=HEADERS)
        self.assertEquals(201, new_conv_req.status_code)
        new_conv_id, new_message_id = new_conv_req.json()["conversationId"], new_conv_req.json()["messageId"]

        # Change message sender so that the signed-in user can't just automatically view their own info
        conn, cur = get_conn_and_cursor()
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        cur.execute("REPLACE INTO Users (username, isBanned, isCCSGA, isAdmin, displayName) VALUES (?, ?, ?, ?, ?);", (test_username, 0, 0, 0, test_disp_name))

        # Give admin privilege
        cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        conn.commit()

        # Test with admin privilege
        deanonymize_req = requests.get(f"{BASE_API_URL}/conversations/{new_conv_id}", params={"overrideAnonymity": "true"}, headers=HEADERS)
        self.assertEquals(200, deanonymize_req.status_code)
        conv = deanonymize_req.json()
        self.assertEquals(test_username, conv["messages"][new_message_id]["sender"]["username"])
        self.assertEquals(test_disp_name, conv["messages"][new_message_id]["sender"]["displayName"])

        # Revoke admin privilege
        cur.execute("UPDATE Users SET isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        conn.commit()

        # Test without admin privilege
        nonadmin_deanonymize_req = requests.get(f"{BASE_API_URL}/conversations/{new_conv_id}", params={"overrideAnonymity": "true"}, headers=HEADERS)
        self.assertEquals(200, deanonymize_req.status_code)
        conv = deanonymize_req.json()
        self.assertEquals('anonymous', conv["messages"][new_message_id]["sender"]["username"])
        self.assertEquals('Anonymous', conv["messages"][new_message_id]["sender"]["displayName"])

        # Clean up database
        cur.execute("DELETE FROM MessageSettings WHERE messageId = ?;", (new_message_id,))
        cur.execute("DELETE FROM ConversationSettings WHERE conversationId = ?;", (new_conv_id,))
        cur.execute("DELETE FROM Messages WHERE id = ?;", (new_message_id,))
        cur.execute("DELETE FROM Conversations WHERE id = ?;", (new_conv_id,))
        cur.execute("DELETE FROM Users WHERE username = ?;", (test_username,))


if __name__ == "__main__":
    unittest.main()