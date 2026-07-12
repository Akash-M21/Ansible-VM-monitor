#!/bin/bash

# Define variables
PEM_FILE="DevOps.pem"
PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
USER="ubuntu"      # Change to ec2-user for Amazon Linux
INVENTORY_FILE="inventory/aws_ec2.yaml"

# Extract hosts from Ansible Dynamic Inventory
HOSTS=$(ansible-inventory -i $INVENTORY_FILE --list | jq -r '._meta.hostvars | keys[]')

# Copy SSH public key to each instance
for HOST in $HOSTS; do

    echo "Injecting SSH key into $HOST"

    ssh \
      -o StrictHostKeyChecking=no \
      -i $PEM_FILE \
      $USER@$HOST "
        mkdir -p ~/.ssh &&
        echo \"$PUB_KEY\" >> ~/.ssh/authorized_keys &&
        chmod 700 ~/.ssh &&
        chmod 600 ~/.ssh/authorized_keys
      "

done
