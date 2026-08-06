## Getting Started

- This guide supports AWS EC2 with Terraform.

### Prepare Repository

```bash
# Local and VM

# Clone repository
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration

# Prepare submodules
git submodule update --init --recursive

# Prepare environment variables
cp .env.example .env
```

### Create Resources with Terraform

```bash
# Local

# Move to repository
cd ExcalidrawCollaboration/terraform

# Prepare and edit local values
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars

# Create resources
terraform init
terraform plan
terraform apply
```

### Connect AWS EC2 with SSM

```bash
# Local

# Configure AWS CLI credentials and region before connecting
aws configure

# Connect to AWS EC2 via SSM
aws ssm start-session --target <EC2_INSTANCE_ID>

# Switch to ubuntu user
sudo -iu ubuntu
```

### Configure Environment Values

```bash
# Local and VM

# Excalidraw room endpoint
vi .env
```

Set the value for the environment where Excalidraw runs.

```dotenv
# Local
VITE_APP_WS_SERVER_URL=http://localhost:9248

# Production
VITE_APP_WS_SERVER_URL=https://<YOUR_FQDN>
```

### Configure Production Values

```bash
# VM

# nginx server_name and certificate paths
vi docker/nginx/default.conf
```

```nginx
# Required
server_name <YOUR_FQDN>;

ssl_certificate /etc/letsencrypt/live/<YOUR_FQDN>/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/<YOUR_FQDN>/privkey.pem;
```

1. Add an A record in your DNS provider to point your domain to the VM public IP.

| Record Name | Type | Value                    | TTL |
| ----------- | ---- | ------------------------ | --- |
| <YOUR_FQDN> | A    | <VM_PUBLIC_IPV4_ADDRESS> | 300 |

### Set Up Excalidraw Server

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Set up Ubuntu, Docker, and certbot
./ubuntu/setup.sh

# Issue SSL certificate
sudo certbot certonly --standalone -d <YOUR_FQDN>

# Start services with nginx
docker compose --profile production up -d --build
```

For local development, start the services without the production profile.

```bash
# Local
docker compose up -d --build
```

If nginx was previously installed on the VM, stop it before starting the
production profile so ports 80 and 443 are available.

```bash
# VM migration only
sudo systemctl disable --now nginx
```

### Renew SSL Certificate

```bash
# VM

# Release port 80 for certbot
docker compose --profile production stop nginx

# Renew certificate
sudo certbot renew

# Start nginx with the renewed certificate
docker compose --profile production start nginx
```

### Optional Swap

```bash
# VM

# Use this only for low-memory instances.
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```
