# 📊 Ansible VM Monitor with Email Notification
```
An automated **VM health monitoring solution** built using **Ansible, AWS Dynamic Inventory, and Email Notification**.

This project dynamically discovers AWS EC2 instances using tags, collects server health metrics, generates an HTML-based monitoring report, and sends the report through email notifications.

---
```
## 📑 Table of Contents

* [Project Overview](#project-overview)
* [Architecture](#architecture)
* [Features](#features)
* [Technologies Used](#technologies-used)
* [Project Structure](#project-structure)
* [Setup Instructions](#setup-instructions)
* [Running the Project](#running-the-project)
* [Sample Monitoring Report](#sample-monitoring-report)
* [Troubleshooting](#troubleshooting)
* [Future Enhancements](#future-enhancements)

---

## 📌 Project Overview

Monitoring VM health is an important part of infrastructure operations. This project automates server monitoring using Ansible by collecting:

* **CPU utilization**
* **Memory usage**
* **Disk utilization**
* **Hostname information**
* **Operating system details**
* **System uptime**

The collected information is converted into a structured HTML report and delivered through email.

---

## 🏗️ Architecture


```text
                 AWS EC2 Instances
                        |
                        |
          Dynamic Inventory Discovery
          (inventory/aws_ec2.yaml)
                        |
                        |
              Ansible Control Node
                        |
                        |
                  playbook.yaml
                        |
          -----------------------------
          |                           |
 collect_metrics.yaml           send_report.yaml
          |                           |
          |                           |
  Collect VM Health Data              |
          |                           |
          |                           |
 Generate HTML Report                 |
          |                           |
          |                           |
  Email Notification <-----------------

```

---

## ✨ Features

* ✅ **AWS EC2 Dynamic Inventory**
* ✅ **Agentless monitoring** using Ansible
* ✅ **SSH-based** VM communication
* ✅ **Automatic EC2 instance discovery**
* ✅ **Resource Monitoring:** CPU, Memory, Disk, and Uptime
* ✅ **HTML email report generation**
* ✅ **Automated email notifications**
* ✅ **Easy configuration** using Ansible variables

---

## 🛠️ Technologies Used

| Technology | Purpose |
| --- | --- |
| **Ansible** | Automation and configuration management |
| **AWS EC2** | Virtual machines |
| **AWS CLI** | AWS resource management |
| **Dynamic Inventory** | Automatic host discovery |
| **Python boto3** | AWS API communication |
| **SSH** | Remote server access |
| **SMTP** | Email notification |
| **YAML** | Configuration management |

---

## 📂 Project Structure

```text
Ansible-VM-Monitor/
│
├── group_vars/
│   └── all.yaml
│
├── inventory/
│   └── aws_ec2.yaml
│
├── templates/
│   └── report_email_animated.html.j2
│
├── scripts/
│   ├── tag_instances.sh
│   └── copy_pubkey.sh
│
├── ansible.cfg
├── collect_metrics.yaml
├── playbook.yaml
├── send_report.yaml
└── README.md
```


## ⚙️ Setup Instructions

```
### Step 1: Update System

```
```bash
sudo apt update && sudo apt upgrade -y

```

### Step 2: Install Ansible

Add the Ansible repository:

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

### Step 3: Install AWS CLI

Download AWS CLI:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip

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

Configure AWS:

```bash
aws configure

```

Provide your:

* `AWS Access Key ID`
* `AWS Secret Access Key`
* `AWS Region`
* `Output Format`

---

# 🏷️ Step 4: Tag AWS EC2 Instances

To make EC2 instances easier to identify, this project automatically assigns sequential **Name** tags (`web-01`, `web-02`, `web-03`, ...).

Create a file named **`tag_instances.sh`**.

```bash
#!/bin/bash

# Fetch instance IDs that match Environment=dev
instance_ids=$(aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=dev" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

# Sort instance IDs deterministically
sorted_ids=($(echo "$instance_ids" | tr '\t' '\n' | sort))

# Rename instances sequentially
counter=1

for id in "${sorted_ids[@]}"; do
  name="web-$(printf "%02d" $counter)"
  echo "Tagging $id as $name"

  aws ec2 create-tags \
    --resources "$id" \
    --tags Key=Name,Value="$name"

  ((counter++))
done
```

Make the script executable:

```bash
chmod +x tag_instances.sh
```

Run the script:

```bash
./tag_instances.sh
```

Example output:

```text
Tagging i-0ab12345cd6789ef0 as web-01
Tagging i-0123456789abcdef0 as web-02
Tagging i-0fedcba9876543210 as web-03
```

---

# 🔑 Step 5: Copy SSH Public Key to EC2 Instances

Before Ansible can communicate with the EC2 instances without prompting for authentication, copy your local SSH public key to all discovered instances.

Create a file named **`copy_pubkey.sh`**.

```bash
#!/bin/bash

# Define variables
PEM_FILE="DevOps-Shack.pem"
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
```

Make the script executable:

```bash
chmod +x copy_pubkey.sh
```

Execute the script:

```bash
./copy_pubkey.sh
```

After successful execution, Ansible can connect to all EC2 instances using SSH without manually copying keys to each server.

---

### Step 6: Configure EC2 Tags

The project uses AWS tags for dynamic discovery.
**Example:**

```text
Environment = dev

```

Only running EC2 instances with this tag will be monitored.

### Step 7: Configure Ansible Inventory

Edit the file at `inventory/aws_ec2.yaml`:

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

### Step 8: Configure Ansible

Edit the file at `ansible.cfg`:

```ini
[defaults]
inventory = ./inventory/aws_ec2.yaml
host_key_checking = False

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

```

### Step 9: Create Python Environment

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

Install dependencies:

```bash
pip install boto3 botocore docker

```

### Step 10: Install AWS Ansible Collection

```bash
ansible-galaxy collection install amazon.aws

```

### Step 11: Verify Dynamic Inventory

Run:

```bash
ansible-inventory -i inventory/aws_ec2.yaml --graph

```

**Example Output:**

```text
@all
 |--web-01
 |--web-02
 |--web-03

```

### Step 12: Configure SSH Access

Ensure the Ansible Control Node can connect to the EC2 instances.
Test:

```bash
ssh ubuntu@server-ip

```

Fix key permission:

```bash
chmod 400 key.pem

```

### Step 13: Configure Email Variables

Update `group_vars/all.yaml`:

```yaml
smtp_server: smtp.gmail.com
smtp_port: 587
sender_email: monitoring@example.com
receiver_email: admin@example.com

```

**For Gmail:**

* Enable App Password
* Use the App Password instead of your account password

---

## ▶️ Running the Project

Execute the main playbook:

```bash
ansible-playbook playbook.yaml

```

### 🔄 Playbook Execution Flow

`playbook.yaml` controls the complete workflow. It executes:

1. **`collect_metrics.yaml`** ➔ Collect VM Information
2. **`send_report.yaml`** ➔ Generate Email Report ➔ Send Notification

---

## 📊 Sample Monitoring Report

> **VM Health Report**
> **Hostname:** `web-01`
> **CPU Usage:** 35%
> **Memory Usage:** 60%
> **Disk Usage:** 45%
> **Uptime:** 15 days
> **Status:** Healthy

### 📧 Email Notification

The project sends an HTML formatted email report. The email contains:

* VM hostname
* CPU usage
* Memory utilization
* Disk usage
* System health status

**Template Location:** `templates/report_email_animated.html.j2`

---

## ⏰ Scheduling Monitoring

Using Cron:

```bash
crontab -e

```

**Example (Run every hour):**

```bash
0 * * * * ansible-playbook playbook.yaml

```

---

## 🧪 Troubleshooting

### Ansible Host Unreachable

Check:

```bash
ansible all -m ping

```

**Verify:**

* SSH key
* AWS Security Groups (inbound rules)
* Instance IP
* Username

### AWS Inventory Not Showing Instances

Check:

```bash
ansible-inventory -i inventory/aws_ec2.yaml --graph

```

**Verify:**

* AWS credentials
* Region
* EC2 tags

### Email Not Received

**Verify:**

* SMTP configuration
* Email credentials
* App password
* SMTP port

---

## 🚀 Future Enhancements

* [ ] Slack notifications
* [ ] Microsoft Teams alerts
* [ ] Prometheus integration
* [ ] Grafana dashboard
* [ ] Alert thresholds
* [ ] Auto remediation
* [ ] Kubernetes node monitoring

---

## 📌 Repository

**GitHub:** [Ansible-VM-Monitor](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FAkash-M21%2FAnsible-VM-Monitor)
