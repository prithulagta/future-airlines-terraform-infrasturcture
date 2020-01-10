#cloud-boothook
#!/bin/bash
set -o pipefail

USERDATALOG="/var/log/user-data.log"
InstanceId=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
InstanceIP=$(wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4)

function log()
{
    message="[INFO] $@"
    echo -e "$message" >> $USERDATALOG 2>&1
}

function logandexit()
{
    message="[$InstanceId]::[$InstanceIP]:: [ERROR] $@"
    echo -e "$message" >> $USERDATALOG 2>&1
    # Shutting down the instance will mark it as Unhealthy in the auto-scaling group
    log "[ERROR] $ERR - shutting down instance in 5 minutes"
    sleep 300
    shutdown -h now
    curl -X POST -H 'Content-Type: application/json' --data "{\"text\": \"Jenkins-Worker :: ${MESSAGE}\"}" ${slack_webhook} 
}



log "Apply the yum update"
yum update -y >> $USERDATALOG 2>&1

log "Run ansible-playbook to start Jenkins worker"
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_RETRY_FILES_ENABLED="False"
cd /tmp/ansible-playbooks && ansible-playbook -i "localhost," --tags "runtime" jenkins-worker.yml -e jenkins_master=${master} >> $USERDATALOG 2>&1

[[  $? -ne 0 ]] && logandexit "Jenkins worker configurations completed with errors. Panic!!"
log "Jenkins worker configurations applied successfully"

log "User-data completed successfully. YAY!!" 


