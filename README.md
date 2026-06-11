```markdown
# 📊 Ansible VM Monitor with Email Notification

An automated **VM health monitoring solution** built using **Ansible, AWS Dynamic Inventory, and Email Notification**.

This project dynamically discovers AWS EC2 instances using tags, collects server health metrics, generates an HTML-based monitoring report, and sends the report through email notifications.

---

## 📑 Table of Contents

* [Project Overview](https://www.google.com/search?q=%23-project-overview)
* [Architecture](https://www.google.com/search?q=%23-architecture)
* [Features](https://www.google.com/search?q=%23-features)
* [Technologies Used](https://www.google.com/search?q=%23-technologies-used)
* [Project Structure](https://www.google.com/search?q=%23-project-structure)
* [Setup Instructions](https://www.google.com/search?q=%23-setup-instructions)
* [Running the Project](https://www.google.com/search?q=%23-running-the-project)
* [Sample Monitoring Report](https://www.google.com/search?q=%23-sample-monitoring-report)
* [Troubleshooting](https://www.google.com/search?q=%23-troubleshooting)
* [Future Enhancements](https://www.google.com/search?q=%23-future-enhancements)

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
├── ansible.cfg
├── collect_metrics.yaml
├── playbook.yaml
├── send_report.yaml
└── README.md

```

---

## ⚙️ Setup Instructions

### Step 1: Update System

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

### Step 4: Configure EC2 Tags

The project uses AWS tags for dynamic discovery.
**Example:**

```text
Environment = dev

```

Only running EC2 instances with this tag will be monitored.

### Step 5: Configure Ansible Inventory

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

### Step 6: Configure Ansible

Edit the file at `ansible.cfg`:

```ini
[defaults]
inventory = ./inventory/aws_ec2.yaml
host_key_checking = False

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

```

### Step 7: Create Python Environment

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

### Step 8: Install AWS Ansible Collection

```bash
ansible-galaxy collection install amazon.aws

```

### Step 9: Verify Dynamic Inventory

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

### Step 10: Configure SSH Access

Ensure the Ansible Control Node can connect to the EC2 instances.
Test:

```bash
ssh ubuntu@server-ip

```

Fix key permission:

```bash
chmod 400 key.pem

```

### Step 11: Configure Email Variables

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
