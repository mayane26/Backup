#!/bin/bash 
set -o errexit 
set -o nounset 
set -o pipefail 

PATH=$(/usr/bin/getconf PATH || /bin/kill $$) # Path Protection

SOURCE_DIR="/home/$USER/conf" 
BACKUP_DIR="/home/$USER/backup" 
DATETIME="$(date '+%Y-%m-%d%H%M%S')" 
BACKUP_PATH="${BACKUP_DIR}/${DATETIME}" 
LATEST_LINK="${BACKUP_DIR}/latest" 
LINK_FBACKUP="${LATEST_LINK}/full_backup" 
INC_BACKUP="${LATEST_LINK}/inc_backup" 
INC_DATE="${INC_BACKUP}/${DATETIME}" 
INC_LATEST="${INC_BACKUP}/latest" 

#First argument to make backups 
BACKUP="$1" 
BACKUP_INC="inc" 
BACKUP_FULL="full"

#When the choice was made, the script runs the backup chosen 
if [ "$BACKUP" == "$BACKUP_FULL" ]; then 
#Create a timestamp directory with two folders in it: full_backup and inc_backup. 
  mkdir -p "$BACKUP_PATH"/{full_backup,inc_backup}

   if [ -L $LATEST_LINK ]; then 
       #If a symbolic link exists we unlink it then we create a new link and we do our full backup with the rsync command in backup/latest/full_backup.
       unlink "$LATEST_LINK" 
       ln -s "$BACKUP_PATH" "$LATEST_LINK"
       rsync -av --delete "$SOURCE_DIR"/ "$LINK_FBACKUP" 
   else
       # If there is no link, we create one and we do the full backup. 
       ln -s "$BACKUP_PATH" "$LATEST_LINK" 
       rsync -av --delete "$SOURCE_DIR"/ "$LINK_FBACKUP"
   fi

elif [ "$BACKUP" == "$BACKUP_INC" ]; then 
    #Create a timestamp directory cd "$INC_BACKUP" 
    mkdir -p "$INC_DATE" 
    if [ -L "$INC_LATEST" ]; then
        #If a symbolic link exists we unlink it then we create a new link and we do our incremental backup with the rsync command in backup/latest/inc_backup. unlink "$INC_LATEST" 
        ln -s "$INC_DATE" "$INC_LATEST" 
        rsync -av --delete "$SOURCE_DIR" --link-dest "$INC_BACKUP" "$INC_LATEST" 
    else
        #If there is no link, we create one and we do the incremental backup.
        ln -s "$INC_DATE" "$INC_LATEST"
        rsync -av --delete "$SOURCE_DIR"/ --link-dest "$LINK_FBACKUP" "$INC_LATEST" 
    fi 
else 
    echo "It failed, the option can not be recognized"
fi
