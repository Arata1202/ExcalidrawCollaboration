# Excalidraw Collaboration

Self-hosted Excalidraw with real-time collaboration, Nginx, OAuth2 Proxy, and Let's Encrypt TLS.

## Getting Started

This guide deploys the complete stack to either AWS EC2 or an Azure VM using Terraform. Follow only the instructions for your selected cloud provider.

### Prerequisites

- Git and Terraform
- AWS: AWS CLI and the Session Manager plugin
- Azure: Azure CLI and OpenSSH
- A domain whose DNS records you can configure

### Set Up Local Repository

```bash
# Local

# Clone repository
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration

# Initialize submodules
git submodule update --init --recursive
```

### Create Resources with Terraform

Choose one cloud provider and run its commands from the repository root.

#### AWS

```bash
# Local

# Configure AWS credentials and region
aws configure

# Move to the AWS Terraform directory
cd terraform/aws

# Prepare local values
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your preferred editor.

#### Azure

If you do not already have a dedicated SSH key for this VM, create one first:

```bash
# Local

# Generate an SSH key pair
ssh-keygen -t ed25519 -C "excalidraw" -f ~/.ssh/excalidraw -N ""
```

Then authenticate with Azure and prepare the Terraform values:

```bash
# Local

# Authenticate with Azure
az login

# Move to the Azure Terraform directory
cd terraform/azure

# Prepare local values
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your preferred editor and set `ssh_public_key` to the contents of `~/.ssh/excalidraw.pub`.

#### Apply

After preparing either the AWS or Azure values:

```bash
# Local

# Create resources
terraform init
terraform plan
terraform apply
```

### Connect to AWS EC2 with SSM

Use this section for AWS. The Terraform configuration uses AWS Systems Manager Session Manager instead of SSH.

```bash
# Local

# Connect to AWS EC2 via SSM
aws ssm start-session --target <EC2_INSTANCE_ID>

# Switch to ubuntu user
sudo -iu ubuntu
```

### Connect to Azure VM with SSH

Use this section for Azure. Add the following host alias to `~/.ssh/config`:

```sshconfig
Host excalidraw
  HostName <VM_PUBLIC_IPV4_ADDRESS>
  User ubuntu
  IdentityFile ~/.ssh/excalidraw
```

```bash
# Local

# Connect to VM via SSH
ssh excalidraw
```

### Configure DNS

Add an A record in your DNS provider to point your domain to the VM public IP.

| Record Name | Type | Value                    | TTL |
| ----------- | ---- | ------------------------ | --- |
| <YOUR_FQDN> | A    | <VM_PUBLIC_IPV4_ADDRESS> | 300 |

### Set Up Excalidraw Server

```bash
# VM

# Clone repository
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git

# Move to repository
cd ExcalidrawCollaboration

# Initialize submodules
git submodule update --init --recursive

# Set up Ubuntu
./ubuntu/setup.sh

# Prepare .env file
cp .env.example .env
```

### Configure Basic Settings

```env
# Required
VITE_APP_WS_SERVER_URL=https://<YOUR_FQDN>
```

Replace every occurrence of `excalidraw.realunivlog.com` in `docker/nginx/default.conf` with your FQDN.

### Configure OIDC

Configure one OIDC provider. To use Google, see [Set Up Google OIDC](docs/google-oidc.md).

Generate the OAuth2 Proxy cookie secret:

```bash
# VM

openssl rand -base64 32 | tr -- '+/' '-_'
```

#### Microsoft Entra ID

1. Access the [Microsoft Entra admin center](https://entra.microsoft.com/)
2. Go to Entra ID -> App registrations -> New registration
3. Register the application
   - Name: Excalidraw
   - Supported account types: Accounts in this organizational directory only (Single tenant)
   - Platform: Web
   - Redirect URI: `https://<YOUR_FQDN>/oauth2/callback`
4. Go to Manage -> Certificates & secrets -> Client secrets -> New client secret
5. Copy the client secret Value immediately and store it securely
6. Save the following values from the application Overview page
   - Application (client) ID
   - Directory (tenant) ID

```env
# Required
OAUTH2_PROXY_PROVIDER=entra-id
OAUTH2_PROXY_CLIENT_ID=<APPLICATION_CLIENT_ID>
OAUTH2_PROXY_CLIENT_SECRET=<CLIENT_SECRET_VALUE>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://login.microsoftonline.com/<DIRECTORY_TENANT_ID>/v2.0
OAUTH2_PROXY_REDIRECT_URL=https://<YOUR_FQDN>/oauth2/callback
OAUTH2_PROXY_SCOPE=openid
OAUTH2_PROXY_COOKIE_SECRET=<GENERATED_COOKIE_SECRET>
```

### Obtain the Initial TLS Certificate

Confirm that your DNS record resolves to the VM public IP and that port 80 is available before continuing.

```bash
# VM

# Start temporary Nginx for the initial ACME challenge
docker run --detach --rm \
  --name certbot-webroot \
  --publish 80:80 \
  --volume /var/www/html:/usr/share/nginx/html \
  nginx:1.30.4-alpine-slim

# Obtain the initial TLS certificate from Let's Encrypt
sudo certbot certonly --webroot -w /var/www/html -d <YOUR_FQDN>

# Stop and remove temporary Nginx
docker stop certbot-webroot
```

### Start Excalidraw Server

Edit `.env` with your preferred editor and configure all required values listed above.

```bash
# VM

# Build images and start all services
make up-b
```

Access Excalidraw at `https://<YOUR_FQDN>`.

### Set Up GitHub Actions

Go to the repository's Settings -> Secrets and variables -> Actions -> Secrets, then add the following repository secrets for `deploy.yml` and `renew.yml`:

> [!NOTE]
> These workflows require direct SSH access and are not compatible with the default AWS SSM setup.

```env
# Required
SSH_HOST=<VM_PUBLIC_IPV4_ADDRESS>
SSH_USERNAME=ubuntu
SSH_PRIVATE_KEY=<SSH_PRIVATE_KEY>
```

- Run the `deploy` workflow manually to pull repository changes, rebuild images, and start the services on the VM.
- Run the `renew` workflow manually to renew the TLS certificate when due and reload Nginx.

### Renew TLS Certificate

Nginx must be running.

```bash
# VM

# Move to repository
cd ~/ExcalidrawCollaboration

# Renew the TLS certificate if due and reload Nginx afterward
make renew
```

### Update Configuration

```bash
# VM

# Move to repository
cd ~/ExcalidrawCollaboration
```

Edit `.env` or `docker/nginx/default.conf` with your preferred editor.

```bash
# VM

# Rebuild images and recreate services
make up-b
```
