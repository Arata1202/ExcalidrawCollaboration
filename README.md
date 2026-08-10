# Excalidraw Collaboration

Self-hosted Excalidraw frontend and real-time collaboration room with Nginx and OAuth2 Proxy. In production, it runs on the same VM as WorkAdventure and uses WorkAdventure's Traefik for HTTPS routing and automatic Let's Encrypt certificate renewal.

## Architecture

```text
Internet
  -> WorkAdventure Traefik (80/443, TLS)
    -> Excalidraw Nginx (OAuth routing)
      -> Excalidraw frontend
      -> Excalidraw Room
      -> OAuth2 Proxy
```

Traefik and Excalidraw Nginx communicate through the external Docker network named `workadventure-proxy`. The remaining Excalidraw services stay on their private Compose network.

The Terraform configuration in this repository is not used by this deployment. Provision and manage the shared VM through the WorkAdventure repository.

## Prerequisites

- Git, Make, Node.js 24, npm, and Docker
- A WorkAdventure VM running the Compose configuration from the sibling `WorkAdventure` repository
- A domain whose DNS records you can configure
- An OIDC provider

## Set Up Local Repository

```bash
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration
git submodule update --init --recursive
npm install
```

## Start Locally

```bash
make up-b-dev
```

Access Excalidraw at `http://localhost:9247`.

## Deploy to the WorkAdventure VM

### Configure DNS

Point the Excalidraw domain to the public IP of the WorkAdventure VM.

| Record Name                     | Type | Value                          | TTL |
| ------------------------------- | ---- | ------------------------------ | --- |
| `excalidraw.realunivlog.com`    | A    | `<WORKADVENTURE_VM_PUBLIC_IP>`  | 300 |

### Start WorkAdventure Traefik

Update the WorkAdventure repository and start its reverse proxy first. The Make command creates the external shared Docker network when it does not already exist.

```bash
cd ~/WorkAdventure
git pull --ff-only
make up P=reverse-proxy
```

Confirm that the shared network exists.

```bash
docker network inspect workadventure-proxy >/dev/null
```

### Set Up Excalidraw

```bash
cd ~
git clone https://github.com/Arata1202/ExcalidrawCollaboration.git
cd ExcalidrawCollaboration
git submodule update --init --recursive

# Required because the Excalidraw Room image is AMD64-only
sudo apt update
sudo apt install -y qemu-user-static

npm install
cp .env.example .env
```

### Configure Basic Settings

```env
DOMAIN=excalidraw.realunivlog.com
DISABLE_ANONYMOUS=true
```

Set `DISABLE_ANONYMOUS=false` only when anonymous access should be allowed.

### Configure Microsoft Entra ID

1. Open the [Microsoft Entra admin center](https://entra.microsoft.com/).
2. Go to Entra ID -> App registrations -> New registration.
3. Register a Web application with the following redirect URI:

   ```text
   https://excalidraw.realunivlog.com/oauth2/callback
   ```

4. Create a client secret under Certificates & secrets.
5. Copy the Application (client) ID, Directory (tenant) ID, and client secret.

Generate the OAuth2 Proxy cookie secret:

```bash
openssl rand -base64 32 | tr -- '+/' '-_'
```

Add the OIDC settings to `.env`.

```env
OAUTH2_PROXY_PROVIDER=entra-id
OAUTH2_PROXY_CLIENT_ID=<APPLICATION_CLIENT_ID>
OAUTH2_PROXY_CLIENT_SECRET=<CLIENT_SECRET_VALUE>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://login.microsoftonline.com/<DIRECTORY_TENANT_ID>/v2.0
OAUTH2_PROXY_SCOPE=openid
OAUTH2_PROXY_COOKIE_SECRET=<GENERATED_COOKIE_SECRET>
OAUTH2_PROXY_EMAIL_DOMAINS=*
```

To use Google instead, see [Set Up Google OIDC](docs/google-oidc.md).

### Start Excalidraw

```bash
make encrypt
make up-b-prod
```

Back up `.env.keys` securely after the first encryption. It is required to decrypt `.env` and must never be committed.

Traefik obtains and renews the TLS certificate automatically. Certbot is not used by this project.

Access Excalidraw at [https://excalidraw.realunivlog.com](https://excalidraw.realunivlog.com).

### Verify the Deployment

```bash
make ps
docker network inspect workadventure-proxy
curl -I https://excalidraw.realunivlog.com
```

The HTTPS response should redirect unauthenticated users to `/oauth2/sign_in`.

## Update Configuration

```bash
cd ~/ExcalidrawCollaboration
make decrypt
```

Edit `.env`, then apply the changes.

```bash
make encrypt
make up-b-prod
```

## GitHub Actions

The manual `deploy` workflow pulls repository and submodule changes, then rebuilds the services on the VM. Configure these repository secrets when the WorkAdventure VM permits SSH access:

```env
SSH_HOST=<WORKADVENTURE_VM_PUBLIC_IP>
SSH_USERNAME=ubuntu
SSH_PRIVATE_KEY=<SSH_PRIVATE_KEY>
```

TLS renewal does not require a workflow because Traefik manages it automatically.
