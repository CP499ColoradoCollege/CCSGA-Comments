import mariadb
import os
from dotenv import load_dotenv
from datetime import datetime
import re

load_dotenv()

def get_new_db_connection():
    '''Connect to the database using the values specified in the environment. 
    Implemented as a function so that it can be called easily in other places when it's discovered that the connection was lost/ended.
    However, outside of this file, it is preferrable to call get_conn_and_cursor() instead.'''
    try:
        return mariadb.connect(
            user=os.getenv("DB_USERNAME"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("DB_IP"),
            database=os.getenv("DB_DBNAME"),
            autocommit=False
        )
    except mariadb.Error as e:
        print(f"Error connecting to MariaDB Platform: {e}")

conn = get_new_db_connection()

def get_conn_and_cursor():
    '''Gets the current MariaDB connection and a cursor from it, automatically re-establishing the connection if needed to do so.
    This is the function that should generally be imported and called in other files.'''
    global conn
    try:
        cur = conn.cursor()
    except mariadb.ProgrammingError: # i.e., conn is not open
        conn = get_new_db_connection()
        print(f"Reconnected to database at {datetime.utcnow()} UTC")
        cur = conn.cursor()
    return conn, cur

def create_tables():
    '''Creates all the tables for the database that don't already exist, but doesn't update their structures if the details below have changed.'''
    conn, cur = get_conn_and_cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS Users (username VARCHAR(40), displayName VARCHAR(100), isBanned BOOL, isCCSGA BOOL, isAdmin BOOL, rolesLastUpdated DATETIME, updatedBy VARCHAR(40), PRIMARY KEY (username), FOREIGN KEY (updatedBy) REFERENCES Users(username));")
    cur.execute("CREATE TABLE IF NOT EXISTS Conversations (id INT AUTO_INCREMENT, status VARCHAR(40), PRIMARY KEY (id));")
    cur.execute("CREATE TABLE IF NOT EXISTS Messages (id INT AUTO_INCREMENT, conversationId INT, sender VARCHAR(40), body TEXT, dateandtime DATETIME, PRIMARY KEY (id), FOREIGN KEY (conversationId) REFERENCES Conversations(id), FOREIGN KEY (sender) REFERENCES Users(username));")
    cur.execute("CREATE TABLE IF NOT EXISTS Labels (id INT AUTO_INCREMENT, body VARCHAR(40), PRIMARY KEY (id), UNIQUE (body));")
    cur.execute("CREATE TABLE IF NOT EXISTS ConversationSettings (id INT AUTO_INCREMENT, conversationId INT, username VARCHAR(40), isArchived BOOL, identityRevealed BOOL, isInitiator BOOL, isAccessible BOOL DEFAULT 1, PRIMARY KEY (id), FOREIGN KEY (conversationId) REFERENCES Conversations(id), FOREIGN KEY (username) REFERENCES Users(username), UNIQUE KEY convIdAndUsername (conversationId, username));")
    cur.execute("CREATE TABLE IF NOT EXISTS MessageSettings (id INT AUTO_INCREMENT, messageId INT, username VARCHAR(40), isRead BOOL, PRIMARY KEY (id), FOREIGN KEY (messageId) REFERENCES Messages(id), FOREIGN KEY (username) REFERENCES Users(username), UNIQUE KEY messageIdAndUsername (messageId, username));")
    cur.execute("CREATE TABLE IF NOT EXISTS AppliedLabels (id INT AUTO_INCREMENT, conversationId INT, labelId INT, PRIMARY KEY (id), FOREIGN KEY (conversationId) REFERENCES Conversations(id), FOREIGN KEY (labelId) REFERENCES Labels(id));")
    cur.execute("CREATE TABLE IF NOT EXISTS Links (id INT AUTO_INCREMENT, icon TEXT, body TEXT, url TEXT, dateandtime DATETIME, PRIMARY KEY (id));")
    cur.execute("CREATE TABLE IF NOT EXISTS Announcements (id INT AUTO_INCREMENT, icon TEXT, body TEXT, dateandtime DATETIME, PRIMARY KEY (id));")
    conn.close()

def create_stored_procedures():
    '''Creates all the stored procedures for the database. Doesn't modify those that currently exist.'''
    messages_commands = [
        '''CREATE PROCEDURE create_conversation (IN revealIdentity BOOL, IN sender VARCHAR(40), OUT conversationId INT)
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE ((isCCSGA AND NOT isAdmin) OR isBanned) AND username=sender) THEN
                    SET conversationId = -403;
                ELSE
                    INSERT INTO Conversations (status) VALUES ('Delivered');
                    SELECT LAST_INSERT_ID() INTO conversationId;
                    INSERT INTO ConversationSettings (conversationId, username, isArchived, identityRevealed, isInitiator, isAccessible) VALUES (conversationId, sender, 0, revealIdentity, 1, 1);
                    INSERT IGNORE INTO ConversationSettings (conversationId, username, isArchived, identityRevealed, isInitiator, isAccessible) SELECT conversationId, Users.username, 0, 1, 0, 1 FROM Users WHERE isCCSGA OR isAdmin;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE create_message (IN conversationIdInput INT, IN sender VARCHAR(40), IN messageBody TEXT, OUT newMessageId INT)
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=sender AND isBanned) THEN
                    SET newMessageId = -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = conversationIdInput) THEN
                    SET newMessageId = -404;
                ELSEIF EXISTS (SELECT username FROM ConversationSettings WHERE username = sender AND conversationId = conversationIdInput AND isAccessible) THEN
                    INSERT INTO Messages (conversationId, sender, body, dateandtime) VALUES (conversationIdInput, sender, messageBody, UTC_TIMESTAMP());
                    SELECT LAST_INSERT_ID() INTO newMessageId;
                    INSERT INTO MessageSettings (messageId, username, isRead) SELECT newMessageId, ConversationSettings.username, 0 FROM ConversationSettings WHERE ConversationSettings.conversationId = conversationIdInput AND isAccessible;
                    UPDATE MessageSettings SET isRead = 1 WHERE username = sender AND messageId = newMessageId;
                ELSE
                    SET newMessageId = -403;
                END IF;
                
            END ;
        ''',
        '''CREATE PROCEDURE apply_label (IN conversationId INT, IN labelBody VARCHAR(40))
            BEGIN
                DECLARE labelId INT;
                IF EXISTS (SELECT id FROM Labels WHERE body = labelBody) THEN
                    SELECT id INTO labelId FROM Labels WHERE body = labelBody;
                ELSE
                    INSERT INTO Labels (body) VALUES (labelBody);
                    SELECT LAST_INSERT_ID() INTO labelId;
                END IF;
                INSERT INTO AppliedLabels (conversationId, labelId) VALUES (conversationId, labelId);
            END ;
        ''',
        '''CREATE PROCEDURE get_conversation_ids (IN requester VARCHAR(40))
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=requester AND isBanned) THEN
                    SELECT -403;
                ELSE
                    SELECT conversationId FROM ConversationSettings WHERE username = requester AND isAccessible;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE get_conversation (IN requestedConversationId INT, IN requester VARCHAR(40), IN anonymityOverrideRequested BOOL)
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=requester AND isBanned) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = requestedConversationId) THEN
                    SELECT -404;
                ELSEIF EXISTS (SELECT username FROM ConversationSettings WHERE username = requester AND conversationId = requestedConversationId AND isAccessible) THEN
                    IF anonymityOverrideRequested AND EXISTS (SELECT username FROM Users WHERE username=requester AND isAdmin) THEN
                        SELECT Messages.id, Users.username, Users.displayName, Messages.body, Messages.dateandtime, MessageSettings.isRead FROM ((Messages JOIN Users ON Messages.sender = Users.username) JOIN MessageSettings ON requester = MessageSettings.username AND Messages.id = MessageSettings.messageId) WHERE Messages.conversationId = requestedConversationId;
                    ELSE
                        SELECT Messages.id, Users.username, Users.displayName, Messages.body, Messages.dateandtime, MessageSettings.isRead FROM (((Messages JOIN Users ON Messages.sender = Users.username) JOIN MessageSettings ON requester = MessageSettings.username AND Messages.id = MessageSettings.messageId) JOIN ConversationSettings ON ConversationSettings.username = Messages.sender AND ConversationSettings.conversationId = requestedConversationId) WHERE Messages.conversationId = requestedConversationId AND (ConversationSettings.identityRevealed OR Messages.sender = requester)
                        UNION SELECT Messages.id, "anonymous", "Anonymous", Messages.body, Messages.dateandtime, MessageSettings.isRead FROM ((Messages JOIN MessageSettings ON requester = MessageSettings.username AND Messages.id = MessageSettings.messageId) JOIN ConversationSettings ON ConversationSettings.username = Messages.sender AND ConversationSettings.conversationId = requestedConversationId) WHERE Messages.conversationId = requestedConversationId AND NOT (ConversationSettings.identityRevealed OR Messages.sender = requester);
                    END IF;
                
                    SELECT status FROM Conversations WHERE id = requestedConversationId;
                    SELECT body FROM Labels JOIN AppliedLabels ON Labels.id = AppliedLabels.labelId WHERE AppliedLabels.conversationId = requestedConversationId;
                    SELECT isArchived FROM ConversationSettings WHERE ConversationSettings.conversationId = requestedConversationId AND ConversationSettings.username = requester;
                    SELECT NOT EXISTS (SELECT ConversationSettings.id from ConversationSettings WHERE ConversationSettings.conversationId = requestedConversationId AND NOT identityRevealed);
                    SELECT NOT EXISTS (SELECT Messages.id FROM Messages JOIN MessageSettings ON requester = MessageSettings.username AND Messages.id = MessageSettings.messageId WHERE Messages.conversationId = requestedConversationId AND NOT isRead);
                ELSE
                    SELECT -403;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE set_status (IN conversationIdToUpdate INT, IN requester VARCHAR(40), IN newStatus VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE username=requester AND (isCCSGA OR isAdmin) AND NOT isBanned) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = conversationIdToUpdate) THEN
                    SELECT -404;
                ELSE
                    UPDATE Conversations SET status = newStatus WHERE id = conversationIdToUpdate;
                    SELECT -200;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE set_archived (IN conversationIdToUpdate INT, IN requester VARCHAR(40), IN newIsArchived BOOL)
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=requester AND isBanned) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = conversationIdToUpdate) THEN
                    SELECT -404;
                ELSEIF NOT EXISTS (SELECT id FROM ConversationSettings WHERE conversationId = conversationIdToUpdate AND username = requester AND isAccessible) THEN
                    SELECT -403;
                ELSE
                    UPDATE ConversationSettings SET isArchived = newIsArchived WHERE conversationId = conversationIdToUpdate AND username = requester;
                    SELECT -200;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE reveal_identity (IN conversationIdToUpdate INT, IN requester VARCHAR(40))
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=requester AND isBanned) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = conversationIdToUpdate) THEN
                    SELECT -404;
                ELSEIF NOT EXISTS (SELECT id FROM ConversationSettings WHERE username=requester AND conversationId=conversationIdToUpdate AND isAccessible) THEN
                    SELECT -403;
                ELSE
                    UPDATE ConversationSettings SET identityRevealed = 1 WHERE username=requester AND id = conversationIdToUpdate;
                    SELECT -200;
                END IF;
            END ;
        '''
    ]

    admin_commands = [
        '''CREATE PROCEDURE add_ccsga (IN newCCSGA VARCHAR(40), IN adder VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = adder) THEN
                    SELECT -403;
                ELSEIF EXISTS (SELECT username FROM Users WHERE username = newCCSGA AND isCCSGA) THEN
                    SELECT -200;
                ELSE
                    IF EXISTS (SELECT username FROM Users WHERE username = newCCSGA) THEN
                        UPDATE Users SET isBanned = 0, isCCSGA = 1, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = adder WHERE username = newCCSGA;
                    ELSE
                        INSERT INTO Users (username, displayName, isBanned, isCCSGA, isAdmin, rolesLastUpdated, updatedBy) VALUES (newCCSGA, CONCAT(newCCSGA, " (display name not set)"), 0, 1, 0, UTC_TIMESTAMP(), adder);
                    END IF;
                    INSERT IGNORE INTO ConversationSettings (conversationId, username, isArchived, identityRevealed, isInitiator) SELECT Conversations.id, newCCSGA, 0, 1, 0 FROM Conversations;
                    UPDATE ConversationSettings SET isAccessible = 1 WHERE username = newCCSGA;
                    INSERT IGNORE INTO MessageSettings (messageId, username, isRead) SELECT Messages.id, newCCSGA, 1 FROM Messages;
                    SELECT -201;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE add_admin (IN newAdmin VARCHAR(40), IN adder VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = adder) THEN
                    SELECT -403;
                ELSEIF EXISTS (SELECT username FROM Users WHERE username = newAdmin AND isAdmin) THEN
                    SELECT -200;
                ELSE
                    IF EXISTS (SELECT username FROM Users WHERE username = newAdmin) THEN
                        UPDATE Users SET isBanned = 0, isAdmin = 1, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = adder WHERE username = newAdmin;
                    ELSE
                        INSERT INTO Users (username, displayName, isBanned, isCCSGA, isAdmin, rolesLastUpdated, updatedBy) VALUES (newAdmin, CONCAT(newAdmin, " (display name not set)"), 0, 0, 1, UTC_TIMESTAMP(), adder);
                    END IF;
                    INSERT IGNORE INTO ConversationSettings (conversationId, username, isArchived, identityRevealed, isInitiator) SELECT Conversations.id, newAdmin, 0, 1, 0 FROM Conversations;
                    UPDATE ConversationSettings SET isAccessible = 1 WHERE username = newAdmin;
                    INSERT IGNORE INTO MessageSettings (messageId, username, isRead) SELECT Messages.id, newAdmin, 1 FROM Messages;
                    SELECT -201;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE remove_ccsga (IN ccsgaToRemove VARCHAR(40), IN remover VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = remover) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT username FROM Users WHERE username = ccsgaToRemove AND isCCSGA) THEN
                    SELECT -404;
                ELSE
                    UPDATE Users SET isCCSGA = 0, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = remover WHERE username = ccsgaToRemove;
                    IF NOT EXISTS (SELECT username FROM Users WHERE username = ccsgaToRemove AND isAdmin) THEN
                        UPDATE ConversationSettings SET isAccessible = 0 WHERE username = ccsgaToRemove AND NOT isInitiator;
                    END IF;
                    SELECT -200;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE remove_admin (IN adminToRemove VARCHAR(40), IN remover VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = remover) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT username FROM Users WHERE username = adminToRemove AND isAdmin) THEN
                    SELECT -404;
                ELSE
                    IF (SELECT COUNT(username) FROM Users WHERE isAdmin) = 1 THEN
                        SELECT -400;
                    ELSE 
                        UPDATE Users SET isAdmin = 0, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = remover WHERE username = adminToRemove;
                        IF NOT EXISTS (SELECT username FROM Users WHERE username = adminToRemove AND isCCSGA) THEN
                            UPDATE ConversationSettings SET isAccessible = 0 WHERE username = adminToRemove AND NOT isInitiator;
                        END IF;
                        SELECT -200;
                    END IF;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE add_ban (IN userToBan VARCHAR(40), IN adder VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = adder) THEN
                    SELECT -403;
                ELSEIF EXISTS (SELECT username FROM Users WHERE username = userToBan AND isBanned) THEN
                    SELECT -200;
                ELSE
                    IF EXISTS (SELECT username FROM Users WHERE username = userToBan) THEN
                        UPDATE Users SET isBanned = 1, isCCSGA = 0, isAdmin = 0, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = adder WHERE username = userToBan;
                    ELSE
                        INSERT INTO Users (username, displayName, isBanned, isCCSGA, isAdmin, rolesLastUpdated, updatedBy) VALUES (userToBan, CONCAT(userToBan, " (display name not set)"), 1, 0, 0, UTC_TIMESTAMP(), adder);
                    END IF;
                    UPDATE ConversationSettings SET isAccessible = 0 WHERE username = userToBan;
                    SELECT -201;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE remove_ban (IN userToUnban VARCHAR(40), IN remover VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = remover) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT username FROM Users WHERE username = userToUnban AND isBanned) THEN
                    SELECT -404;
                ELSE
                    UPDATE Users SET isBanned = 0, rolesLastUpdated = UTC_TIMESTAMP(), updatedBy = remover WHERE username = userToUnban;
                    UPDATE ConversationSettings SET isAccessible = 1 WHERE username = userToUnban AND isInitiator;
                    SELECT -200;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE get_admins (IN requester VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = requester) THEN
                    SELECT -403;
                ELSE
                    SELECT username, displayName, isBanned, isCCSGA, isAdmin FROM Users WHERE isAdmin;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE get_ccsga_reps (IN requester VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = requester) THEN
                    SELECT -403;
                ELSE
                    SELECT username, displayName, isBanned, isCCSGA, isAdmin FROM Users WHERE isCCSGA;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE get_banned_users (IN requester VARCHAR(40))
            BEGIN
                IF NOT EXISTS (SELECT username FROM Users WHERE isAdmin AND username = requester) THEN
                    SELECT -403;
                ELSE
                    SELECT username, displayName, isBanned, isCCSGA, isAdmin FROM Users WHERE isBanned;
                END IF;
            END ;
        '''
    ]


    all_commands = [messages_commands, admin_commands]
    
    conn, cur = get_conn_and_cursor()
    for command_list in all_commands:
        for command in command_list:
            try:
                cur.execute(command)
            except mariadb.OperationalError as e: # Procedure already exists, hopefully
                # Still raise the execption if it wasn't due to the procedure already existing
                if re.match(r"PROCEDURE \S+ already exists", str(e)) == None:
                    conn.close()
                    raise
    
    conn.close()

# Helper functions for other files to import

def confirm_user_in_db(username, display_name):
    '''Insert a record for this user (as a student) into the DB if their username is not yet in the database.
    This function also updates the user's display name if it has changed since the last time it was checked.'''
    conn, cur = get_conn_and_cursor()
    cur.execute("INSERT IGNORE INTO Users (username, isBanned, isCCSGA, isAdmin, displayName, rolesLastUpdated) VALUES (?, 0, 0, 0, ?, UTC_TIMESTAMP());", (username, display_name))
    cur.execute("UPDATE Users SET displayName = ? WHERE username = ?;", (display_name, username))
    conn.commit()
    # Don't close connection, because the calling function may have already asked for the connection and won't realize that it's since been closed here

# Helper functions for checking user role (other files can import these)

def is_student(username):
    '''Return True iff specified user is student (i.e., neither CCSGA rep nor admin).'''
    if not username: return False
    conn, cur = get_conn_and_cursor()
    cur.execute("SELECT isCCSGA, isAdmin FROM Users WHERE username = ?", (username,))
    isCCSGA, isAdmin = cur.fetchone()
    conn.close()
    return not (isCCSGA or isAdmin)

def is_ccsga(username):
    '''Return True iff specified user is a CCSGA rep.'''
    if not username: return False
    conn, cur = get_conn_and_cursor()
    cur.execute("SELECT isCCSGA FROM Users WHERE username = ?", (username,))
    isCCSGA = cur.fetchone()[0]
    conn.close()
    return bool(isCCSGA)

def is_admin(username):
    '''Return True iff specified user is an admin.'''
    if not username: return False
    conn, cur = get_conn_and_cursor()
    cur.execute("SELECT isAdmin FROM Users WHERE username = ?", (username,))
    isAdmin = cur.fetchone()[0]
    conn.close()
    return bool(isAdmin) 


if __name__ == '__main__':
    print("Creating database tables (doesn't modify any that already exist)")
    create_tables()
    print("Creating stored procedures (doesn't modify any that already exist)")
    create_stored_procedures()
