```markdown
An automated **VM health monitoring solution** built using **Ansible, AWS Dynamic Inventory, and Email Notification**.

This project dynamically discovers AWS EC2 instances using tags, collects server health metrics, generates an HTML-based monitoring report, and sends the report through email notifications.

---

## 📌 Project Overview

Monitoring VM health is an important part of infrastructure operations. This project automates server monitoring using Ansible by collecting:

* **CPU utilization**
* **Memory usage**
* **Disk utilization**
* **Hostname information**
* **Operating system details**
* **System uptime**

The collected information is converted into a structured HTML report and delivered straight to your inbox.

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
          |
          |
  Collect VM Health Data
          |
          |
 Generate HTML Report
          |
          |
  Email Notification

```

---

## ✨ Features

* ✅ **AWS EC2 Dynamic Inventory**
* ✅ **Agentless monitoring** using Ansible
* ✅ **SSH-based** VM communication
* ✅ **Automatic EC2 instance discovery** based on tags
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
| **Python / boto3** | AWS API communication |
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

Add the Ansible repository and install:

```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

```

Verify installation:

```bash
ansible --version

```

### Step 3: Install & Configure AWS CLI

Download and install the AWS CLI:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

```

Configure your AWS credentials:

```bash
aws configure

```

*Provide your AWS Access Key ID, Secret Access Key, Region, and preferred Output Format.*
```
### Step 4: Configure EC2 Tags

The project relies on AWS tags for dynamic discovery. Ensure your target EC2 instances have the appropriate tags.
**Example:** `Environment = dev`
*(Only running EC2 instances with this tag will be monitored.)*

### Step 5: Configure Ansible Inventory

Edit `inventory/aws_ec2.yaml`:

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

### Step 6: Configure Ansible Settings

Edit `ansible.cfg`:

```ini
[defaults]
inventory = ./inventory/aws_ec2.yaml
host_key_checking = False

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

```

### Step 7: Create Python Environment

Create and activate a virtual environment, then install dependencies:

```bash
sudo apt install python3-venv -y
python3 -m venv ansible-env
source ansible-env/bin/activate
pip install boto3 botocore docker

```

### Step 8: Install AWS Ansible Collection

```bash
ansible-galaxy collection install amazon.aws

```

### Step 9: Verify Dynamic Inventory

Check if Ansible successfully discovers your AWS instances:

```bash
ansible-inventory -i inventory/aws_ec2.yaml --graph

```

*Expected Output Example:*

```text
@all
 |--web-01
 |--web-02
 |--web-03

```

### Step 10: Configure SSH Access

Ensure the Ansible Control Node can communicate with the EC2 instances.
Fix your key permissions and test the connection:

```bash
chmod 400 key.pem
ssh -i key.pem ubuntu@<server-ip>

```

### Step 11: Configure Email Variables

Update `group_vars/all.yaml` with your SMTP details:

```yaml
smtp_server: smtp.gmail.com
smtp_port: 587
sender_email: monitoring@example.com
receiver_email: admin@example.com

```

> **Note for Gmail Users:** You must enable an App Password and use it instead of your standard account password.

---

## ▶️ Running the Project

Execute the main playbook to start the monitoring workflow:

```bash
ansible-playbook playbook.yaml

```

### 🔄 Playbook Execution Flow

`playbook.yaml` controls the complete workflow. It seamlessly coordinates:

1. **`collect_metrics.yaml`** ➔ Collects VM Information
2. **`send_report.yaml`** ➔ Generates HTML Report & Sends Email Notification

---

## 📊 Sample Monitoring Report

> **VM Health Report**
> **Hostname:** `web-01`
> **CPU Usage:** 35%
> **Memory Usage:** 60%
> **Disk Usage:** 45%
> **Uptime:** 15 days
> **Status:** ✅ Healthy

### 📧 Email Notification

The project sends a formatted HTML email report using the Jinja2 template located at `templates/report_email_animated.html.j2`. It highlights the system health status, resource utilization, and uptime.

---

## ⏰ Scheduling Monitoring

To automate the monitoring process, schedule the playbook using Cron:

```bash
crontab -e

```

*Example: Run the playbook every hour:*

```bash
0 * * * * /path/to/ansible-env/bin/ansible-playbook /path/to/Ansible-VM-Monitor/playbook.yaml

```

---

## 🧪 Troubleshooting

### Ansible Host Unreachable

Test connectivity:

```bash
ansible all -m ping

```

* **Verify:** SSH key permissions (`chmod 400`), AWS Security Group inbound rules (Port 22), instance public IP, and the correct SSH username (e.g., `ubuntu`, `ec2-user`).

### AWS Inventory Not Showing Instances

Test dynamic inventory:

```bash
ansible-inventory -i inventory/aws_ec2.yaml --graph

```

* **Verify:** AWS CLI credentials (`aws configure`), correct region in `aws_ec2.yaml`, and that your EC2 tags match the filters exactly.

### Email Not Received

* **Verify:** SMTP server and port settings, sender/receiver email addresses, and ensure you are using a valid **App Password** (for Gmail/O365) rather than a standard password.

---

## 🚀 Future Enhancements

* [ ] Slack & Microsoft Teams alerts integration
* [ ] Prometheus metrics exposure
* [ ] Grafana dashboard visualization
* [ ] Custom alert thresholds
* [ ] Auto-remediation tasks
* [ ] Kubernetes node monitoring

---

## 📌 Repository

**GitHub:** [Ansible-VM-Monitor](https://github.com/Akash-M21/Ansible-VM-Monitor)
