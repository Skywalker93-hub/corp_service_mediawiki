# Corporate MediaWiki Infrastructure (AWS + Terraform + Ansible)

Automated Infrastructure-as-Code (IaC) and configuration management solution for deploying a high-availability, internal corporate knowledge portal (**MediaWiki**) on **AWS**, accessible exclusively through an **OpenVPN** gateway.

## Architecture & Key Features

- **Private Network Isolation (AWS VPC):** Multi-AZ topology across 3 Availability Zones (`eu-west-1a`, `eu-west-1b`, `eu-west-1c`) with public and private subnets, Internet Gateway, and NAT Gateway.
- **Secure Access via VPN:** Dedicated EC2 instance running **OpenVPN Access Server** (Docker Compose) with split-tunneling and internal VPC DNS resolution.
- **Multi-Tier Load Balancing:**
  - **AWS Internal Application Load Balancer (ALB)** distributing traffic across Nginx reverse proxy nodes.
  - **Nginx Reverse Proxy Layer** (`nginxproxy1`, `nginxproxy2`) with upstream health checks and failover.
  - **MediaWiki Web Tier** (`nginxweb1`, `nginxweb2`) running Nginx + PHP 8.3-FPM with shared media storage mounted via **AWS EFS (NFSv4)**.
  - **Database High Availability:** Local **HAProxy** TCP load balancer on each web node routing traffic to primary/standby **PostgreSQL** instances (`postgresql1`, `postgresql2`).
- **Automated Backups to AWS S3:** Systemd timers (`backup.timer`, `config-backup.timer`) running daily `pg_dump` database backups and configuration archives (`LocalSettings.php`, `/etc/nginx`, `/etc/haproxy`) uploaded to S3 via AWS CLI v2.
- **Monitoring Ready:** Dedicated EC2 instance provisioned for Zabbix monitoring.

## Tech Stack

- **Cloud & IaC:** AWS (VPC, EC2 Ubuntu 24.04 LTS, Internal ALB, EFS, S3, NAT Gateway, Security Groups, IAM), Terraform (`>= 1.5`)
- **Configuration Management:** Ansible (Roles, Jinja2 Templates, Handlers)
- **Web & Proxy:** MediaWiki 1.42, Nginx, HAProxy, PHP 8.3-FPM
- **Database:** PostgreSQL
- **Security & Networking:** OpenVPN Access Server (Docker Compose), Security Groups
- **Backup & Automation:** Bash, Systemd (`service` & `timer` units), AWS CLI v2

## Deployment Guide

### 1. Provision Cloud Infrastructure (Terraform)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Configure Servers and Services (Ansible)

Update `ansible/inventory/inventory.yml` with the provisioned OpenVPN Elastic IP and required variables (`db_password`, `mediawiki_secret_key`, `efs_dns_name`, `wg_server_url`), then run:

```bash
cd ../ansible
ansible-playbook playbook/playbookvpn.yml
ansible-playbook playbook/proxy.yml
ansible-playbook playbook/mediawiki.yml
ansible-playbook playbook/db.yml
```
