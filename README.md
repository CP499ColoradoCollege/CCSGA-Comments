# CCSGA Comments
A system for secure, informal, comfortable communication between students and the student government at Colorado College.

## Deployment Documentation


## Developer Documentation

Once the system is set up and running successfully, use the following information and instructions to continue its maintenance and operations.

#### System Architecture and File Structure

![System Architecture](documentation/System_Architecture.png)

The frontend of the system is created through the Flutter framework, written in Dart. The dart files stored within the repository at `students/lib/` (of which `students/lib/main.dart` is the main entry point) are transpiled into a JavaScript web build placed at `students/build/web`, which a Flask backend serves to the browser whenever browser requests any routes not beginning with `/api`.

__TODO describe frontend routing & navigation, models, user I/O__

When the frontend needs to make an API request, it formats any required data as JSON, sends a request through the Dart http library, and awaits a JSON response from the server. Nginx, acting as a reverse proxy running on port 8443 on the virtual server, fields the request directy and forwards it to the Gunicorn service running strictly locally on port 8000 on the virtual server. Gunicorn runs a Flask application encompassed within the files located at `/opt/ccsga_comments/backend` on the server. Most of the files at this location (or at least in the `backend` folder within the repository) are flask files, including `__init__.py` (the main application entry point), `route_wrappers.py`, and files of the form `*_handler.py`. Other files in `backend` include `config.py` and `.env`, which store certain sensitive and non-sensitive configuraton values that should stay within the virtual machine (i.e., they should not be included in version control, which is why sample versions of both are provided as templates in the repository). Finally, `requirements.txt` stores the current dependencies for the flask backend, and the `test` directory holds all of the API tests, which can be run as individual python programs after the developer signs into the website and pastes the required values into `.env`, as described in `.env_sample`.

The other backend components with which the Flask application interfaces are the MariaDB database and the CAS server. The former is a service, also running on the virtual machine, to which the application connects through the python mariadb library, while the latter is a separate server with which the application communicates through the python Flask-CAS library. 

#### API

In the `documentation` folder of this repository, we have placed the document we have been using an an authority for consistent API development between frontend and backend. In the interest of encouraging future development, we have provided it as is, including iceboxed routes, notes, and general tasks for future development.

#### Database Entity Relationships
![ER Diagram](documentation/CCSGA_Comments_ER_Diagram.png)

The core objects within the messaging system are Users, Conversations, and Messages. The Users table stores information from CAS (username and display name), information about special roles (i.e., if a user is banned, CCSGA, or an admin), and metadata regarding the updating of the user's roles. The Conversations table itself stores only the CCSGA-set status of each conversation, and the Messages table itself stores the sender, body, and timestamp of each message. 

The ConversationSettings and MessageSettings tables embody the many-to-many relationships between Users and Conversations and between Users and Messages, respectively. The ConversationSettings table contains some fields that represent actual settings of a specific User within the context of a specific conversation (i.e., whether or not the user has archived or revealed their identity within that conversation). In addition, the table also stores indicators of whether or not the user initated the conversation (used for determining access when a user is demoted from an admin or CCSGA role) and whether or not the user currently has access to the conversation. The latter is redundant currently, as a user's conversation access could be determined solely by their isInitiator flag or their isCCSGA/isAdmin status under the current setup. However, this method would become problematic if future functionality allowed students to copy other students when initiating conversations, since such other students are indifferentiable from ex-reps in terms of isInitiator and isCCSGA/isAdmin, but such other students should still have access to the conversation whereas ex-reps shouldn’t. Having an isAccessible field in ConversationSettings resolves this easily, so it is included in the table proactively. If future development moves in this direction, further thought should be given to this strategy; either isInitiator or isAccessible might need to change to something similar to becameInvolvedAsStudent to cover students who were copied on a conversation, were later promoted, and were even later demoted. 

The MessageSettings table is the sole location for recording which messages which users have read. When communicating the read or unread state of an entire conversation, the program should indicate that an entire conversation is read, for a given user, if and only if all messages in that conversation are marked as read for that user.

The Labels and AppliedLabels tables are the final two tables that back the messaging service. Labels simply have a field for the text body of each label, which should be unique throughout the table. AppliedLabels embody the many-to-many relationship between Labels and Conversations. This design was chosen with the potential of supporting a small, fixed number of labels (although the system does not work this way currently) and with the potential of allowing label objects to become more complex than simple strings, if desired in the future.

The database also includes two tables designed to be used if future development allows for a dynamic homepage. The Announcements table stores a string representation of an icon (the means of this representation remain to be determined), the announcement body, and the timestamp of the announcement. The Links table stores all of these attribtes as well as a URL to which a user is directed when clicking on that link.
