#!/bin/bash
set -e -o pipefail

USERDATALOG="/var/log/user-data.log"

function log()
{
    message="[INFO] $@"
    echo -e "$message" >> $USERDATALOG 2>&1
}

function logandexit()
{
    message="[ERROR] $@"
    echo -e "$message" >> $USERDATALOG 2>&1
    # Shutting down the instance will mark it as Unhealthy in the auto-scaling group
    log "[ERROR] $ERR - shutting down instance in 5 minutes"
    sleep 300
    shutdown -h now
    echo -e "$message" >> $USERDATALOG 2>&1
    curl -X POST -H 'Content-Type: application/json' --data "{\"text\": \"Jenkins-Master :: ${MESSAGE}\"}" ${slack_webhook} 
}


service awslogs start

log "Apply the yum update"
yum update -y >> $USERDATALOG 2>&1

# Start Docker Service
service docker start >> $USERDATALOG 2>&1

# Check that /mnt/efs is not already mounted. If it does, it is a bad sign.
mountpoint -q /mnt/efs

if [[ $? -ne 0 ]]; then
    log "Mountpoint /mnt/efs doesn't exit. Proceed!!"
else 
    logandexit "Mountpoint /mnt/efs exist. Panic!!"
fi


# Update fstab to mount EFS
echo "${efs_id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

# Remount
mount -a

mkdir -p /mnt/efs/jenkins-data

# Remove default Jenkins data dir and replace with EFS
# And update Owner Permissions
rm -rf /var/lib/jenkins
ln -s /mnt/efs/jenkins-data /var/lib/jenkins
chown jenkins:jenkins -R /mnt/efs

df -h >> $USERDATALOG 2>&1

service jenkins restart >> $USERDATALOG 2>&1



