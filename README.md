```markdown
# 🚀 Ansible VM Monitor with Email Notification

An automated **VM health monitoring solution** built using **Ansible and AWS Dynamic Inventory**.

This project dynamically discovers AWS EC2 instances based on tags, connects to them using SSH, collects system health metrics, generates reports, and sends email notifications with VM status details.

---

# 📌 Project Overview

In cloud environments, monitoring server health is essential for maintaining availability and preventing failures.

This project automates VM monitoring using Ansible by collecting:

- CPU utilization
- Memory usage
- Disk utilization
- System uptime
- Hostname details
- Operating system information

After collecting the metrics, Ansible generates a health report and sends it through email notification.

---

# 🏗️ Architecture

```
                    AWS EC2 Instances
                           |
                           |
              Tag Instances (Environment=dev)
                           |
                           |
                 AWS Dynamic Inventory
                           |
                           |
                 Ansible Control Node
                           |
                           |
                    SSH Connection
                           |
        ---------------------------------------
        |                  |                  |
     VM-01              VM-02              VM-03
     Linux              Linux              Linux

                           |
                           |
                Collect System Metrics

                           |
                           |
                 Generate Health Report

                           |
                           |
                 Email Notification
```

---

# ✨ Features

✅ AWS EC2 Dynamic Inventory  
✅ Agentless monitoring using Ansible  
✅ SSH-based VM communication  
✅ Multiple VM monitoring support  
✅ CPU usage monitoring  
✅ Memory utilization monitoring  
✅ Disk usage monitoring  
✅ System uptime monitoring  
✅ Automated health report generation  
✅ Email notification alerts  
✅ Cron-based scheduling support  

---

# 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Ansible | Automation and monitoring |
| AWS EC2 | Virtual machines |
| AWS CLI | EC2 management |
| Dynamic Inventory | Automatic host discovery |
| Python | AWS SDK support |
| SSH | Secure connection |
| SMTP | Email notification |
| Linux | Control and target machines |

---
```
# 📂 Project Structure

```
Ansible-VM-Monitor/

│
├── inventory/
│   └── aws_ec2.yaml
│
├── playbooks/
│   └── playbook.yaml
│
├── templates/
│   └── email_template.j2
│
├── reports/
│
├── scripts/
│   ├── tag_instances.sh
│   └── copy_pubkey.sh
│
├── ansible.cfg
│
└── README.md

```

---

# ⚙️ Setup Instructions

## Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
```

---

# Step 2: Install Ansible

Add Ansible repository:

```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
```

Install Ansible:

```bash
sudo apt install ansible -y
```

Verify:

```bash
ansible --version
```

---

# Step 3: Install AWS CLI

Download AWS CLI:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o awscliv2.zip
```

Install unzip:

```bash
sudo apt install unzip -y
```

Extract:

```bash
unzip awscliv2.zip
```

Install:

```bash
sudo ./aws/install
```

Verify:

```bash
aws --version
```

Configure AWS credentials:

```bash
aws configure
```

Provide:

```
AWS Access Key ID
AWS Secret Access Key
AWS Region
Output Format
```

---

# Step 4: Tag EC2 Instances

Create:

```
tag_instances.sh
```

Script:

```bash
#!/bin/bash


instance_ids=$(aws ec2 describe-instances \
--filters "Name=tag:Environment,Values=dev" \
"Name=instance-state-name,Values=running" \
--query 'Reservations[*].Instances[*].InstanceId' \
--output text)


sorted_ids=($(echo "$instance_ids" | tr '\t' '\n' | sort))


counter=1

for id in "${sorted_ids[@]}"
do

name="web-$(printf "%02d" $counter)"

echo "Tagging $id as $name"


aws ec2 create-tags \
--resources "$id" \
--tags Key=Name,Value="$name"


((counter++))

done
```

Run:

```bash
chmod +x tag_instances.sh

./tag_instances.sh
```

Example:

```
web-01
web-02
web-03
```

---

# Step 5: Configure Ansible

Create:

```
ansible.cfg
```

Configuration:

```ini
[defaults]

inventory = ./inventory/aws_ec2.yaml

host_key_checking = False


[ssh_connection]

ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

```

---

# Step 6: Configure AWS Dynamic Inventory

Create:

```
inventory/aws_ec2.yaml
```

Content:

```yaml
plugin: amazon.aws.aws_ec2


regions:

  - ap-south-1


filters:

  tag:Environment: dev

  instance-state-name: running


compose:

  ansible_host: public_ip_address


keyed_groups:

  - key: tags.Name
    prefix: name


  - key: tags.Environment
    prefix: env

```

---

# Step 7: Create Python Environment

Install venv:

```bash
sudo apt install python3-venv -y
```

Create environment:

```bash
python3 -m venv ansible-env
```

Activate:

```bash
source ansible-env/bin/activate
```

Install packages:

```bash
pip install boto3 botocore docker
```

---

# Step 8: Install AWS Ansible Collection

```bash
ansible-galaxy collection install amazon.aws
```

---

# Step 9: Verify Dynamic Inventory

Run:

```bash
ansible-inventory \
-i inventory/aws_ec2.yaml \
--graph
```

Example:

```
@all

 |--web-01
 |--web-02
 |--web-03

```

---

# Step 10: Configure SSH Access

Copy public key to EC2 instances.

Create:

```
copy_pubkey.sh
```

Script:

```bash
#!/bin/bash


PEM_FILE="DevOps-Shack.pem"

PUB_KEY=$(cat ~/.ssh/id_rsa.pub)

USER="ubuntu"

INVENTORY_FILE="inventory/aws_ec2.yaml"



HOSTS=$(ansible-inventory \
-i $INVENTORY_FILE \
--list | jq -r '._meta.hostvars | keys[]')


for HOST in $HOSTS

do

echo "Injecting key into $HOST"


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
```

Execute:

```bash
chmod +x copy_pubkey.sh

./copy_pubkey.sh
```

---

# Step 11: Test Ansible Connection

```bash
ansible all \
-i inventory/aws_ec2.yaml \
-m ping
```

Expected:

```
web-01 | SUCCESS => pong

web-02 | SUCCESS => pong
```

---

# Step 12: Run Monitoring Playbook

Execute:

```bash
ansible-playbook \
-i inventory/aws_ec2.yaml \
playbook.yaml
```

---

# 📊 Monitoring Report Example

```
VM Health Report


Hostname:
web-01


CPU Usage:
35%


Memory Usage:
60%


Disk Usage:
45%


Uptime:
15 days


Status:
Healthy

```

---

# 📧 Email Notification

After monitoring completion, an email report is sent containing:

- VM hostname
- CPU utilization
- Memory utilization
- Disk usage
- System health status


Example Subject:

```
VM Monitoring Report - Server Health Status
```

---

# ⏰ Schedule Monitoring

Use Cron:

```bash
crontab -e
```

Example:

Run every hour:

```bash
0 * * * * ansible-playbook -i inventory/aws_ec2.yaml playbook.yaml
```

---

# 🧪 Troubleshooting

## SSH Permission Error

Fix:

```bash
chmod 400 key.pem
```

---

## Host Unreachable

Check:

```bash
ansible all -i inventory/aws_ec2.yaml -m ping
```

Verify:

- Security group rules
- SSH key
- Instance IP
- Username

---

## Email Not Received

Check:

- SMTP configuration
- Email credentials
- Firewall rules
- SMTP port

---

# 🚀 Future Enhancements

- Slack notifications
- Microsoft Teams alerts
- Prometheus integration
- Grafana dashboards
- Auto remediation
- CPU/Disk threshold alerts
- Kubernetes monitoring

---

# 📌 Repository

GitHub:

https://github.com/Akash-M21/Ansible-VM-Monitor
