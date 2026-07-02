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

### Configure Production Values

```bash
# Local and VM

# Excalidraw room endpoint through nginx
vi docker-compose.yaml

# nginx server_name and certificate paths
vi nginx/default.conf
```

```yaml
# Required
VITE_APP_WS_SERVER_URL: "wss://<YOUR_FQDN>"
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

# Set up Ubuntu, Docker, nginx, and certbot
./ubuntu/setup.sh

# Issue SSL certificate
sudo certbot certonly --standalone -d <YOUR_FQDN>

# Start services
docker compose up -d --build

# Configure nginx
sudo cp nginx/default.conf /etc/nginx/sites-available/excalidraw.conf
sudo ln -sf /etc/nginx/sites-available/excalidraw.conf /etc/nginx/sites-enabled/excalidraw.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
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
