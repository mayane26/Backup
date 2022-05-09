# Backup

This script allows you to make full backups in timestamped folders. Incremental backup is based on full backup using links
symbolic.
Each time a new backup will be created, the last current link, still pointing to the previous backup, will be unlinked; it will then be recreated with the
new backup directory as target. The link will always point to the latest backup available.
