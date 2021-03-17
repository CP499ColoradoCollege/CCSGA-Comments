#!/bin/bash
# This file is designed to be automatically run on a regular basis by cron. 
# In order to use it, update the values for insert_backup_user_username, insert_password (with no space after the -p), and insert_database_name below,
# according to the values for a MariaDB account with SELECT, LOCK TABLES, and RELOAD privileges. 

# Make sure backups folder exists
cd $HOME
mkdir -p backups

# Create backup
mysqldump -u insert_backup_user_username -pinsert_password -x --databases insert_database_name > backups/`date +'%Y%m%d'`.sql || return 1

# Delete backups that are at least a week old
for filename in backups/*.sql; do
    filedate=${filename:8:-4}
    minkeepdate=$(date -v -6d +'%Y%m%d') # works on Mac, not that Linux machine
    # minkeepdate=$(date -d "-6 day" +'%Y%m%d') # Linux version
    if [[ $filedate < $minkeepdate ]]; then 
        rm $filename
    fi
done