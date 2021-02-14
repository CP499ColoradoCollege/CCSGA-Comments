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
    cur.execute("CREATE TABLE IF NOT EXISTS Users (username VARCHAR(40), displayName VARCHAR(100), isBanned BOOL, isCCSGA BOOL, isAdmin BOOL, PRIMARY KEY (username));")
    cur.execute("CREATE TABLE IF NOT EXISTS Conversations (id INT AUTO_INCREMENT, status VARCHAR(40), PRIMARY KEY (id));")
    cur.execute("CREATE TABLE IF NOT EXISTS Messages (id INT AUTO_INCREMENT, conversationId INT, sender VARCHAR(40), body TEXT, dateandtime DATETIME, PRIMARY KEY (id), FOREIGN KEY (conversationId) REFERENCES Conversations(id), FOREIGN KEY (sender) REFERENCES Users(username));")
    cur.execute("CREATE TABLE IF NOT EXISTS Labels (id INT AUTO_INCREMENT, body VARCHAR(40), PRIMARY KEY (id), UNIQUE (body));")
    cur.execute("CREATE TABLE IF NOT EXISTS ConversationSettings (id INT AUTO_INCREMENT, conversationId INT, username VARCHAR(40), isArchived BOOL, identityRevealed BOOL, PRIMARY KEY (id), FOREIGN KEY (conversationId) REFERENCES Conversations(id), FOREIGN KEY (username) REFERENCES Users(username));")
    cur.execute("CREATE TABLE IF NOT EXISTS MessageSettings (id INT AUTO_INCREMENT, messageId INT, username VARCHAR(40), isRead BOOL, PRIMARY KEY (id), FOREIGN KEY (messageId) REFERENCES Messages(id), FOREIGN KEY (username) REFERENCES Users(username));")
    cur.execute("CREATE TABLE IF NOT EXISTS AppliedLabels (id INT AUTO_INCREMENT, conversationId INT, labelId INT, PRIMARY KEY (id), FOREIGN KEY (conversationId) REFERENCES Conversations(id), FOREIGN KEY (labelId) REFERENCES Labels(id));")
    cur.execute("CREATE TABLE IF NOT EXISTS Links (id INT AUTO_INCREMENT, icon TEXT, body TEXT, url TEXT, dateandtime DATETIME, PRIMARY KEY (id));")
    cur.execute("CREATE TABLE IF NOT EXISTS Announcements (id INT AUTO_INCREMENT, icon TEXT, body TEXT, dateandtime DATETIME, PRIMARY KEY (id));")

def create_stored_procedures():
    '''Creates all the stored procedures for the database. Doesn't modify those that currently exist.'''
    commands = [
        '''CREATE PROCEDURE create_conversation (IN revealIdentity BOOL, IN sender VARCHAR(40), OUT conversationId INT)
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE (isCCSGA OR isBanned) AND username=sender) THEN
                    SET conversationId = -403;
                ELSE
                    INSERT INTO Conversations (status) VALUES ('Delivered');
                    SELECT LAST_INSERT_ID() INTO conversationId;
                    INSERT INTO ConversationSettings (conversationId, username, isArchived, identityRevealed) VALUES (conversationId, sender, 0, revealIdentity);
                    INSERT INTO ConversationSettings (conversationId, username, isArchived, identityRevealed) SELECT conversationId, Users.username, 0, 1 FROM Users WHERE isCCSGA;
                END IF;
            END ;
        ''',
        '''CREATE PROCEDURE create_message (IN conversationIdInput INT, IN sender VARCHAR(40), IN messageBody TEXT, OUT newMessageId INT)
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=sender AND isBanned) THEN
                    SET newMessageId = -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = conversationIdInput) THEN
                    SET newMessageId = -404;
                ELSEIF EXISTS (SELECT username FROM Users WHERE isCCSGA AND username=sender) OR EXISTS (SELECT username FROM ConversationSettings WHERE username = sender AND conversationId = conversationIdInput) THEN
                    INSERT INTO Messages (conversationId, sender, body, dateandtime) VALUES (conversationIdInput, sender, messageBody, UTC_TIMESTAMP());
                    SELECT LAST_INSERT_ID() INTO newMessageId;
                    INSERT INTO MessageSettings (messageId, username, isRead) SELECT newMessageId, ConversationSettings.username, 0 FROM ConversationSettings WHERE ConversationSettings.conversationId = conversationIdInput;
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
        '''CREATE PROCEDURE get_conversation (IN requestedConversationId INT, IN requester VARCHAR(40))
            BEGIN
                IF EXISTS (SELECT username FROM Users WHERE username=requester AND isBanned) THEN
                    SELECT -403;
                ELSEIF NOT EXISTS (SELECT id FROM Conversations WHERE id = requestedConversationId) THEN
                    SELECT -404;
                ELSEIF EXISTS (SELECT username FROM Users WHERE isCCSGA AND username=requester) OR EXISTS (SELECT username FROM ConversationSettings WHERE username = requester AND conversationId = requestedConversationId) THEN
                    SELECT Messages.id, Users.username, Users.displayName, Messages.body, Messages.dateandtime, MessageSettings.isRead FROM ((Messages JOIN Users ON Messages.sender = Users.username) JOIN MessageSettings ON requester = MessageSettings.username AND Messages.id = MessageSettings.messageId) WHERE Messages.conversationId = requestedConversationId;
                ELSE
                    SELECT -403;
                END IF;
            END ;
        '''
    ]
    
    conn, cur = get_conn_and_cursor()
    for command in commands:
        try:
            cur.execute(command)
        except mariadb.OperationalError as e: # Procedure already exists, hopefully
            # Still raise the execption if it wasn't due to the procedure already existing
            if re.match(r"PROCEDURE \S+ already exists", str(e)) == None:
                raise


if __name__ == '__main__':
    print("Creating database tables (doesn't modify any that already exist)")
    create_tables()
    print("Creating stored procedures (doesn't modify any that already exist)")
    create_stored_procedures()
