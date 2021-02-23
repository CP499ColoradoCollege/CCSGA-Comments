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

class TestAdminRoutes(unittest.TestCase):
    
    def setUp(self):
        self.conn, self.cur = get_conn_and_cursor()
        self.conv_ids_for_cleanup = []
        self.message_ids_for_cleanup = []

    def test_override_anonymity(self):
        
        # Create new conversation
        self.conn, self.cur = get_conn_and_cursor()
        data={"revealIdentity":False,"messageBody":"Initial message in test conversation","labels":[]}
        new_conv_req = requests.post(f"{BASE_API_URL}/conversations/create", verify=False, json=data, headers=POST_HEADERS)
        self.assertEqual(201, new_conv_req.status_code)
        new_conv_id, new_message_id = new_conv_req.json()["conversationId"], new_conv_req.json()["messageId"]
        self.conv_ids_for_cleanup.append(new_conv_id)
        self.message_ids_for_cleanup.append(new_message_id)

        # Change message sender so that the signed-in user can't just automatically view their own info
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        self.cur.execute("INSERT IGNORE INTO Users (username, isBanned, isCCSGA, isAdmin, displayName, rolesLastUpdated) VALUES (?, ?, ?, ?, ?, UTC_TIMESTAMP());", (test_username, 0, 0, 0, test_disp_name))
        # These few lines make sure the user is not an admin and doesn't already have ConversationSettings and MessageSettings for this Conversation and Message
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username=?;", (test_username,))
        self.cur.execute("DELETE from ConversationSettings WHERE username = ? AND conversationId = ?;", (test_username, new_conv_id))
        self.cur.execute("DELETE from MessageSettings WHERE username = ? AND messageId = ?;", (test_username, new_message_id))
        # Now give the signed-in user's objects to the test user
        self.cur.execute("UPDATE ConversationSettings SET username = ? WHERE conversationId = ? AND username = ?;", (test_username, new_conv_id, SIGNED_IN_USERNAME))
        self.cur.execute("UPDATE Messages SET sender = ? WHERE id = ?;", (test_username, new_message_id))
        self.cur.execute("UPDATE MessageSettings SET username = ? WHERE messageId = ? AND username = ?;", (test_username, new_message_id, SIGNED_IN_USERNAME))
        self.conn.commit()
        
        # Give admin privilege 
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.cur.execute("INSERT INTO ConversationSettings (conversationId, username, isArchived, identityRevealed) VALUES (?, ?, ?, ?);", (new_conv_id, SIGNED_IN_USERNAME, 0, 1))
        self.cur.execute("INSERT INTO MessageSettings (messageId, username, isRead) VALUES (?, ?, ?);", (new_message_id, SIGNED_IN_USERNAME, 0))
        self.conn.commit()

        # Test with admin privilege
        deanonymize_req = requests.get(f"{BASE_API_URL}/conversations/{new_conv_id}", verify=False, params={"overrideAnonymity": "true"}, headers=GET_HEADERS)
        self.assertEqual(200, deanonymize_req.status_code)
        conv = deanonymize_req.json()
        self.assertEqual(test_username, conv["messages"][str(new_message_id)]["sender"]["username"])
        self.assertEqual(test_disp_name, conv["messages"][str(new_message_id)]["sender"]["displayName"])

        # Revoke admin privilege, grant CCSGA privilege
        self.cur.execute("UPDATE Users SET isCCSGA = 1, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Test without admin privilege but with CCSGA privilege (so can view the conversation but not de-anonymize it)
        nonadmin_deanonymize_req = requests.get(f"{BASE_API_URL}/conversations/{new_conv_id}", verify=False, params={"overrideAnonymity": "true"}, headers=GET_HEADERS)
        self.assertEqual(200, nonadmin_deanonymize_req.status_code)
        conv = nonadmin_deanonymize_req.json()
        self.assertEqual('anonymous', conv["messages"][str(new_message_id)]["sender"]["username"])
        self.assertEqual('Anonymous', conv["messages"][str(new_message_id)]["sender"]["displayName"])

    def test_add_admin(self):
        
        # Ensure signed-in user is not currently an admin, to check the unauthorized check
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Ensure the admin soon to be added is not currently an admin
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        confirm_user_in_db(test_username, test_disp_name)
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (test_username,))
        self.conn.commit()

        # Make request to add admin but with NO authentication
        req = requests.post(f"{BASE_API_URL}/admins/create", verify=False, json={"newAdmin": test_username})
        self.assertEqual(401, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_admin)

        # Make unauthorized request to add admin (i.e., signed in but not as an admin)
        req = requests.post(f"{BASE_API_URL}/admins/create", verify=False, json={"newAdmin": test_username}, headers=POST_HEADERS)
        self.assertEqual(403, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_admin)

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make authorized request to add admin
        req = requests.post(f"{BASE_API_URL}/admins/create", verify=False, json={"newAdmin": test_username}, headers=POST_HEADERS)
        self.assertEqual(201, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_admin)

        # Make request to add admin again; make sure their already-admin status is indicated in the response status code
        req = requests.post(f"{BASE_API_URL}/admins/create", verify=False, json={"newAdmin": test_username}, headers=POST_HEADERS)
        self.assertEqual(200, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_admin)

    def test_remove_admin(self):
        
        # Ensure signed-in user is not currently an admin, to check the unauthorized check
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Ensure the admin soon to be removed is currently, nominally an admin
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        confirm_user_in_db(test_username, test_disp_name)
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 1 WHERE username = ?;", (test_username,))
        self.conn.commit()

        # Make request to remove admin but with NO authentication
        req = requests.delete(f"{BASE_API_URL}/admins/{test_username}", verify=False)
        self.assertEqual(401, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_admin)

        # Make unauthorized request to remove admin (i.e., signed in but not as an admin)
        req = requests.delete(f"{BASE_API_URL}/admins/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(403, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_admin)

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make authorized request to remove admin
        req = requests.delete(f"{BASE_API_URL}/admins/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(200, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_admin)

        # Make request to remove admin again; make sure their already-non-admin status is indicated in the response status code
        req = requests.delete(f"{BASE_API_URL}/admins/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(404, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isAdmin FROM Users WHERE username = ?;", (test_username,))
        is_admin = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_admin)
    
    def test_add_ccsga(self):
        
        # Ensure signed-in user is not currently an admin, to check the unauthorized check
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Ensure the rep soon to be added is not currently CCSGA
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        confirm_user_in_db(test_username, test_disp_name)
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (test_username,))
        self.conn.commit()

        # Make request to add CCSGA but with NO authentication
        req = requests.post(f"{BASE_API_URL}/ccsga_reps/create", verify=False, json={"newCCSGA": test_username})
        self.assertEqual(401, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_ccsga)

        # Make unauthorized request to add CCSGA (i.e., signed in but not as an admin)
        req = requests.post(f"{BASE_API_URL}/ccsga_reps/create", verify=False, json={"newCCSGA": test_username}, headers=POST_HEADERS)
        self.assertEqual(403, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_ccsga)

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make authorized request to add CCSGA
        req = requests.post(f"{BASE_API_URL}/ccsga_reps/create", verify=False, json={"newCCSGA": test_username}, headers=POST_HEADERS)
        self.assertEqual(201, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_ccsga)

        # Make request to add CCSGA again; make sure their already-CCSGA status is indicated in the response status code
        req = requests.post(f"{BASE_API_URL}/ccsga_reps/create", verify=False, json={"newCCSGA": test_username}, headers=POST_HEADERS)
        self.assertEqual(200, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_ccsga)

    def test_remove_ccsga(self):
        
        # Ensure signed-in user is not currently an admin, to check the unauthorized check
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Ensure the rep soon to be removed is currently, nominally a CCSGA rep
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        confirm_user_in_db(test_username, test_disp_name)
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 1, isAdmin = 0 WHERE username = ?;", (test_username,))
        self.conn.commit()

        # Make request to remove CCSGA but with NO authentication
        req = requests.delete(f"{BASE_API_URL}/ccsga_reps/{test_username}", verify=False)
        self.assertEqual(401, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_ccsga)

        # Make unauthorized request to remove CCSGA (i.e., signed in but not as an admin)
        req = requests.delete(f"{BASE_API_URL}/ccsga_reps/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(403, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_ccsga)

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make authorized request to remove CCSGA
        req = requests.delete(f"{BASE_API_URL}/ccsga_reps/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(200, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_ccsga)

        # Make request to remove CCSGA again; make sure their already-non-CCSGA status is indicated in the response status code
        req = requests.delete(f"{BASE_API_URL}/ccsga_reps/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(404, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isCCSGA FROM Users WHERE username = ?;", (test_username,))
        is_ccsga = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_ccsga)
    
    def test_add_banned(self):
        
        # Ensure signed-in user is not currently an admin, to check the unauthorized check
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Ensure the user soon to be banned is not currently banned
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        confirm_user_in_db(test_username, test_disp_name)
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (test_username,))
        self.conn.commit()

        # Make request to add ban but with NO authentication
        req = requests.post(f"{BASE_API_URL}/banned_users/create", verify=False, json={"userToBan": test_username})
        self.assertEqual(401, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_banned)

        # Make unauthorized request to add ban (i.e., signed in but not as an admin)
        req = requests.post(f"{BASE_API_URL}/banned_users/create", verify=False, json={"userToBan": test_username}, headers=POST_HEADERS)
        self.assertEqual(403, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_banned)

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make authorized request to add ban
        req = requests.post(f"{BASE_API_URL}/banned_users/create", verify=False, json={"userToBan": test_username}, headers=POST_HEADERS)
        self.assertEqual(201, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_banned)

        # Make request to add ban again; make sure their already-banned status is indicated in the response status code
        req = requests.post(f"{BASE_API_URL}/banned_users/create", verify=False, json={"userToBan": test_username}, headers=POST_HEADERS)
        self.assertEqual(200, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_banned)

    def test_remove_banned(self):
        
        # Ensure signed-in user is not currently an admin, to check the unauthorized check
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Ensure the user soon to be unbanned is currently, nominally banned
        test_username, test_disp_name = 'test_user_1', 'Test User 1'
        confirm_user_in_db(test_username, test_disp_name)
        self.cur.execute("UPDATE Users SET isBanned = 1, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (test_username,))
        self.conn.commit()

        # Make request to remove ban but with NO authentication
        req = requests.delete(f"{BASE_API_URL}/banned_users/{test_username}", verify=False)
        self.assertEqual(401, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_banned)

        # Make unauthorized request to remove ban (i.e., signed in but not as an admin)
        req = requests.delete(f"{BASE_API_URL}/banned_users/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(403, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertTrue(is_banned)

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make authorized request to remove ban
        req = requests.delete(f"{BASE_API_URL}/banned_users/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(200, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_banned)

        # Make request to remove ban again; make sure their already-unbanned status is indicated in the response status code
        req = requests.delete(f"{BASE_API_URL}/banned_users/{test_username}", verify=False, headers=DELETE_HEADERS)
        self.assertEqual(404, req.status_code)
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("SELECT isBanned FROM Users WHERE username = ?;", (test_username,))
        is_banned = self.cur.fetchone()[0]
        self.cur.nextset()
        self.assertFalse(is_banned)
    
    def test_get_admins(self):

        # Ensure signed-in user is not currently an admin, to check unauthorized requests
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make request to get admins but with NO authentication
        req = requests.get(f"{BASE_API_URL}/admins", verify=False)
        self.assertEqual(401, req.status_code)
        self.assertEqual(1, len(req.json()))
        self.assertNotIn("admins", req.json().keys())

        # Make unauthorized request to get admins (i.e., signed in but not as an admin)
        req = requests.get(f"{BASE_API_URL}/admins", verify=False, headers=GET_HEADERS)
        self.assertEqual(403, req.status_code)
        self.assertEqual(1, len(req.json()))
        self.assertNotIn("admins", req.json().keys())

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()
        
        # Set up an admin and a non-admin
        admin_username, admin_display_name = "test_user_1", "Test User 1"
        confirm_user_in_db(admin_username, admin_display_name)
        self.cur.callproc("add_admin", (admin_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        self.cur.callproc("remove_ccsga", (admin_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        non_admin_username, non_admin_display_name = "test_user_2", "Test User 2"
        confirm_user_in_db(non_admin_username, non_admin_display_name)
        self.cur.callproc("remove_admin", (non_admin_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        self.conn.commit()

        # Make authorized request to get admins
        req = requests.get(f"{BASE_API_URL}/admins", verify=False, headers=GET_HEADERS)
        self.assertEqual(200, req.status_code)
        self.assertIn({"username": admin_username, "displayName": admin_display_name, "isBanned": False, "isCCSGA": False, "isAdmin": True}, req.json().get("admins"))
        self.assertIn(admin_username, [admin["username"] for admin in req.json().get("admins")])
        self.assertNotIn(non_admin_username, [admin["username"] for admin in req.json().get("admins")])

    def test_get_ccsga(self):

        # Ensure signed-in user is not currently an admin, to check unauthorized requests
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make request to get CCSGA reps but with NO authentication
        req = requests.get(f"{BASE_API_URL}/ccsga_reps", verify=False)
        self.assertEqual(401, req.status_code)
        self.assertEqual(1, len(req.json()))
        self.assertNotIn("ccsgaReps", req.json().keys())

        # Make unauthorized request to get CCSGA reps (i.e., signed in but not as an admin)
        req = requests.get(f"{BASE_API_URL}/ccsga_reps", verify=False, headers=GET_HEADERS)
        self.assertEqual(403, req.status_code)
        self.assertEqual(1, len(req.json()))
        self.assertNotIn("ccsgaReps", req.json().keys())

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()
        
        # Set up a rep and a non-rep
        rep_username, rep_display_name = "test_user_1", "Test User 1"
        confirm_user_in_db(rep_username, rep_display_name)
        self.cur.callproc("remove_admin", (rep_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        self.cur.callproc("add_ccsga", (rep_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        non_rep_username, non_rep_display_name = "test_user_2", "Test User 2"
        confirm_user_in_db(non_rep_username, non_rep_display_name)
        self.cur.callproc("remove_ccsga", (non_rep_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        self.conn.commit()

        # Make authorized request to get CCSGA reps
        req = requests.get(f"{BASE_API_URL}/ccsga_reps", verify=False, headers=GET_HEADERS)
        self.assertEqual(200, req.status_code)
        self.assertIn({"username": rep_username, "displayName": rep_display_name, "isBanned": False, "isCCSGA": True, "isAdmin": False}, req.json().get("ccsgaReps"))
        self.assertIn(rep_username, [rep["username"] for rep in req.json().get("ccsgaReps")])
        self.assertNotIn(non_rep_username, [rep["username"] for rep in req.json().get("ccsgaReps")])

    def test_get_banned(self):

        # Ensure signed-in user is not currently an admin, to check unauthorized requests
        self.conn, self.cur = get_conn_and_cursor()
        confirm_user_in_db(SIGNED_IN_USERNAME, "User Who Signed In For Testing")
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()

        # Make request to get banned users but with NO authentication
        req = requests.get(f"{BASE_API_URL}/banned_users", verify=False)
        self.assertEqual(401, req.status_code)
        self.assertEqual(1, len(req.json()))
        self.assertNotIn("bannedUsers", req.json().keys())

        # Make unauthorized request to get banned users (i.e., signed in but not as an admin)
        req = requests.get(f"{BASE_API_URL}/banned_users", verify=False, headers=GET_HEADERS)
        self.assertEqual(403, req.status_code)
        self.assertEqual(1, len(req.json()))
        self.assertNotIn("bannedUsers", req.json().keys())

        # Give superficial admin privilege (although not actual conversation access) to signed in user
        self.conn, self.cur = get_conn_and_cursor()
        self.cur.execute("UPDATE Users SET isAdmin = 1 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()
        
        # Set up a banned user and a non-banned user
        banned_username, banned_display_name = "test_user_1", "Test User 1"
        confirm_user_in_db(banned_username, banned_display_name)
        self.cur.callproc("add_ban", (banned_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        non_banned_username, non_banned_display_name = "test_user_2", "Test User 2"
        confirm_user_in_db(non_banned_username, non_banned_display_name)
        self.cur.callproc("remove_ban", (non_banned_username, SIGNED_IN_USERNAME))
        self.cur.nextset()
        self.conn.commit()

        # Make authorized request to get banned users
        req = requests.get(f"{BASE_API_URL}/banned_users", verify=False, headers=GET_HEADERS)
        self.assertEqual(200, req.status_code)
        self.assertIn({"username": banned_username, "displayName": banned_display_name, "isBanned": True, "isCCSGA": False, "isAdmin": False}, req.json().get("bannedUsers"))
        self.assertIn(banned_username, [user["username"] for user in req.json().get("bannedUsers")])
        self.assertNotIn(non_banned_username, [user["username"] for user in req.json().get("bannedUsers")])


    def tearDown(self):

        try:
            self.conn.close()
        except e:
            print("Caught in teardown: " + str(e))
            pass
        
        self.conn, self.cur = get_conn_and_cursor()

        for message_id in self.message_ids_for_cleanup:
            self.cur.execute("DELETE FROM MessageSettings WHERE messageId = ?;", (message_id,))
            self.cur.execute("DELETE FROM Messages WHERE id = ?;", (message_id,))
        for conv_id in self.conv_ids_for_cleanup:
            self.cur.execute("DELETE FROM ConversationSettings WHERE conversationId = ?;", (conv_id,))
            self.cur.execute("DELETE FROM Conversations WHERE id = ?;", (conv_id,))
        self.cur.execute("UPDATE Users SET isBanned = 0, isCCSGA = 0, isAdmin = 0 WHERE username = ?;", (SIGNED_IN_USERNAME,))
        self.conn.commit()
        self.message_ids_for_cleanup.clear()
        self.conv_ids_for_cleanup.clear()

        self.conn.close()


if __name__ == "__main__":
    unittest.main()
