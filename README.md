## Getting Started

- This guide supports both AWS EC2 and Azure VM with Terraform.

### Prepare Repository

```bash
# Local and VM

# Clone repository
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration

# Initialize submodules
git submodule update --init --recursive

# Prepare and edit .env file
cp .env.example .env
vi .env
```

```dotenv
# Local
VITE_APP_WS_SERVER_URL=http://localhost:9248

# VM
VITE_APP_WS_SERVER_URL=https://<YOUR_FQDN>
```

### Create Resources with Terraform

```bash
# Local

# Move to repository
cd ExcalidrawCollaboration
cd terraform/aws # or terraform/azure

# Prepare and edit local values
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars

# Create resources
terraform init
terraform plan
terraform apply
```

### Connect AWS EC2 with SSM

- Default for AWS is SSM.

```bash
# Local

# Configure AWS CLI credentials and region before connecting
aws configure

# Connect to AWS EC2 via SSM
aws ssm start-session --target <EC2_INSTANCE_ID>

# Switch to ubuntu user
sudo -iu ubuntu
```

### Configure SSH Access

- Default for Azure is SSH (Azure Bastion can be costly).

```bash
# Local

# Save the VM private key
vi ~/.ssh/excalidraw_key.pem
chmod 600 ~/.ssh/excalidraw_key.pem

# Configure SSH host aliases
vi ~/.ssh/config
```

```sshconfig
Host excalidraw
  HostName <VM_PUBLIC_IPV4_ADDRESS>
  User ubuntu
  IdentityFile ~/.ssh/excalidraw_key.pem
```

```bash
# Local

# Connect to VM via SSH
ssh excalidraw
```

### Set Up Excalidraw Server

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Prepare and edit default.conf file
vi docker/nginx/default.conf

# Set up Ubuntu
./ubuntu/setup.sh

# Start temporary Nginx for the initial ACME challenge
docker run --detach --rm --name certbot-webroot --publish 80:80 --volume /var/www/html:/usr/share/nginx/html nginx:1.30-alpine

# Obtain the initial TLS certificate from Let's Encrypt
sudo certbot certonly --webroot -w /var/www/html -d <YOUR_FQDN>

# Stop and remove temporary Nginx
docker stop certbot-webroot

# Start server
make up-b
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

### Renew TLS Certificate

- Nginx must be running.

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Renew the TLS certificate if due and reload Nginx afterward
make renew
```
