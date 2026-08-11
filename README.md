<div align="right">

![GitHub License](https://img.shields.io/github/license/Arata1202/ExcalidrawCollaboration)

</div>

## Getting Started

- This guide supports both AWS EC2 and Azure VM with Terraform.

### Prepare Local Repository

```bash
# Local

# Clone repository
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration

# Initialize submodules
git submodule update --init --recursive

# Install dependencies
npm install
```

### Start Excalidraw Locally

```bash
# Local

# Move to repository
cd ExcalidrawCollaboration

# Start local services
make up-b-dev
```

Access Excalidraw at `http://localhost:9247`.

### Create Resources with Terraform

When using Azure, generate an SSH key first:

```bash
ssh-keygen -t ed25519 -C "excalidraw" -f ~/.ssh/excalidraw -N ""
```

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

For Azure, set `ssh_public_key` in `terraform.tfvars` to the contents of `~/.ssh/excalidraw.pub`. The SSH key is not used by the default AWS SSM configuration.

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

### Prepare VM Repository

```bash
# VM

# Clone repository
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration

# Initialize submodules
git submodule update --init --recursive

# Set up Ubuntu
./ubuntu/setup.sh

# Install dependencies
npm install
```

### Configure DNS

Add an A record in your DNS provider before obtaining the TLS certificate.

| Record Name | Type | Value                    | TTL |
| ----------- | ---- | ------------------------ | --- |
| <YOUR_FQDN> | A    | <VM_PUBLIC_IPV4_ADDRESS> | 300 |

### Set Up GitHub Actions

1. Configure GitHub Actions secrets for `deploy.yml` and `renew.yml`

> [!NOTE]
> These workflows require direct SSH access and are not compatible with the default AWS SSM setup.
> The VM must already contain the repository, encrypted `.env`, and matching `.env.keys`.

```env
# Required
SSH_HOST=<VM_PUBLIC_IPV4_ADDRESS>
SSH_USERNAME=ubuntu
SSH_PRIVATE_KEY=<SSH_PRIVATE_KEY>
```

2. Run the `deploy` workflow manually from GitHub Actions to apply repository changes to the VM
3. Run the `renew` workflow manually from GitHub Actions to renew the TLS certificate when needed

### Set Up Microsoft Entra ID OIDC

For Google OIDC, see [Set Up Google OIDC](docs/google-oidc.md).

1. Access Microsoft Azure portal
2. Go to Microsoft Entra ID -> App registrations
3. Create a new registration
   - Name: Excalidraw
   - Supported account types: Accounts in this organizational directory only
   - Platform: Web
   - Redirect URI: `https://<YOUR_FQDN>/oauth2/callback`
4. Open Certificates & secrets and create a new client secret
5. Save the following values
   - Application (client) ID
   - Directory (tenant) ID
   - Client secret Value (not the Secret ID)

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Prepare .env file
cp .env.example .env

# Generate the OAuth2 Proxy cookie secret
openssl rand -base64 32 | tr -- '+/' '-_'

# Edit .env file
vi .env
```

```env
# Required
DOMAIN=<YOUR_FQDN>
OAUTH2_PROXY_PROVIDER=entra-id
OAUTH2_PROXY_CLIENT_ID=<APPLICATION_CLIENT_ID>
OAUTH2_PROXY_CLIENT_SECRET=<CLIENT_SECRET_VALUE>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://login.microsoftonline.com/<DIRECTORY_TENANT_ID>/v2.0
OAUTH2_PROXY_SCOPE=openid
OAUTH2_PROXY_COOKIE_SECRET=<GENERATED_COOKIE_SECRET>
OAUTH2_PROXY_EMAIL_DOMAINS=<ALLOWED_EMAIL_DOMAIN>
```

### Set Up Excalidraw Server

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Start temporary Nginx for the initial ACME challenge
docker run --detach --rm --name certbot-webroot --publish 80:80 --volume /var/www/html:/usr/share/nginx/html nginx:1.30.4-alpine-slim

# Obtain the initial TLS certificate from Let's Encrypt
sudo certbot certonly --webroot -w /var/www/html -d <YOUR_FQDN>

# Stop and remove temporary Nginx
docker stop certbot-webroot

# Encrypt .env file
make encrypt

# Start server
make up-b-prod
```

Back up `.env.keys` securely. It is required to decrypt `.env` and must not be committed.

Access Excalidraw at `https://<YOUR_FQDN>`.

### Update Configuration

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Decrypt and edit .env
make decrypt
vi .env

# Encrypt .env and restart services
make encrypt
make up-b-prod
```

### Renew TLS Certificate

- Nginx must be running.

```bash
# VM

# Move to repository
cd ExcalidrawCollaboration

# Renew the TLS certificate if due and reload Nginx afterward
make renew
```
